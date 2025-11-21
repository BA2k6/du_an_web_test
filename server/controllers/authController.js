// /server/controllers/authController.js

const userModel = require('../models/userModel');
const jwt = require('jsonwebtoken');
const db = require('../config/db.config'); // Cần import DB để xử lý Transaction khi đăng ký

const JWT_SECRET = process.env.JWT_SECRET || 'default_secret';

const authController = {
    // ============================================================
    // 1. ĐĂNG NHẬP
    // ============================================================
    login: async (req, res) => {
        const { username, password } = req.body;

        if (!username || !password) {
            return res.status(400).json({ message: 'Vui lòng nhập tài khoản và mật khẩu.' });
        }

        try {
            // Gọi Model để tìm user (Model đã tự động JOIN với Employees/Customers để lấy tên)
            const user = await userModel.findByUsername(username);

            if (!user) {
                return res.status(401).json({ message: 'Tài khoản không tồn tại.' });
            }
            
            // So sánh mật khẩu (Plaintext - do dữ liệu mẫu là không mã hóa)
            // Nếu sau này dùng bcrypt, đổi thành: await bcrypt.compare(password, user.password_hash)
            if (user.password_hash !== password) {
                return res.status(401).json({ message: 'Mật khẩu không chính xác.' });
            }

            // Tạo Token
            const token = jwt.sign(
                { userId: user.user_id, roleId: user.role_id }, 
                JWT_SECRET, 
                { expiresIn: '1d' }
            );
            
            // Trả về thông tin (fullName lấy từ bảng Employees/Customers thông qua JOIN)
            res.status(200).json({
                message: 'Đăng nhập thành công',
                token,
                user: {
                    userId: user.user_id,
                    fullName: user.full_name || user.username, // Fallback nếu không có tên
                    roleId: user.role_id,
                    roleName: user.roleName,
                    mustChangePassword: user.must_change_password
                }
            });

        } catch (error) {
            console.error("Login error details:", error);
            res.status(500).json({ message: 'Lỗi server khi đăng nhập.' });
        }
    },

    // ============================================================
    // 2. ĐĂNG KÝ (Dành cho Khách hàng mới)
    // ============================================================
    register: async (req, res) => {
        const { fullName, phone, password } = req.body;

        if (!fullName || !phone || !password) {
            return res.status(400).json({ message: 'Vui lòng điền đầy đủ thông tin: Họ tên, SĐT, Mật khẩu.' });
        }

        // Bắt đầu Transaction (để đảm bảo insert cả 2 bảng thành công)
        const connection = await db.getConnection();
        await connection.beginTransaction();

        try {
            // 1. Kiểm tra trùng lặp (SĐT đã dùng làm user_id chưa)
            const [existing] = await connection.query("SELECT user_id FROM users WHERE username = ?", [phone]);
            if (existing.length > 0) {
                await connection.release();
                return res.status(409).json({ message: 'Số điện thoại này đã được đăng ký.' });
            }

            // 2. Insert vào bảng USERS (Tài khoản)
            // Role ID 2 = Customer
            // user_id = phone, username = phone
            const insertUserQuery = `
                INSERT INTO users 
                (user_id, username, password_hash, role_id, status, must_change_password)
                VALUES (?, ?, ?, 2, 'Active', FALSE)
            `;
            await connection.query(insertUserQuery, [phone, phone, password]);

            // 3. Insert vào bảng CUSTOMERS (Thông tin cá nhân)
            const insertCustomerQuery = `
                INSERT INTO customers 
                (customer_id, user_id, full_name, phone)
                VALUES (?, ?, ?, ?)
            `;
            // Tạo mã KH tự động: CUS_ + SĐT
            const newCustomerId = `CUS_${phone}`; 
            await connection.query(insertCustomerQuery, [newCustomerId, phone, fullName, phone]);

            // Commit Transaction
            await connection.commit();
            connection.release();

            res.status(201).json({ message: 'Đăng ký thành công! Vui lòng đăng nhập.' });

        } catch (error) {
            // Rollback nếu lỗi
            await connection.rollback();
            connection.release();
            console.error("Register error:", error);
            res.status(500).json({ message: 'Lỗi hệ thống khi đăng ký.', details: error.message });
        }
    },

    // ============================================================
    // 3. CÁC HÀM PHỤ (Đổi mật khẩu)
    // ============================================================
    
    changePassword: async (req, res) => {
        // Logic đổi mật khẩu
        res.status(200).json({ message: 'Chức năng đổi mật khẩu thành công' });
    },

    resetPassword: async (req, res) => {
        const { userId, newPassword } = req.body;
        try {
            await userModel.updatePassword(userId, newPassword, false);
            res.status(200).json({ message: 'Đặt lại mật khẩu thành công' });
        } catch (error) {
            res.status(500).json({ message: 'Lỗi khi đặt lại mật khẩu' });
        }
    }
};

module.exports = authController;