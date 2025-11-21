// /server/models/orderModel.js
const db = require('../config/db.config');

const orderModel = {
    getAllOrders: async () => {
        const query = `
            SELECT 
                o.order_id AS id, 
                c.full_name AS customerName, /* Lấy từ bảng customers (đã join sẵn trong SQL cũ) */
                o.total_amount AS totalAmount, 
                o.status AS status, 
                o.order_type AS orderType,
                o.shipper_user_id,
                e.full_name AS staffName,    /* <-- SỬA: Lấy từ employees */
                DATE_FORMAT(o.order_date, '%Y-%m-%d %H:%i:%s') AS orderDate 
            FROM orders o
            LEFT JOIN customers c ON o.customer_id = c.customer_id
            -- JOIN với employees để lấy tên nhân viên sales
            LEFT JOIN employees e ON o.sales_user_id = e.user_id 
            ORDER BY o.order_date DESC
        `;
        try {
            const [rows] = await db.query(query);
            return rows;
        } catch (error) {
            console.error("SQL Error in orderModel:", error);
            throw error; 
        }
    }
};
module.exports = orderModel;