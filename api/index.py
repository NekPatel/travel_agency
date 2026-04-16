"""
Wanderlust Travel & Tourism — Python Flask Backend
Connects to TiDB Cloud (MySQL) and exposes REST API endpoints
for all 24 database tables.

Run:
    pip install -r requirements.txt
    python app.py
"""

import os
import mysql.connector
from mysql.connector import Error
from flask import Flask, jsonify, request
from flask_cors import CORS
from dotenv import load_dotenv

# ── Load environment variables from .env ──────────────────────────────────────
load_dotenv()

app = Flask(__name__)
CORS(app)  # Allow frontend HTML to call this API


# ── Database connection ───────────────────────────────────────────────────────
def get_db():
    """Create and return a new MySQL connection to TiDB Cloud."""
    try:
        conn = mysql.connector.connect(
            host=os.getenv("HOST"),
            port=int(os.getenv("PORT", 4000)),
            user=os.getenv("USERNAME"),
            password=os.getenv("PASSWORD"),
            database=os.getenv("DATABASE"),
            ssl_disabled=False,          # TiDB Cloud requires SSL
            connection_timeout=10
        )
        return conn
    except Error as e:
        print(f"[DB ERROR] {e}")
        return None


def query(sql, params=None, fetch=True):
    """
    Run a SQL query and return results.
    fetch=True  → SELECT  (returns list of dicts)
    fetch=False → INSERT/UPDATE/DELETE (returns lastrowid or rowcount)
    """
    conn = get_db()
    if not conn:
        return None, "Cannot connect to database"
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(sql, params or ())
        if fetch:
            result = cursor.fetchall()
        else:
            conn.commit()
            result = {"lastrowid": cursor.lastrowid, "rowcount": cursor.rowcount}
        cursor.close()
        conn.close()
        return result, None
    except Error as e:
        conn.close()
        return None, str(e)


# ── Helper ────────────────────────────────────────────────────────────────────
def ok(data):
    return jsonify({"success": True, "data": data})

def err(msg, code=400):
    return jsonify({"success": False, "error": msg}), code


# ═══════════════════════════════════════════════════════════════════════════════
#  ROOT
# ═══════════════════════════════════════════════════════════════════════════════
@app.route("/")
def index():
    return ok({
        "message": "🌍 Wanderlust Travel API is running!",
        "version": "1.0",
        "endpoints": [
            "/api/dashboard",
            "/api/customers", "/api/customers/<id>",
            "/api/agents",    "/api/agents/<id>",
            "/api/destinations",
            "/api/hotels",
            "/api/rooms",
            "/api/packages",  "/api/packages/<id>",
            "/api/bookings",  "/api/bookings/<id>",
            "/api/payments",
            "/api/transport",
            "/api/schedules",
            "/api/feedback",
            "/api/offers",
            "/api/insurance",
            "/api/support",
            "/api/loyalty",
        ]
    })


