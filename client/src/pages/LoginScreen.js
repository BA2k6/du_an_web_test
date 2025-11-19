// /client/src/pages/LoginScreen.js

import React, { useState } from 'react';
import { Zap, Eye, EyeOff } from 'lucide-react'; // <-- IMPORT ICONS
// Import API thật để giao tiếp với Server
import { login } from '../services/api'; 
// Import các hằng số và routes
import { roleToRoutes, ROLES } from '../utils/constants';
import ShopLogo from '../assets/shop-logo-konen.png'; 

// 1. Trang Đăng nhập (/login)
export const LoginScreen = ({ setPath, setUser, setIsLoggedIn }) => {
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');
    const [isLoading, setIsLoading] = useState(false);
    
    // THÊM STATE MỚI: Theo dõi trạng thái hiển thị mật khẩu
    const [showPassword, setShowPassword] = useState(false); 
    
  
    const handleLogin = async (e) => { 
        e.preventDefault();
        setError('');
        setIsLoading(true);

        try {
            // ... (Logic gọi API login giữ nguyên) ...
            const data = await login(username, password); 
            const user = data.user;
            
            // 1. Lưu Token và thông tin cơ bản
            localStorage.setItem('jwt_token', data.token);
            localStorage.setItem('user_role_name', user.roleName);
            localStorage.setItem('user_id', user.userId);
            localStorage.setItem('user_name', user.fullName);

            // 2. Cập nhật trạng thái ứng dụng
            const fullUser = { 
                ...user, 
                roleName: user.roleName, 
                must_change_password: user.mustChangePassword
            };
            setUser(fullUser);
            setIsLoggedIn(true);

            // 3. Chuyển hướng
            if (user.mustChangePassword) {
                setPath('/reset-password'); 
            } else if (user.roleName === ROLES.OWNER.name) {
                setPath('/dashboard');
            } else {
                const defaultPath = roleToRoutes[user.roleName]?.[0]?.path || '/products';
                setPath(defaultPath);
            }

        } catch (err) {
            setError(err.message || 'Lỗi đăng nhập không xác định.');
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div className="min-h-screen flex items-center justify-center bg-gray-100 p-4">
            <div className="w-full max-w-md bg-white rounded-xl shadow-2xl p-8 transform transition-all duration-300">
                <div className="text-center mb-8">
                    <img 
                        src={ShopLogo} 
                        alt="Store Management Logo" 
                        className="w-32 h-32 mx-auto mb-4" 
                    />
                    
                </div>
                <form onSubmit={handleLogin}>
                    <div className="space-y-4">
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Tài khoản</label>
                            <input
                                type="text"
                                value={username}
                                onChange={(e) => setUsername(e.target.value)}
                                placeholder="Nhập tên đăng nhập"
                                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-blue-500 focus:border-blue-500 transition duration-150"
                                required
                            />
                        </div>
                        
                        
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Mật khẩu</label>
                            <div className="relative">
                                <input
                                   
                                    type={showPassword ? "text" : "password"} 
                                    value={password}
                                    onChange={(e) => setPassword(e.target.value)}
                                    placeholder="Nhập mật khẩu"
                                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-blue-500 focus:border-blue-500 transition duration-150 pr-10" // Thêm pr-10 để chừa chỗ cho icon
                                    required
                                />
                                
                                <button
                                    type="button"
                                    onClick={() => setShowPassword(!showPassword)} // Thay đổi state
                                    className="absolute inset-y-0 right-0 flex items-center px-3 text-gray-600 hover:text-gray-800"
                                    title={showPassword ? "Ẩn mật khẩu" : "Hiện mật khẩu"}
                                >
                                    {showPassword ? (
                                        <EyeOff className="h-5 w-5" /> 
                                    ) : (
                                        <Eye className="h-5 w-5" />
                                    )}
                                </button>
                            </div>
                        </div>
                    </div>

                    {error && (
                        <div className="mt-4 p-3 text-sm text-red-700 bg-red-100 rounded-lg border border-red-300">
                            {error}
                        </div>
                    )}

                    <button
                        type="submit"
                        disabled={isLoading}
                        className={`w-full mt-6 py-2 px-4 border border-transparent rounded-lg text-white font-semibold shadow-md transition duration-300 ease-in-out ${
                            isLoading ? 'bg-yellow-400 cursor-not-allowed' : 'bg-yellow-600 hover:bg-yellow-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-yellow-500'
                        }`}
                    >
                        {isLoading ? 'Đang đăng nhập...' : 'Đăng nhập'}
                    </button>
                </form>
            </div>
        </div>
    );
};