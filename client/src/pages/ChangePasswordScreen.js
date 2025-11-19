// C:\Users\Admin\Downloads\DUANWEB(1)\client\src\pages\ChangePasswordScreen.js

import React, { useState } from 'react';
import { Settings } from 'lucide-react';
import { updatePassword } from '../services/api'; // <-- Import API cập nhật mật khẩu
import { roleToRoutes } from '../utils/constants'; // <-- Dùng để chuyển hướng sau khi thành công

// Màn hình đổi mật khẩu chung (/change-password)
export const ChangePasswordScreen = ({ currentUser, setPath }) => {
    const [oldPassword, setOldPassword] = useState('');
    const [newPassword, setNewPassword] = useState('');
    const [confirmPassword, setConfirmPassword] = useState('');
    const [error, setError] = useState('');
    const [isSubmitting, setIsSubmitting] = useState(false);

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError('');

        if (newPassword.length < 6) {
            setError('Mật khẩu mới phải có ít nhất 6 ký tự.');
            return;
        }
        if (newPassword !== confirmPassword) {
            setError('Mật khẩu mới và xác nhận mật khẩu không khớp.');
            return;
        }

        setIsSubmitting(true);
        
        try {
            // --- GỌI API ĐỔI MẬT KHẨU ---
            // Backend sẽ chịu trách nhiệm: 
            // 1. Xác thực mật khẩu cũ (oldPassword).
            // 2. Hash và lưu mật khẩu mới.
            await updatePassword(currentUser.id, oldPassword, newPassword); 
            
            alert('Đổi mật khẩu thành công!');
            
            // Xóa mật khẩu cũ khỏi local storage để buộc đăng nhập lại
            localStorage.removeItem('jwt_token'); 
            
            // Chuyển hướng về trang mặc định của họ
            const defaultPath = roleToRoutes[currentUser.roleName]?.[0]?.path || '/products';
            setPath(defaultPath);

        } catch (err) {
            // Xử lý lỗi từ Server (Ví dụ: Mật khẩu cũ không chính xác)
            setError(err.message || 'Đổi mật khẩu thất bại. Vui lòng kiểm tra lại mật khẩu cũ.');
        } finally {
            setIsSubmitting(false);
        }
    };

    return (
        <div className="flex items-center justify-center p-4">
            <div className="w-full max-w-md bg-white rounded-xl shadow-2xl p-8">
                <div className="text-center mb-6">
                    <Settings className="w-10 h-10 text-indigo-500 mx-auto mb-3" />
                    <h2 className="text-2xl font-bold text-gray-900">Đổi Mật khẩu Tài khoản</h2>
                    <p className="text-sm text-gray-600 mt-2">Xin chào **{currentUser.fullName}**. Vui lòng nhập thông tin.</p>
                </div>
                <form onSubmit={handleSubmit} className="space-y-4">
                    <div>
                        <label className="block text-sm font-medium text-gray-700">Mật khẩu Cũ</label>
                        <input
                            type="password"
                            value={oldPassword}
                            onChange={(e) => setOldPassword(e.target.value)}
                            className="w-full px-4 py-2 border border-gray-300 rounded-lg"
                            required
                        />
                    </div>
                    <div>
                        <label className="block text-sm font-medium text-gray-700">Mật khẩu Mới</label>
                        <input
                            type="password"
                            value={newPassword}
                            onChange={(e) => setNewPassword(e.target.value)}
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
                            isSubmitting ? 'bg-indigo-400 cursor-not-allowed' : 'bg-indigo-600 hover:bg-indigo-700'
                        }`}
                    >
                        {isSubmitting ? 'Đang cập nhật...' : 'Cập nhật Mật khẩu'}
                    </button>
                </form>
            </div>
        </div>
    );
}