# ═══════════════════════════════════════════════════════════════════════════════
#  DASHBOARD — aggregate stats
# ═══════════════════════════════════════════════════════════════════════════════
@app.route("/api/dashboard")
def dashboard():
    stats = {}

    queries = {
        "total_customers": "SELECT COUNT(*) AS val FROM Customer",
        "total_bookings":  "SELECT COUNT(*) AS val FROM Booking",
        "total_packages":  "SELECT COUNT(*) AS val FROM Package",
        "total_revenue":   "SELECT COALESCE(SUM(Amount),0) AS val FROM Payment",
        "confirmed_bookings": "SELECT COUNT(*) AS val FROM Booking WHERE status='Confirmed'",
        "pending_bookings":   "SELECT COUNT(*) AS val FROM Booking WHERE status='Pending'",
        "cancelled_bookings": "SELECT COUNT(*) AS val FROM Booking WHERE status='Cancelled'",
        "total_destinations": "SELECT COUNT(*) AS val FROM Destination",
        "total_hotels":       "SELECT COUNT(*) AS val FROM Hotel",
        "total_agents":       "SELECT COUNT(*) AS val FROM Agent",
        "open_tickets":       "SELECT COUNT(*) AS val FROM Support_Ticket WHERE status != 'Resolved'",
        "avg_feedback":       "SELECT ROUND(AVG(Rating),2) AS val FROM Feedback",
    }

    for key, sql in queries.items():
        rows, error = query(sql)
        stats[key] = rows[0]["val"] if rows and not error else 0

    # Recent 5 bookings
    recent_sql = """
        SELECT b.booking_id, c.name AS customer, p.Name AS package,
               b.status, b.Total_Amount, b.Booking_Date
        FROM Booking b
        JOIN Customer c ON b.customer_id = c.customer_id
        JOIN Package  p ON b.package_id  = p.package_id
        ORDER BY b.booking_id DESC LIMIT 5
    """
    recent, _ = query(recent_sql)
    stats["recent_bookings"] = recent or []

    # Top 5 destinations
    top_dest_sql = """
        SELECT d.Name, d.Country, d.Rating,
               COUNT(pd.package_dest_id) AS package_count
        FROM Destination d
        LEFT JOIN Package_Destination pd ON d.destination_id = pd.destination_id
        GROUP BY d.destination_id
        ORDER BY d.Rating DESC LIMIT 5
    """
    top_dest, _ = query(top_dest_sql)
    stats["top_destinations"] = top_dest or []

    return ok(stats)


# ═══════════════════════════════════════════════════════════════════════════════
#  CUSTOMERS
# ═══════════════════════════════════════════════════════════════════════════════
@app.route("/api/customers", methods=["GET", "POST"])
def customers():
    if request.method == "GET":
        search = request.args.get("search", "")
        limit  = int(request.args.get("limit", 50))
        offset = int(request.args.get("offset", 0))
        if search:
            sql = """SELECT * FROM Customer
                     WHERE name LIKE %s OR email LIKE %s OR Nationality LIKE %s
                     LIMIT %s OFFSET %s"""
            rows, error = query(sql, (f"%{search}%", f"%{search}%", f"%{search}%", limit, offset))
        else:
            rows, error = query("SELECT * FROM Customer LIMIT %s OFFSET %s", (limit, offset))
        if error:
            return err(error)
        return ok(rows)

    # POST — create new customer
    data = request.json or {}
    sql = """INSERT INTO Customer (name, email, Phone, Nationality, passport_no)
             VALUES (%s, %s, %s, %s, %s)"""
    result, error = query(sql, (
        data.get("name"), data.get("email"),
        data.get("phone"), data.get("nationality"), data.get("passport_no")
    ), fetch=False)
    if error:
        return err(error)
    return ok({"message": "Customer created", "id": result["lastrowid"]}), 201


@app.route("/api/customers/<int:cid>", methods=["GET", "PUT", "DELETE"])
def customer_detail(cid):
    if request.method == "GET":
        rows, error = query("SELECT * FROM Customer WHERE customer_id=%s", (cid,))
        if error: return err(error)
        if not rows: return err("Customer not found", 404)
        return ok(rows[0])

    if request.method == "PUT":
        data = request.json or {}
        sql = """UPDATE Customer SET name=%s, email=%s, Phone=%s,
                 Nationality=%s, passport_no=%s WHERE customer_id=%s"""
        result, error = query(sql, (
            data.get("name"), data.get("email"), data.get("phone"),
            data.get("nationality"), data.get("passport_no"), cid
        ), fetch=False)
        if error: return err(error)
        return ok({"message": "Customer updated"})

    if request.method == "DELETE":
        result, error = query("DELETE FROM Customer WHERE customer_id=%s", (cid,), fetch=False)
        if error: return err(error)
        return ok({"message": "Customer deleted"})


