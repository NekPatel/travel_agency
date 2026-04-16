import mysql from "mysql2/promise";

let pool;

export function getPool() {
    if (!pool) {
        pool = mysql.createPool({
            host: process.env.HOST,
            port: process.env.PORT || 4000,
            user: process.env.USERNAME,
            password: process.env.PASSWORD,
            database: process.env.DATABASE,
            ssl: { rejectUnauthorized: true },
            connectionLimit: 5
        });
    }
    return pool;
}