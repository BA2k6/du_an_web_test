// /server/controllers/authController.js
const userModel = require('../models/userModel');
const jwt = require('jsonwebtoken'); 
// const bcrypt = require('bcryptjs'); // Cần dùng thư viện hash trong thực tế

const JWT_SECRET = process.env.JWT_SECRET || 'default_secret'; 

const authController = {
    login: async (req, res) => {
        const { username, password } = req.body;
        try {
            const user = await userModel.findByUsername(username);
            if (!user) return res.status(401).json({ message: 'Sai tài khoản hoặc mật khẩu.' });
            
            // QUAN TRỌNG: MOCK so sánh plaintext vì DB hiện lưu plaintext.
            const passwordMatch = user.password_hash === password; 
            // THỰC TẾ: const passwordMatch = await bcrypt.compare(password, user.password_hash);
            
            if (!passwordMatch) return res.status(401).json({ message: 'Sai tài khoản hoặc mật khẩu.' });

            const token = jwt.sign({ userId: user.user_id, roleId: user.role_id }, JWT_SECRET, { expiresIn: '1d' });
            
            res.status(200).json({
                message: 'Đăng nhập thành công',
                token,
                user: {
                    userId: user.user_id,
                    fullName: user.full_name,
                    roleId: user.role_id,
                    roleName: user.roleName, // Lấy từ JOIN trong Model
                    mustChangePassword: user.must_change_password
                }
            });
        } catch (error) {
            console.error("Login error:", error);
            res.status(500).json({ message: 'Lỗi máy chủ nội bộ.' });
        }
    },
    
    changePassword: async (req, res) => {
        const { userId, oldPassword, newPassword } = req.body; 
        try {
            // 1. Giả định tìm user và kiểm tra mật khẩu cũ đã được thực hiện
            // ... (Logic kiểm tra password cũ)
            
            // 2. Hash và cập nhật
            const newPasswordHash = newPassword; // Mock: lưu plaintext
            // const newPasswordHash = await bcrypt.hash(newPassword, 10); // THỰC TẾ
            await userModel.updatePassword(userId, newPasswordHash, false);

            res.status(200).json({ message: 'Mật khẩu đã được cập nhật thành công.' });

        } catch (error) {
            console.error("Change password error:", error);
            res.status(500).json({ message: 'Lỗi máy chủ nội bộ.' });
        }
    },
    
    resetPassword: async (req, res) => {
        const { userId, newPassword } = req.body; 
        try {
            const newPasswordHash = newPassword; // Mock: lưu plaintext
            // const newPasswordHash = await bcrypt.hash(newPassword, 10); // THỰC TẾ

            // Cập nhật và tắt cờ buộc đổi
            await userModel.updatePassword(userId, newPasswordHash, false); 

            res.status(200).json({ message: 'Mật khẩu đã được đặt lại thành công.' });

        } catch (error) {
            console.error("Reset password error:", error);
            res.status(500).json({ message: 'Lỗi máy chủ nội bộ.' });
        }
    },
};
module.exports = authController;