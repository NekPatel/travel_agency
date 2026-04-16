import { getPool } from "./db";

export default async function handler(req, res) {
    const db = getPool();

    try {
        const [rows] = await db.query(`
      SELECT h.*, d.Name destination_name
      FROM Hotel h JOIN Destination d
      ON h.destination_id=d.destination_id
    `);

        res.status(200).json({ success: true, data: rows });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
}