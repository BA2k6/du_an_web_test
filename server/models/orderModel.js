const db = require('../config/db.config');

const orderModel = {
    getAllOrders: async () => {
        const query = `
            SELECT 
                o.order_id AS id, 
                o.customer_name AS customerName,
                o.total_amount AS totalAmount, 
                o.status AS status, 
                o.order_type AS orderType,
                o.shipper_user_id,
                
                u.full_name AS staffName, 
                s.full_name AS shipperName,
                
                DATE_FORMAT(o.order_date, '%Y-%m-%d %H:%i:%s') AS orderDate 
            FROM orders o
            JOIN users u ON o.sales_user_id = u.user_id
            LEFT JOIN users s ON o.shipper_user_id = s.user_id
            ORDER BY o.order_date DESC
        `;

        try {
            const [rows] = await db.query(query);
            return rows;
        } catch (error) {
            console.error("❌ SQL ERROR trong orderModel:", error);
            throw error; 
        }
    }
};

module.exports = orderModel;