# ═══════════════════════════════════════════════════════════════════════════════
#  AGENTS
# ═══════════════════════════════════════════════════════════════════════════════
@app.route("/api/agents", methods=["GET", "POST"])
def agents():
    if request.method == "GET":
        rows, error = query("SELECT * FROM Agent ORDER BY agent_id LIMIT 100")
        if error: return err(error)
        return ok(rows)

    data = request.json or {}
    sql = "INSERT INTO Agent (name, Email, Phone, Commission_rate) VALUES (%s,%s,%s,%s)"
    result, error = query(sql, (
        data.get("name"), data.get("email"),
        data.get("phone"), data.get("commission_rate", 0)
    ), fetch=False)
    if error: return err(error)
    return ok({"message": "Agent created", "id": result["lastrowid"]}), 201


@app.route("/api/agents/<int:aid>", methods=["GET", "PUT", "DELETE"])
def agent_detail(aid):
    if request.method == "GET":
        rows, error = query("SELECT * FROM Agent WHERE agent_id=%s", (aid,))
        if error: return err(error)
        if not rows: return err("Agent not found", 404)
        return ok(rows[0])

    if request.method == "PUT":
        data = request.json or {}
        sql = "UPDATE Agent SET name=%s, Email=%s, Phone=%s, Commission_rate=%s WHERE agent_id=%s"
        result, error = query(sql, (
            data.get("name"), data.get("email"),
            data.get("phone"), data.get("commission_rate"), aid
        ), fetch=False)
        if error: return err(error)
        return ok({"message": "Agent updated"})

    if request.method == "DELETE":
        result, error = query("DELETE FROM Agent WHERE agent_id=%s", (aid,), fetch=False)
        if error: return err(error)
        return ok({"message": "Agent deleted"})


# ═══════════════════════════════════════════════════════════════════════════════
#  DESTINATIONS
# ═══════════════════════════════════════════════════════════════════════════════
@app.route("/api/destinations", methods=["GET", "POST"])
def destinations():
    if request.method == "GET":
        search  = request.args.get("search", "")
        country = request.args.get("country", "")
        sql = "SELECT * FROM Destination WHERE 1=1"
        params = []
        if search:
            sql += " AND (Name LIKE %s OR Description LIKE %s)"
            params += [f"%{search}%", f"%{search}%"]
        if country:
            sql += " AND Country=%s"
            params.append(country)
        sql += " ORDER BY Rating DESC"
        rows, error = query(sql, params)
        if error: return err(error)
        return ok(rows)

    data = request.json or {}
    sql = "INSERT INTO Destination (Name, Country, Description, Rating) VALUES (%s,%s,%s,%s)"
    result, error = query(sql, (
        data.get("name"), data.get("country"),
        data.get("description"), data.get("rating")
    ), fetch=False)
    if error: return err(error)
    return ok({"message": "Destination created", "id": result["lastrowid"]}), 201


@app.route("/api/destinations/<int:did>", methods=["GET"])
def destination_detail(did):
    rows, error = query("SELECT * FROM Destination WHERE destination_id=%s", (did,))
    if error: return err(error)
    if not rows: return err("Destination not found", 404)
    # Also get hotels for this destination
    hotels, _ = query("SELECT * FROM Hotel WHERE destination_id=%s", (did,))
    result = rows[0]
    result["hotels"] = hotels or []
    return ok(result)


# ═══════════════════════════════════════════════════════════════════════════════
#  HOTELS
# ═══════════════════════════════════════════════════════════════════════════════
@app.route("/api/hotels", methods=["GET", "POST"])
def hotels():
    if request.method == "GET":
        sql = """SELECT h.*, d.Name AS destination_name, d.Country
                 FROM Hotel h JOIN Destination d ON h.destination_id=d.destination_id
                 ORDER BY h.hotel_id LIMIT 100"""
        rows, error = query(sql)
        if error: return err(error)
        return ok(rows)

    data = request.json or {}
    sql = "INSERT INTO Hotel (destination_id, Name, Rating, Contact_no) VALUES (%s,%s,%s,%s)"
    result, error = query(sql, (
        data.get("destination_id"), data.get("name"),
        data.get("rating"), data.get("contact_no")
    ), fetch=False)
    if error: return err(error)
    return ok({"message": "Hotel created", "id": result["lastrowid"]}), 201


