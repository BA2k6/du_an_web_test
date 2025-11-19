// /server/models/dashboardModel.js (VERSION FIX LỖI 500 VÀ NULL)

const db = require('../config/db.config');

const dashboardModel = {
    getMonthlySummary: async (year) => { 
        const startDate = `${year}-01-01`; 
        const endDate = `${year}-12-31`;   

        const query = `
            SELECT
                DATE_FORMAT(o.order_date, '%Y-%m') AS month,
                IFNULL(SUM(o.total_amount), 0) AS salesRevenue, 
                
                -- Tính COGS: Sử dụng LEFT JOIN để không crash khi thiếu chi tiết/sản phẩm
                IFNULL(SUM(od.quantity * IFNULL(p.cost_price, 0)), 0) AS totalCOGS, 
                
                COUNT(DISTINCT o.order_id) AS totalOrders
            FROM orders o
            LEFT JOIN order_details od ON o.order_id = od.order_id /* <-- LEFT JOIN */
            LEFT JOIN products p ON od.product_id = p.product_id   /* <-- LEFT JOIN */
            WHERE o.status = 'Completed'
            -- Dùng DATE() để so sánh an toàn hơn
            AND DATE(o.order_date) BETWEEN ? AND ? 
            GROUP BY month
            ORDER BY month ASC;
        `;
        try {
            const [rows] = await db.query(query, [startDate, endDate]);
            return rows;
        } catch (error) {
            console.error("❌ SQL ERROR in getMonthlySummary (COGS/Orders):", error);
            // Ném lỗi để Controller trả về 500
            throw new Error(`SQL Error on Dashboard Summary: ${error.message}`); 
        }
    },
    
    getMonthlySalaries: async (year) => {
        const query = `
            SELECT 
                DATE_FORMAT(month_year, '%Y-%m') AS month,
                IFNULL(SUM(net_salary), 0) AS totalSalaries
            FROM salaries
            WHERE month_year BETWEEN '${year}-01-01' AND '${year}-12-31'
            GROUP BY month
        `;
        const [rows] = await db.query(query);
        return rows;
    }
};
module.exports = dashboardModel;