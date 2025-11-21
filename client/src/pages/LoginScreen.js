// /client/src/pages/LoginScreen.js (CẬP NHẬT THÊM NÚT ĐĂNG KÝ)

import React, { useState } from 'react';
import { Zap, Eye, EyeOff, Facebook } from 'lucide-react'; 
import { login } from '../services/api'; 
import { roleToRoutes, ROLES } from '../utils/constants';
import ShopLogo from '../assets/shop-logo-konen.png'; 

export const LoginScreen = ({ setPath, setUser, setIsLoggedIn }) => {
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');
    const [isLoading, setIsLoading] = useState(false);
    const [showPassword, setShowPassword] = useState(false); 

    const handleLogin = async (e) => { 
        e.preventDefault();
        setError('');
        setIsLoading(true);

        try {
            const data = await login(username, password); 
            const user = data.user;
            
            localStorage.setItem('jwt_token', data.token);
            localStorage.setItem('user_role_name', user.roleName);
            localStorage.setItem('user_id', user.userId);
            localStorage.setItem('user_name', user.fullName);

            const fullUser = { 
                ...user, 
                roleName: user.roleName, 
                must_change_password: user.mustChangePassword
            };
            setUser(fullUser);
            setIsLoggedIn(true);

            if (user.mustChangePassword) {
                setPath('/reset-password'); 
            } else if (user.roleName === 'Customer') {
                // KHÁCH HÀNG -> Vào trang Shop
                setPath('/shop');
            } else if (user.roleName === 'Owner') {
                // ADMIN -> Vào Dashboard
                setPath('/dashboard');
            } else {
                // NHÂN VIÊN KHÁC -> Vào trang sản phẩm quản lý
                setPath('/products');
            }


        } catch (err) {
            setError(err.message || 'Lỗi đăng nhập không xác định.');
        } finally {
            setIsLoading(false);
        }
    };

    const handleGoogleLogin = () => {
        alert("Chức năng Đăng nhập Google đang được phát triển!");
    };

    const handleFacebookLogin = () => {
        alert("Chức năng Đăng nhập Facebook đang được phát triển!");
    };

    // Hàm xử lý khi bấm Đăng ký
    const handleRegister = () => {
        // Sau này bạn có thể setPath('/register') để chuyển sang màn hình đăng ký
        alert("Chức năng Đăng ký tài khoản mới đang được phát triển!");
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
                    {/* <h2 className="text-xl font-extrabold text-gray-900">Hệ thống Quản lý Cửa hàng</h2> */}
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
                                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-blue-500 focus:border-blue-500 transition duration-150 pr-10"
                                    required
                                />
                                <button
                                    type="button"
                                    onClick={() => setShowPassword(!showPassword)}
                                    className="absolute inset-y-0 right-0 flex items-center pr-3 text-gray-600 hover:text-gray-800"
                                    title={showPassword ? "Ẩn" : "Hiện"}
                                >
                                    {showPassword ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
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

                {/* --- PHẦN ĐĂNG NHẬP MẠNG XÃ HỘI --- */}
                <div className="mt-6">
                    <div className="relative">
                        <div className="absolute inset-0 flex items-center">
                            <div className="w-full border-t border-gray-300"></div>
                        </div>
                        <div className="relative flex justify-center text-sm">
                            <span className="px-2 bg-white text-gray-500">Hoặc đăng nhập với</span>
                        </div>
                    </div>

                    <div className="mt-6 grid grid-cols-2 gap-3">
                        <button
                            type="button"
                            onClick={handleGoogleLogin}
                            className="w-full inline-flex justify-center items-center py-2 px-4 border border-gray-300 rounded-lg shadow-sm bg-white text-sm font-medium text-gray-500 hover:bg-gray-50 transition duration-150"
                        >
                            <svg className="h-5 w-5 mr-2" aria-hidden="true" viewBox="0 0 24 24">
                                <path d="M12.0003 20.45c-4.6667 0-8.45-3.7833-8.45-8.45 0-4.6667 3.7833-8.45 8.45-8.45 2.2833 0 4.35 0.8333 5.9667 2.35l-2.3833 2.3833c-0.9333-0.9-2.1667-1.45-3.5833-1.45-2.85 0-5.1667 2.3167-5.1667 5.1667s2.3167 5.1667 5.1667 5.1667c2.6167 0 4.4333-1.8833 4.5833-4.4833h-4.5833v-3.2667h7.9167c0.0833 0.5 0.1167 1.0333 0.1167 1.6 0 4.8833-3.5167 8.3833-8.3833 8.3833z" fill="#EA4335" />
                            </svg>
                            Google
                        </button>

                        <button
                            type="button"
                            onClick={handleFacebookLogin}
                            className="w-full inline-flex justify-center items-center py-2 px-4 border border-gray-300 rounded-lg shadow-sm bg-white text-sm font-medium text-gray-500 hover:bg-gray-50 transition duration-150"
                        >
                            <Facebook className="h-5 w-5 mr-2 text-blue-600" />
                            Facebook
                        </button>
                    </div>
                </div>

                {/* --- PHẦN NÚT ĐĂNG KÝ (MỚI) --- */}
                <div className="mt-6 text-center">
                    <p className="text-sm text-gray-600">
                        Chưa có tài khoản?{' '}
                        <button 
                            onClick={handleRegister}
                            className="font-medium text-yellow-600 hover:text-yellow-500 hover:underline focus:outline-none transition duration-150"
                        >
                            Đăng ký ngay
                        </button>
                    </p>
                </div>
                
            </div>
        </div>
    );
};