# ═══════════════════════════════════════════════════════════════════════════════
#  ROOMS
# ═══════════════════════════════════════════════════════════════════════════════
@app.route("/api/rooms", methods=["GET", "POST"])
def rooms():
    if request.method == "GET":
        available = request.args.get("available")
        hotel_id  = request.args.get("hotel_id")
        sql = """SELECT r.*, h.Name AS hotel_name
                 FROM Room r JOIN Hotel h ON r.hotel_id=h.hotel_id WHERE 1=1"""
        params = []
        if available == "true":
            sql += " AND r.Availability_Status=1"
        if hotel_id:
            sql += " AND r.hotel_id=%s"
            params.append(hotel_id)
        rows, error = query(sql, params)
        if error: return err(error)
        return ok(rows)

    data = request.json or {}
    sql = """INSERT INTO Room (hotel_id, Room_Type, PricePerNight, Capacity, Availability_Status)
             VALUES (%s,%s,%s,%s,%s)"""
    result, error = query(sql, (
        data.get("hotel_id"), data.get("room_type"),
        data.get("price_per_night"), data.get("capacity"),
        data.get("availability_status", True)
    ), fetch=False)
    if error: return err(error)
    return ok({"message": "Room created", "id": result["lastrowid"]}), 201


# ═══════════════════════════════════════════════════════════════════════════════
#  PACKAGES
# ═══════════════════════════════════════════════════════════════════════════════
@app.route("/api/packages", methods=["GET", "POST"])
def packages():
    if request.method == "GET":
        sql = """SELECT p.*, a.name AS agent_name, t.Type_Name AS tour_type
                 FROM Package p
                 JOIN Agent    a ON p.agent_id     = a.agent_id
                 JOIN Tour_Type t ON p.tour_type_id = t.tour_type_id
                 ORDER BY p.package_id LIMIT 100"""
        rows, error = query(sql)
        if error: return err(error)
        return ok(rows)

    data = request.json or {}
    sql = """INSERT INTO Package (agent_id,tour_type_id,Name,Duration_Days,Price,description)
             VALUES (%s,%s,%s,%s,%s,%s)"""
    result, error = query(sql, (
        data.get("agent_id"), data.get("tour_type_id"),
        data.get("name"), data.get("duration_days"),
        data.get("price"), data.get("description")
    ), fetch=False)
    if error: return err(error)
    return ok({"message": "Package created", "id": result["lastrowid"]}), 201


@app.route("/api/packages/<int:pid>", methods=["GET", "PUT", "DELETE"])
def package_detail(pid):
    if request.method == "GET":
        rows, error = query("""
            SELECT p.*, a.name AS agent_name, t.Type_Name AS tour_type
            FROM Package p
            JOIN Agent a     ON p.agent_id=a.agent_id
            JOIN Tour_Type t ON p.tour_type_id=t.tour_type_id
            WHERE p.package_id=%s""", (pid,))
        if error: return err(error)
        if not rows: return err("Package not found", 404)
        # Destinations in this package
        dests, _ = query("""
            SELECT d.*, pd.sequence_no FROM Destination d
            JOIN Package_Destination pd ON d.destination_id=pd.destination_id
            WHERE pd.package_id=%s ORDER BY pd.sequence_no""", (pid,))
        result = rows[0]
        result["destinations"] = dests or []
        return ok(result)

    if request.method == "PUT":
        data = request.json or {}
        sql = """UPDATE Package SET Name=%s,Duration_Days=%s,Price=%s,description=%s
                 WHERE package_id=%s"""
        result, error = query(sql, (
            data.get("name"), data.get("duration_days"),
            data.get("price"), data.get("description"), pid
        ), fetch=False)
        if error: return err(error)
        return ok({"message": "Package updated"})

    if request.method == "DELETE":
        result, error = query("DELETE FROM Package WHERE package_id=%s", (pid,), fetch=False)
        if error: return err(error)
        return ok({"message": "Package deleted"})


