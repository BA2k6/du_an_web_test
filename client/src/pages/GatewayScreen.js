// /client/src/pages/GatewayScreen.js

import React from 'react';
import { LogIn, ShoppingBag, Sparkles } from 'lucide-react'; // Import icon
import ShopLogo from '../assets/shop-logo-konen.png'; // Import Logo

export const GatewayScreen = ({ setPath }) => {
    return (
        <div className="min-h-screen flex flex-col items-center justify-center bg-gradient-to-br from-indigo-600 via-purple-600 to-pink-500 text-white relative overflow-hidden">
            
            {/* Hình nền trang trí mờ (Optional) */}
            <div className="absolute top-0 left-0 w-full h-full overflow-hidden z-0 pointer-events-none">
                <div className="absolute top-10 left-10 w-72 h-72 bg-purple-400 rounded-full mix-blend-multiply filter blur-3xl opacity-20 animate-blob"></div>
                <div className="absolute top-10 right-10 w-72 h-72 bg-yellow-400 rounded-full mix-blend-multiply filter blur-3xl opacity-20 animate-blob animation-delay-2000"></div>
                <div className="absolute -bottom-32 left-20 w-72 h-72 bg-pink-400 rounded-full mix-blend-multiply filter blur-3xl opacity-20 animate-blob animation-delay-4000"></div>
            </div>

            {/* Nội dung chính */}
            <div className="text-center p-8 max-w-4xl z-10">
                
                {/* Logo & Header */}
                <div className="mb-8 flex flex-col items-center">
                    <img 
                        src={ShopLogo} 
                        alt="AuraStore Logo" 
                        className="w-40 h-40 mb-6 drop-shadow-2xl hover:scale-105 transition-transform duration-500"
                    />
                    <h1 className="text-5xl md:text-6xl font-extrabold mb-4 tracking-tight drop-shadow-lg">
                        Chào mừng đến với <span className="text-yellow-300">AuraStore</span>
                    </h1>
                    <p className="text-lg md:text-xl text-indigo-100 max-w-2xl mx-auto font-light">
                        Trải nghiệm mua sắm đẳng cấp và hệ thống quản lý tối ưu.
                    </p>
                </div>

                {/* Khu vực 2 Nút bấm */}
                <div className="flex flex-col sm:flex-row items-center justify-center gap-6 mt-10">
                    
                    {/* NÚT 1: KHÁM PHÁ CỬA HÀNG (Dành cho Khách hàng) */}
                    {/* Nút này nổi bật hơn (Màu trắng) */}
                    <button
                        onClick={() => alert("Tính năng Giao diện Khách hàng đang được phát triển!")} // Sau này setPath('/shop')
                        className="group relative inline-flex items-center justify-center px-8 py-4 text-lg font-bold text-indigo-700 bg-white rounded-full shadow-xl transition-all duration-300 hover:bg-indigo-50 hover:scale-105 hover:shadow-2xl focus:outline-none focus:ring-4 focus:ring-white/50 w-full sm:w-auto"
                    >
                        <ShoppingBag className="w-6 h-6 mr-2 text-pink-500 group-hover:rotate-12 transition-transform" />
                        Khám phá Cửa hàng
                    </button>

                    {/* NÚT 2: ĐĂNG NHẬP (Dành cho Nhân viên/Quản lý) */}
                    {/* Nút này dạng trong suốt/viền (Glassmorphism) */}
                    <button
                        onClick={() => setPath('/login')} // Chuyển đến trang Login
                        className="group relative inline-flex items-center justify-center px-8 py-4 text-lg font-bold text-white border-2 border-white/30 bg-white/10 backdrop-blur-sm rounded-full shadow-lg transition-all duration-300 hover:bg-white/20 hover:scale-105 hover:border-white/60 focus:outline-none focus:ring-4 focus:ring-white/30 w-full sm:w-auto"
                    >
                        <LogIn className="w-6 h-6 mr-2 group-hover:translate-x-1 transition-transform" />
                        Đăng nhập Quản lý
                    </button>

                </div>
            </div>

            {/* Footer */}
            <div className="absolute bottom-6 text-sm text-white/60">
                © 2025 AuraStore System
            </div>
        </div>
    );
};