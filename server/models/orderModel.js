// /server/models/orderModel.js
const db = require('../config/db.config');

const orderModel = {
    getAllOrders: async () => {
       // /server/models/orderModel.js (Đảm bảo tất cả cột đều có alias rõ ràng)
// ...
const query = `
    SELECT 
        o.order_id as id, 
        o.order_date as orderDate, 
        o.total_amount as totalAmount, 
        o.status, 
        o.customer_name as customerName, /* Lấy tên từ bảng orders */
        u.full_name as staffName,        /* Tên nhân viên từ bảng users */
        o.order_type as orderType
    FROM orders o
    JOIN users u ON o.sales_user_id = u.user_id 
    /* KHÔNG JOIN customers, vì tên khách hàng đã có trong bảng orders */
    ORDER BY o.order_date DESC
`;
// ...
        const [rows] = await db.query(query);
        return rows;
    }
};

module.exports = orderModel;