# ═══════════════════════════════════════════════════════════════════════════════
#  BOOKINGS
# ═══════════════════════════════════════════════════════════════════════════════
@app.route("/api/bookings", methods=["GET", "POST"])
def bookings():
    if request.method == "GET":
        status = request.args.get("status", "")
        limit  = int(request.args.get("limit", 50))
        sql = """SELECT b.*, c.name AS customer_name, c.email,
                        p.Name AS package_name, p.Price AS package_price
                 FROM Booking b
                 JOIN Customer c ON b.customer_id=c.customer_id
                 JOIN Package  p ON b.package_id =p.package_id"""
        params = []
        if status:
            sql += " WHERE b.status=%s"
            params.append(status)
        sql += " ORDER BY b.booking_id DESC LIMIT %s"
        params.append(limit)
        rows, error = query(sql, params)
        if error: return err(error)
        return ok(rows)

    data = request.json or {}
    sql = """INSERT INTO Booking (customer_id,package_id,Booking_Date,
             Start_Date,End_Date,Total_Amount,status)
             VALUES (%s,%s,%s,%s,%s,%s,%s)"""
    result, error = query(sql, (
        data.get("customer_id"), data.get("package_id"),
        data.get("booking_date"), data.get("start_date"),
        data.get("end_date"), data.get("total_amount"),
        data.get("status", "Pending")
    ), fetch=False)
    if error: return err(error)
    return ok({"message": "Booking created", "id": result["lastrowid"]}), 201


@app.route("/api/bookings/<int:bid>", methods=["GET", "PUT", "DELETE"])
def booking_detail(bid):
    if request.method == "GET":
        rows, error = query("""
            SELECT b.*, c.name AS customer_name, c.email, c.Phone,
                   p.Name AS package_name, p.Duration_Days
            FROM Booking b
            JOIN Customer c ON b.customer_id=c.customer_id
            JOIN Package  p ON b.package_id =p.package_id
            WHERE b.booking_id=%s""", (bid,))
        if error: return err(error)
        if not rows: return err("Booking not found", 404)
        payments, _ = query("SELECT * FROM Payment WHERE booking_id=%s", (bid,))
        result = rows[0]
        result["payments"] = payments or []
        return ok(result)

    if request.method == "PUT":
        data = request.json or {}
        sql = "UPDATE Booking SET status=%s, Total_Amount=%s WHERE booking_id=%s"
        result, error = query(sql, (data.get("status"), data.get("total_amount"), bid), fetch=False)
        if error: return err(error)
        return ok({"message": "Booking updated"})

    if request.method == "DELETE":
        result, error = query("DELETE FROM Booking WHERE booking_id=%s", (bid,), fetch=False)
        if error: return err(error)
        return ok({"message": "Booking deleted"})


# ═══════════════════════════════════════════════════════════════════════════════
#  PAYMENTS
# ═══════════════════════════════════════════════════════════════════════════════
@app.route("/api/payments", methods=["GET", "POST"])
def payments():
    if request.method == "GET":
        sql = """SELECT p.*, b.status AS booking_status, c.name AS customer_name
                 FROM Payment p
                 JOIN Booking b  ON p.booking_id=b.booking_id
                 JOIN Customer c ON b.customer_id=c.customer_id
                 ORDER BY p.payment_id DESC LIMIT 100"""
        rows, error = query(sql)
        if error: return err(error)
        return ok(rows)

    data = request.json or {}
    sql = """INSERT INTO Payment (booking_id,Amount,Payment_Date,Method,transaction_id)
             VALUES (%s,%s,%s,%s,%s)"""
    result, error = query(sql, (
        data.get("booking_id"), data.get("amount"),
        data.get("payment_date"), data.get("method"),
        data.get("transaction_id")
    ), fetch=False)
    if error: return err(error)
    return ok({"message": "Payment recorded", "id": result["lastrowid"]}), 201


