import React, { useState, useEffect, useMemo } from 'react';

// Import các màn hình và component
import { ROLES, roleToRoutes } from './utils/constants';
import { Sidebar } from './components/Sidebar';
import { Navbar } from './components/Navbar';
import { UnauthorizedScreen } from './components/UnauthorizedScreen';

import { LoginScreen } from './pages/LoginScreen'; 
import { GatewayScreen } from './pages/GatewayScreen'; 
import { DashboardScreen } from './pages/DashboardScreen';
import { ProductsScreen } from './pages/ProductsScreen';
import { CustomersScreen } from './pages/CustomersScreen';
import { OrdersScreen } from './pages/OrdersScreen';
import StockInScreen from './pages/StockInScreen';
import { UsersScreen } from './pages/UsersScreen';
import { SalariesScreen } from './pages/SalariesScreen';
import { ChangePasswordScreen } from './pages/ChangePasswordScreen';
import { ResetPasswordScreen } from './pages/ResetPasswordScreen';
import { ShopScreen } from './pages/ShopScreen';
import { PublicShopScreen } from './pages/PublicShopScreen'; 

// Component Chứa Nội dung chính (CHỈ CÒN CÁC TRANG CẦN MENU ADMIN)
const AppContent = ({ path, setPath, currentUser, userRoleName }) => {
    
    const isAuthorized = useMemo(() => {
        if (path === '/shop' || path === '/publicshop' || path === '/login' || path === '/' || path === '/change-password') return true;
        if (userRoleName === ROLES.OWNER.name) return true;
        
        const allowedRoutes = roleToRoutes[userRoleName];
        if (!allowedRoutes) return false; 
        
        const isAllowed = allowedRoutes.some(route => route.path === path);
        if (isAllowed) return true;
        
        return path === '/unauthorized'; 
    }, [path, userRoleName]);

    useEffect(() => {
        // Nếu là Customer thì chỉ cho ở Shop hoặc đổi mật khẩu
        if (userRoleName === 'Customer' && path !== '/shop' && path !== '/change-password') {
            setPath('/shop'); return;
        }
        if (userRoleName && !isAuthorized && path !== '/unauthorized') {
            setPath('/unauthorized');
        }
    }, [isAuthorized, userRoleName, path, setPath]);

    switch (path) {
        case '/dashboard': return <DashboardScreen />;
        case '/products': return <ProductsScreen userRoleName={userRoleName} />;
        case '/customers': return <CustomersScreen userRoleName={userRoleName} />;
        case '/orders': return <OrdersScreen currentUserId={currentUser?.id} userRoleName={userRoleName} />;
        case '/stockin': return <StockInScreen userRoleName={userRoleName} />;
        case '/users': return <UsersScreen currentUser={currentUser} />;
        case '/salaries': return <SalariesScreen userRoleName={userRoleName} />;
        
        case '/unauthorized': return <UnauthorizedScreen setPath={setPath} />;
        default: return null;
    }
};

export default function App() {
    const [isLoggedIn, setIsLoggedIn] = useState(false);
    const [currentUser, setCurrentUser] = useState(null);
    const [userRoleName, setUserRoleName] = useState(null);
    const [path, setPath] = useState('/'); 
    const [isCheckingAuth, setIsCheckingAuth] = useState(true);

    // --- LOGIC: TỰ ĐỘNG ĐĂNG XUẤT KHI CHẠY LẠI ---
    useEffect(() => {
        console.log("App Started: Cleaning session...");
        localStorage.clear(); 
        setIsLoggedIn(false);
        setUserRoleName(null);
        setCurrentUser(null);
        setPath('/'); 
        setIsCheckingAuth(false);
    }, []); 

    const handleLogout = () => {
        localStorage.clear();
        setIsLoggedIn(false);
        setUserRoleName(null);
        setCurrentUser(null);
        setPath('/login'); 
    };

    const setUser = (user) => {
        const normalizedUser = {
            ...user,
            id: user.userId || user.id, 
        };
        setCurrentUser(normalizedUser);
        setUserRoleName(normalizedUser.roleName);
        
        if(user.token) localStorage.setItem('jwt_token', user.token);
        localStorage.setItem('user_id', normalizedUser.id);
        localStorage.setItem('user_role_name', normalizedUser.roleName);
    };

    if (isCheckingAuth) return <div className="flex h-screen items-center justify-center">Đang tải hệ thống...</div>;

    // 1. Gateway
    if (path === '/') return <GatewayScreen setPath={setPath} />;

    // 2. Login
    if (path === '/login') {
        if (isLoggedIn) {
             const defaultPath = userRoleName === 'Customer' ? '/shop' : '/products';
             setPath(defaultPath); return null;
        }
        return <LoginScreen setPath={setPath} setUser={setUser} setIsLoggedIn={setIsLoggedIn} />;
    }

    // 3. Public Shop
    if (path === '/publicshop') return <PublicShopScreen setPath={setPath} />;

    // 4. Shop (SỬA LẠI ĐỂ CHO PHÉP KHÁCH VÃNG LAI)
    // Logic mới: Nếu path là /shop VÀ (Chưa đăng nhập HOẶC là Customer) thì cho vào
    if (path === '/shop') {
        if (!isLoggedIn || userRoleName === 'Customer') {
            return <ShopScreen setPath={setPath} isLoggedIn={isLoggedIn} currentUser={currentUser} onLogout={handleLogout} />;
        }
    }

    // 5. Kiểm tra đăng nhập (Chặn các trang còn lại nếu chưa login)
    if (!isLoggedIn) { setPath('/'); return null; }

    // 6. Reset Password
    if (currentUser && currentUser.mustChangePassword && path !== '/reset-password') {
         setPath('/reset-password');
         return <ResetPasswordScreen currentUser={currentUser} setPath={setPath} />;
    }
    
    // 7. Đổi mật khẩu chủ động (Full màn hình)
    if (path === '/change-password') {
        return <ChangePasswordScreen currentUser={currentUser} setPath={setPath} />;
    }
    
    // 8. Reset Password (Direct link)
    if (path === '/reset-password') {
        return <ResetPasswordScreen currentUser={currentUser} setPath={setPath} />;
    }

    // 9. GIAO DIỆN QUẢN TRỊ (CÓ MENU & HEADER)
    return (
        <div className="flex min-h-screen bg-gray-100 font-sans">
            <Sidebar currentPath={path} setPath={setPath} userRoleName={userRoleName} />
            <div className="flex-1 md:ml-64 flex flex-col">
                <Navbar currentUser={currentUser} handleLogout={handleLogout} setPath={setPath} />
                <main className="flex-1 overflow-y-auto p-4">
                    <AppContent path={path} setPath={setPath} currentUser={currentUser} userRoleName={userRoleName} />
                </main>
            </div>
        </div>
    );
}