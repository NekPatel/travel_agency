import { getPool } from "./db";

export default async function handler(req, res) {
    const db = getPool();

    try {
        const [rows] = await db.query("SELECT * FROM Payment ORDER BY payment_id DESC LIMIT 100");
        res.status(200).json({ success: true, data: rows });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
}