# ═══════════════════════════════════════════════════════════════════════════════
#  TRANSPORT & SCHEDULES
# ═══════════════════════════════════════════════════════════════════════════════
@app.route("/api/transport", methods=["GET", "POST"])
def transport():
    if request.method == "GET":
        rows, error = query("SELECT * FROM Transport ORDER BY transport_id")
        if error: return err(error)
        return ok(rows)

    data = request.json or {}
    sql = "INSERT INTO Transport (type,Company_Name,Contact_No) VALUES (%s,%s,%s)"
    result, error = query(sql, (data.get("type"), data.get("company_name"), data.get("contact_no")), fetch=False)
    if error: return err(error)
    return ok({"message": "Transport created", "id": result["lastrowid"]}), 201


@app.route("/api/schedules", methods=["GET", "POST"])
def schedules():
    if request.method == "GET":
        sql = """SELECT s.*, t.type AS transport_type, t.Company_Name
                 FROM Schedule s JOIN Transport t ON s.transport_id=t.transport_id
                 ORDER BY s.Departure_Time LIMIT 100"""
        rows, error = query(sql)
        if error: return err(error)
        return ok(rows)

    data = request.json or {}
    sql = """INSERT INTO Schedule (transport_id,source,destination,Departure_Time,Arrival_Time,fare)
             VALUES (%s,%s,%s,%s,%s,%s)"""
    result, error = query(sql, (
        data.get("transport_id"), data.get("source"), data.get("destination"),
        data.get("departure_time"), data.get("arrival_time"), data.get("fare")
    ), fetch=False)
    if error: return err(error)
    return ok({"message": "Schedule created", "id": result["lastrowid"]}), 201


# ═══════════════════════════════════════════════════════════════════════════════
#  FEEDBACK
# ═══════════════════════════════════════════════════════════════════════════════
@app.route("/api/feedback", methods=["GET", "POST"])
def feedback():
    if request.method == "GET":
        sql = """SELECT f.*, c.name AS customer_name, p.Name AS package_name
                 FROM Feedback f
                 JOIN Customer c ON f.customer_id=c.customer_id
                 JOIN Package  p ON f.package_id =p.package_id
                 ORDER BY f.feedback_id DESC LIMIT 100"""
        rows, error = query(sql)
        if error: return err(error)
        return ok(rows)

    data = request.json or {}
    sql = "INSERT INTO Feedback (customer_id,package_id,Rating,Comments,Feedback_Date) VALUES (%s,%s,%s,%s,%s)"
    result, error = query(sql, (
        data.get("customer_id"), data.get("package_id"),
        data.get("rating"), data.get("comments"), data.get("feedback_date")
    ), fetch=False)
    if error: return err(error)
    return ok({"message": "Feedback submitted", "id": result["lastrowid"]}), 201


# ═══════════════════════════════════════════════════════════════════════════════
#  OFFERS
# ═══════════════════════════════════════════════════════════════════════════════
@app.route("/api/offers", methods=["GET", "POST"])
def offers():
    if request.method == "GET":
        rows, error = query("SELECT * FROM Offer ORDER BY End_Date DESC")
        if error: return err(error)
        return ok(rows)

    data = request.json or {}
    sql = "INSERT INTO Offer (title,Discount_Percent,Start_Date,End_Date) VALUES (%s,%s,%s,%s)"
    result, error = query(sql, (
        data.get("title"), data.get("discount_percent"),
        data.get("start_date"), data.get("end_date")
    ), fetch=False)
    if error: return err(error)
    return ok({"message": "Offer created", "id": result["lastrowid"]}), 201


# ═══════════════════════════════════════════════════════════════════════════════
#  INSURANCE
# ═══════════════════════════════════════════════════════════════════════════════
@app.route("/api/insurance", methods=["GET", "POST"])
def insurance():
    if request.method == "GET":
        sql = """SELECT ti.*, c.name AS customer_name,
                        ip.Provider_Name
                 FROM Travel_Insurance ti
                 JOIN Customer c ON ti.customer_id=c.customer_id
                 JOIN Insurance_Provider ip ON ti.insurance_provider_id=ip.insurance_provider_id
                 ORDER BY ti.insurance_id DESC LIMIT 100"""
        rows, error = query(sql)
        if error: return err(error)
        return ok(rows)

    data = request.json or {}
    sql = """INSERT INTO Travel_Insurance
             (customer_id,insurance_provider_id,Policy_No,Start_Date,End_Date,Coverage_Amount)
             VALUES (%s,%s,%s,%s,%s,%s)"""
    result, error = query(sql, (
        data.get("customer_id"), data.get("insurance_provider_id"),
        data.get("policy_no"), data.get("start_date"),
        data.get("end_date"), data.get("coverage_amount")
    ), fetch=False)
    if error: return err(error)
    return ok({"message": "Insurance created", "id": result["lastrowid"]}), 201


