// /server/models/userModel.js (Phiên bản cho DB Tách Bảng Users/Employees)
const db = require('../config/db.config');

const userModel = {
    // 1. Tìm user theo username (Dùng cho Login)
    findByUsername: async (username) => {
        // Sử dụng COALESCE để lấy tên từ bảng Employees HOẶC Customers tùy vào user đó là ai
        const query = `
            SELECT 
                u.user_id, 
                u.username, 
                u.password_hash, 
                u.role_id, 
                u.status, 
                u.must_change_password,
                r.role_name as roleName,
                -- Lấy tên: Nếu có trong employees thì lấy, nếu không thì lấy trong customers, không thì 'Unknown'
                COALESCE(e.full_name, c.full_name, u.username) as full_name
            FROM users u
            JOIN roles r ON u.role_id = r.role_id
            LEFT JOIN employees e ON u.user_id = e.user_id
            LEFT JOIN customers c ON u.user_id = c.user_id
            WHERE u.username = ? AND u.status = 'Active'
        `;
        
        try {
            const [rows] = await db.query(query, [username]);
            return rows.length > 0 ? rows[0] : null;
        } catch (error) {
            console.error("SQL Error in findByUsername:", error);
            throw error;
        }
    },

    // 2. Cập nhật mật khẩu
    updatePassword: async (userId, newPasswordHash, mustChangePassword) => {
        const query = `UPDATE users SET password_hash = ?, must_change_password = ? WHERE user_id = ?`;
        await db.query(query, [newPasswordHash, mustChangePassword, userId]);
        return true;
    },
    
    // 3. Lấy danh sách nhân viên (Chỉ lấy những user có trong bảng employees)
    getAllUsers: async () => {
         const query = `
            SELECT 
                u.user_id, u.username, u.status, u.must_change_password,
                e.full_name, e.email, e.phone, e.department, e.base_salary, e.employee_type,
                r.role_name as roleName
            FROM users u
            JOIN roles r ON u.role_id = r.role_id
            JOIN employees e ON u.user_id = e.user_id
            ORDER BY u.created_at DESC
        `;
        try {
            const [rows] = await db.query(query);
            return rows;
        } catch (error) {
            console.error("SQL Error in getAllUsers:", error);
            throw error;
        }
    }
};

module.exports = userModel;