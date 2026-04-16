import { getPool } from "./db";

export default async function handler(req, res) {
    const db = getPool();

    try {
        // GET all customers
        if (req.method === "GET") {
            const [rows] = await db.query("SELECT * FROM Customer LIMIT 50");
            return res.status(200).json({ success: true, data: rows });
        }

        // CREATE customer
        if (req.method === "POST") {
            const { name, email, phone, nationality, passport_no } = req.body;

            const [result] = await db.query(
                "INSERT INTO Customer (name,email,Phone,Nationality,passport_no) VALUES (?,?,?,?,?)",
                [name, email, phone, nationality, passport_no]
            );

            return res.status(201).json({ success: true, id: result.insertId });
        }

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
}