# ═══════════════════════════════════════════════════════════════════════════════
#  INSURANCE PROVIDERS
# ═══════════════════════════════════════════════════════════════════════════════
@app.route("/api/insurance-providers", methods=["GET"])
def insurance_providers():
    rows, error = query("SELECT * FROM Insurance_Provider")
    if error: return err(error)
    return ok(rows)


# ═══════════════════════════════════════════════════════════════════════════════
#  SUPPORT TICKETS
# ═══════════════════════════════════════════════════════════════════════════════
@app.route("/api/support", methods=["GET", "POST"])
def support():
    if request.method == "GET":
        status = request.args.get("status", "")
        sql = """SELECT st.*, c.name AS customer_name
                 FROM Support_Ticket st
                 JOIN Customer c ON st.customer_id=c.customer_id"""
        params = []
        if status:
            sql += " WHERE st.status=%s"
            params.append(status)
        sql += " ORDER BY st.created_at DESC LIMIT 100"
        rows, error = query(sql, params)
        if error: return err(error)
        return ok(rows)

    data = request.json or {}
    sql = """INSERT INTO Support_Ticket
             (customer_id,booking_id,Issue_Type,Description,status,created_at)
             VALUES (%s,%s,%s,%s,%s,NOW())"""
    result, error = query(sql, (
        data.get("customer_id"), data.get("booking_id"),
        data.get("issue_type"), data.get("description"),
        data.get("status", "Open")
    ), fetch=False)
    if error: return err(error)
    return ok({"message": "Ticket created", "id": result["lastrowid"]}), 201


@app.route("/api/support/<int:tid>", methods=["PUT"])
def resolve_ticket(tid):
    data = request.json or {}
    sql = "UPDATE Support_Ticket SET status=%s, resolved_at=NOW() WHERE ticket_id=%s"
    result, error = query(sql, (data.get("status", "Resolved"), tid), fetch=False)
    if error: return err(error)
    return ok({"message": "Ticket updated"})


# ═══════════════════════════════════════════════════════════════════════════════
#  LOYALTY
# ═══════════════════════════════════════════════════════════════════════════════
@app.route("/api/loyalty", methods=["GET"])
def loyalty():
    sql = """SELECT cl.*, c.name AS customer_name, lp.name AS program_name
             FROM Customer_Loyalty cl
             JOIN Customer c ON cl.customer_id=c.customer_id
             JOIN Loyalty_Program lp ON cl.program_id=lp.program_id
             ORDER BY cl.Total_Points DESC LIMIT 100"""
    rows, error = query(sql)
    if error: return err(error)
    return ok(rows)


@app.route("/api/loyalty/programs", methods=["GET"])
def loyalty_programs():
    rows, error = query("SELECT * FROM Loyalty_Program")
    if error: return err(error)
    return ok(rows)


# ═══════════════════════════════════════════════════════════════════════════════
#  TOUR TYPES
# ═══════════════════════════════════════════════════════════════════════════════
@app.route("/api/tour-types", methods=["GET"])
def tour_types():
    rows, error = query("SELECT * FROM Tour_Type")
    if error: return err(error)
    return ok(rows)


# ═══════════════════════════════════════════════════════════════════════════════
#  RUN
# ═══════════════════════════════════════════════════════════════════════════════
if __name__ == "__main__":
    import sys
    sys.stdout.reconfigure(encoding="utf-8")
    print("Starting Wanderlust Travel API...")
    print("Connecting to TiDB Cloud at port 5000...")
    app.run(host="0.0.0.0", port=5000, debug=True)
