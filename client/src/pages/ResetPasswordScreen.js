// C:\Users\Admin\Downloads\DUANWEB(1)\client\src\pages\ResetPasswordScreen.js

import React, { useState } from 'react';
import { ShieldOff } from 'lucide-react';
import { resetPassword } from '../services/api'; // <-- Import API đặt lại mật khẩu
import { roleToRoutes } from '../utils/constants'; // <-- Dùng để chuyển hướng sau khi thành công

// Màn hình bắt buộc đổi mật khẩu lần đầu (/reset-password)
export const ResetPasswordScreen = ({ currentUser, setPath }) => {
    const [password, setPassword] = useState('');
    const [confirmPassword, setConfirmPassword] = useState('');
    const [error, setError] = useState('');
    const [isSubmitting, setIsSubmitting] = useState(false);

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError('');

        if (password.length < 6) {
            setError('Mật khẩu phải có ít nhất 6 ký tự.');
            return;
        }
        if (password !== confirmPassword) {
            setError('Mật khẩu mới và xác nhận mật khẩu không khớp.');
            return;
        }

        setIsSubmitting(true);
        
        try {
            // --- GỌI API RESET MẬT KHẨU LẦN ĐẦU ---
            // Backend sẽ hash mật khẩu mới và đặt cờ must_change_password = FALSE
            await resetPassword(currentUser.id, password); 
            
            alert('Đặt mật khẩu thành công!');
            
            // Cập nhật trạng thái người dùng cục bộ để cho phép truy cập
            currentUser.must_change_password = false;
            
            // Chuyển hướng đến trang mặc định của họ
            const defaultPath = roleToRoutes[currentUser.roleName]?.[0]?.path || '/products';
            setPath(defaultPath);

        } catch (err) {
            setError(err.message || 'Lỗi hệ thống trong quá trình đổi mật khẩu.');
        } finally {
            setIsSubmitting(false);
        }
    };

    return (
        <div className="min-h-screen flex items-center justify-center bg-gray-100 p-4">
            <div className="w-full max-w-md bg-white rounded-xl shadow-2xl p-8">
                <div className="text-center mb-6">
                    <ShieldOff className="w-10 h-10 text-orange-500 mx-auto mb-3" />
                    <h2 className="text-2xl font-bold text-gray-900">Yêu cầu Đổi Mật khẩu Lần đầu</h2>
                    <p className="text-sm text-gray-600 mt-2">Chào **{currentUser.fullName}**. Vui lòng đặt mật khẩu mới để bảo mật tài khoản.</p>
                </div>
                <form onSubmit={handleSubmit} className="space-y-4">
                    <div>
                        <label className="block text-sm font-medium text-gray-700">Mật khẩu Mới</label>
                        <input
                            type="password"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            className="w-full px-4 py-2 border border-gray-300 rounded-lg"
                            required
                        />
                    </div>
                    <div>
                        <label className="block text-sm font-medium text-gray-700">Xác nhận Mật khẩu Mới</label>
                        <input
                            type="password"
                            value={confirmPassword}
                            onChange={(e) => setConfirmPassword(e.target.value)}
                            className="w-full px-4 py-2 border border-gray-300 rounded-lg"
                            required
                        />
                    </div>
                    {error && (
                        <div className="p-3 text-sm text-red-700 bg-red-100 rounded-lg">{error}</div>
                    )}
                    <button
                        type="submit"
                        disabled={isSubmitting}
                        className={`w-full py-2 px-4 rounded-lg text-white font-semibold transition duration-300 ${
                            isSubmitting ? 'bg-orange-400 cursor-not-allowed' : 'bg-orange-600 hover:bg-orange-700'
                        }`}
                    >
                        {isSubmitting ? 'Đang cập nhật...' : 'Đổi Mật khẩu & Tiếp tục'}
                    </button>
                </form>
            </div>
        </div>
    );
}