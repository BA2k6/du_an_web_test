// /server/models/userModel.js
const db = require('../config/db.config');

const userModel = {
    findByUsername: async (username) => {
        // Truy vấn lấy thông tin cơ bản cho quá trình đăng nhập/xác thực
        const query = `
            SELECT 
                u.user_id, u.password_hash, u.role_id, u.full_name, 
                u.must_change_password, u.status, r.role_name as roleName
            FROM users u
            JOIN roles r ON u.role_id = r.role_id
            WHERE u.username = ? AND u.status = 'Active'
        `;
        const [rows] = await db.query(query, [username]);
        return rows.length > 0 ? rows[0] : null;
    },
    
    getAllUsers: async () => {
        const query = `
            SELECT 
                u.user_id as id, u.username, u.full_name as fullName, 
                u.email, u.phone, u.employee_type, u.department, 
                u.base_salary, u.commission_rate, u.status, u.must_change_password,
                r.role_name as roleName
            FROM users u
            JOIN roles r ON u.role_id = r.role_id
            ORDER BY u.user_id
        `;
        const [rows] = await db.query(query);
        return rows;
    },
    
    updatePassword: async (userId, newPasswordHash, mustChangePassword) => {
        const query = `
            UPDATE users 
            SET 
                password_hash = ?, 
                must_change_password = ?
            WHERE 
                user_id = ?
        `;
        await db.query(query, [newPasswordHash, mustChangePassword, userId]);
        return true;
    }
};
module.exports = userModel;