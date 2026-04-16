import { getPool } from "./db";

export default async function handler(req, res) {
    const db = getPool();

    try {
        if (req.method === "GET") {
            const [rows] = await db.query("SELECT * FROM Agent");
            return res.status(200).json({ success: true, data: rows });
        }

        if (req.method === "POST") {
            const { name, email, phone, commission_rate } = req.body;

            const [result] = await db.query(
                "INSERT INTO Agent (name,Email,Phone,Commission_rate) VALUES (?,?,?,?)",
                [name, email, phone, commission_rate]
            );

            return res.status(201).json({ success: true, id: result.insertId });
        }

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
}