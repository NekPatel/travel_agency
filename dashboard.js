import { getPool } from "./db";

export default async function handler(req, res) {
    try {
        const db = getPool();

        const [customers] = await db.query("SELECT COUNT(*) val FROM Customer");
        const [bookings] = await db.query("SELECT COUNT(*) val FROM Booking");
        const [packages] = await db.query("SELECT COUNT(*) val FROM Package");
        const [revenue] = await db.query("SELECT COALESCE(SUM(Amount),0) val FROM Payment");

        res.status(200).json({
            success: true,
            data: {
                total_customers: customers[0].val,
                total_bookings: bookings[0].val,
                total_packages: packages[0].val,
                total_revenue: revenue[0].val
            }
        });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
}