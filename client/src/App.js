// /client/src/App.js (BẢN FIX LOGIC RENDER CHO CUSTOMER)

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
import  StockInScreen  from './pages/StockInScreen';
import { UsersScreen } from './pages/UsersScreen';
import { SalariesScreen } from './pages/SalariesScreen';
import { ChangePasswordScreen } from './pages/ChangePasswordScreen';
import { ResetPasswordScreen } from './pages/ResetPasswordScreen';
import { ShopScreen } from './pages/ShopScreen';
import { PublicShopScreen } from './pages/PublicShopScreen'; 

const getFullUserFromLocalStorage = (id, roleName) => {
    return {
        id: id,
        fullName: localStorage.getItem('user_name'),
        roleName: roleName,
        must_change_password: false, 
    };
};

// Component Chứa Nội dung chính (Dành cho Admin Panel)
const AppContent = ({ path, setPath, currentUser, userRoleName }) => {
    
    const isAuthorized = useMemo(() => {
        // Các trang công khai và cơ bản
        if (path === '/shop' || path === '/publicshop' || path === '/login' || path === '/' || path === '/change-password') return true;
        
        // Owner quyền cao nhất
        if (userRoleName === ROLES.OWNER.name) return true;

        // Kiểm tra quyền hạn
        const allowedRoutes = roleToRoutes[userRoleName];
        if (!allowedRoutes) return false; 

        const isAllowed = allowedRoutes.some(route => route.path === path);
        if (isAllowed) return true;

        return path === '/unauthorized'; 
    }, [path, userRoleName]);

    useEffect(() => {
        // Nếu là Customer nhưng lọt vào đây (AppContent của Admin), đẩy về Shop ngay
        if (userRoleName === 'Customer' && path !== '/shop' && path !== '/change-password') {
            setPath('/shop');
            return;
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
        case '/change-password': return <ChangePasswordScreen currentUser={currentUser} setPath={setPath} />;
        case '/reset-password': return <ResetPasswordScreen currentUser={currentUser} setPath={setPath} />;
        case '/unauthorized': return <UnauthorizedScreen setPath={setPath} />;
        default: return null;
    }
};


export default function App() {
    const [isLoggedIn, setIsLoggedIn] = useState(false);
    const [currentUser, setCurrentUser] = useState(null);
    const [userRoleName, setUserRoleName] = useState(null);
    const [path, setPath] = useState('/'); 
    const [isCheckingAuth, setIsCheckingAuth] = useState(true); // Trạng thái chờ kiểm tra session

    // Khôi phục trạng thái đăng nhập từ localStorage
    useEffect(() => {
        const roleName = localStorage.getItem('user_role_name');
        const id = localStorage.getItem('user_id'); 
        const token = localStorage.getItem('jwt_token');

        if (roleName && id && token) {
            const user = getFullUserFromLocalStorage(id, roleName);
            
            setIsLoggedIn(true);
            setUserRoleName(roleName);
            setCurrentUser(user);
            
            // Logic chuyển hướng khi F5
            if (path === '/' || path === '/login') {
                if (roleName === 'Customer') {
                    setPath('/shop');
                } else if (roleToRoutes[roleName]) {
                    setPath(roleToRoutes[roleName][0]?.path || '/products');
                }
            }
        } else {
            // Nếu chưa đăng nhập, chỉ cho phép vào các trang công khai
            if (path !== '/' && path !== '/publicshop' && path !== '/shop' && path !== '/login') {
                setPath('/');
            }
        }
        setIsCheckingAuth(false);
    }, []); 

    const handleLogout = () => {
        localStorage.clear();
        setIsLoggedIn(false);
        setUserRoleName(null);
        setCurrentUser(null);
        setPath('/'); 
    };

    const setUser = (user) => {
        setCurrentUser(user);
        setUserRoleName(user.roleName);
    };

    // --- LOGIC RENDER (QUAN TRỌNG) ---
    
    // 0. Đang kiểm tra session
    if (isCheckingAuth) return <div className="flex h-screen items-center justify-center">Đang tải...</div>;

    // 1. Trang Gateway
    if (path === '/') {
        return <GatewayScreen setPath={setPath} />; 
    }

    // 2. Trang Login
    if (path === '/login') {
        if (isLoggedIn) {
             const defaultPath = userRoleName === 'Customer' ? '/shop' : '/products';
             setPath(defaultPath);
             return null;
        }
        return <LoginScreen setPath={setPath} setUser={setUser} setIsLoggedIn={setIsLoggedIn} />;
    }

    // 3. Trang Shop (Dành cho Khách hàng & Khách vãng lai)
    // Nếu là Customer, LUÔN render ShopScreen (trừ khi đổi mật khẩu)
    if (path === '/shop' || (isLoggedIn && userRoleName === 'Customer' && path !== '/change-password')) {
        return (
            <ShopScreen 
                setPath={setPath} 
                isLoggedIn={isLoggedIn} 
                currentUser={currentUser} 
                onLogout={handleLogout} 
            />
        );
    }

    // 4. Trang Công khai khác
    if (path === '/publicshop') {
        return <PublicShopScreen setPath={setPath} />;
    }
    
    // 5. Chưa đăng nhập -> Về Gateway
    if (!isLoggedIn) {
        setPath('/');
        return null;
    }

    // 6. Đổi mật khẩu lần đầu
    if (currentUser && currentUser.must_change_password && path !== '/reset-password') {
         setPath('/reset-password');
         return <ResetPasswordScreen currentUser={currentUser} setPath={setPath} />;
    }

    // ==================================================================
    // 7. GIAO DIỆN ADMIN (Chỉ dành cho Nhân viên/Owner)
    // ==================================================================
    // Đến đây chắc chắn là Admin (vì Customer đã được return ở mục 3)
    return (
        <div className="flex min-h-screen bg-gray-100 font-sans">
            <Sidebar currentPath={path} setPath={setPath} userRoleName={userRoleName} />
            <div className="flex-1 md:ml-64 flex flex-col">
                <Navbar currentUser={currentUser} handleLogout={handleLogout} setPath={setPath} />
                <main className="flex-1 overflow-y-auto p-4">
                    <AppContent
                        path={path}
                        setPath={setPath}
                        currentUser={currentUser}
                        userRoleName={userRoleName}
                    />
                </main>
            </div>
        </div>
    );
}