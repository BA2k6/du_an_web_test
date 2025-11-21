// /client/src/App.js

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
import  StockInScreen from './pages/StockInScreen';
import { UsersScreen } from './pages/UsersScreen';
import { SalariesScreen } from './pages/SalariesScreen';
import { ChangePasswordScreen } from './pages/ChangePasswordScreen';
import { ResetPasswordScreen } from './pages/ResetPasswordScreen';
import { ShopScreen } from './pages/ShopScreen';

// Hàm giả lập lấy thông tin User từ LocalStorage
const getFullUserFromLocalStorage = (id, roleName) => {
    return {
        id: id,
        fullName: localStorage.getItem('user_name'),
        roleName: roleName,
        must_change_password: false, 
    };
};

// Component Chứa Nội dung chính 
const AppContent = ({ path, setPath, currentUser, userRoleName }) => {
    
    // Kiểm tra quyền truy cập (Authorization)
    const isAuthorized = useMemo(() => {
        // 1. Luôn cho phép các trang cơ bản
        if (path === '/login' || path === '/' || path === '/change-password') return true;

        // 2. OWNER CÓ QUYỀN TỐI THƯỢNG (FIX LỖI 403)
        // Nếu là Owner, cho phép truy cập mọi trang (trừ trang lỗi)
        if (userRoleName === ROLES.OWNER.name) return true;

        // 3. Kiểm tra danh sách quyền hạn
        const allowedRoutes = roleToRoutes[userRoleName];
        if (!allowedRoutes) return false; 

        // Tìm xem path hiện tại có trong danh sách cho phép không
        const isAllowed = allowedRoutes.some(route => route.path === path);
        if (isAllowed) return true;

        // Nếu đang ở trang lỗi thì cho phép hiển thị
        return path === '/unauthorized'; 
    }, [path, userRoleName]);

    // Effect: Chuyển hướng nếu không có quyền
    useEffect(() => {
        if (userRoleName && !isAuthorized && path !== '/unauthorized') {
            console.warn(`🚫 Chặn truy cập: Role ${userRoleName} vào ${path}`);
            setPath('/unauthorized');
        }
    }, [isAuthorized, userRoleName, path, setPath]);

    // Render trang tương ứng
    switch (path) {
        case '/dashboard': return <DashboardScreen />;
        case '/products': return <ProductsScreen userRoleName={userRoleName} />;
        case '/customers': return <CustomersScreen userRoleName={userRoleName} />;
        case '/orders': return <OrdersScreen currentUserId={currentUser?.id} userRoleName={userRoleName} />;
        case '/stockin': return <StockInScreen userRoleName={userRoleName} />;
        case '/users': return <UsersScreen currentUser={currentUser} />;
        case '/salaries': return <SalariesScreen userRoleName={userRoleName} />;
        case '/shop': return <ShopScreen />; // Trang mua sắm
        case '/change-password': return <ChangePasswordScreen currentUser={currentUser} setPath={setPath} />;
        case '/reset-password': return <ResetPasswordScreen currentUser={currentUser} setPath={setPath} />;
        case '/unauthorized': return <UnauthorizedScreen setPath={setPath} />;
        
        // Case mặc định: Chuyển hướng về trang chủ của Role đó
        default:
             // Tránh vòng lặp vô hạn bằng cách kiểm tra nếu path đã hợp lệ chưa
             const defaultPath = roleToRoutes[userRoleName]?.[0]?.path || '/products';
             if (path !== defaultPath && path !== '/unauthorized') {
                 setPath(defaultPath);
             }
             return null;
    }
};


export default function App() {
    const [isLoggedIn, setIsLoggedIn] = useState(false);
    const [currentUser, setCurrentUser] = useState(null);
    const [userRoleName, setUserRoleName] = useState(null);
    const [path, setPath] = useState('/'); 

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
            
            // Nếu đang ở trang gốc hoặc login, chuyển vào Dashboard
            if (path === '/' || path === '/login') {
                const defaultPath = roleToRoutes[roleName]?.[0]?.path || '/products';
                setPath(defaultPath);
            }
            return;
        }

        // Nếu chưa đăng nhập, giữ ở trang Gateway
        if (!isLoggedIn && path !== '/') {
            setPath('/');
        }
    }, [isLoggedIn]); // Chỉ chạy khi trạng thái login thay đổi

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

    // --- LOGIC RENDER ---

    if (path === '/') {
        return <GatewayScreen setPath={setPath} />; 
    }

    if (path === '/login') {
        if (isLoggedIn) {
             const defaultPath = roleToRoutes[userRoleName]?.[0]?.path || '/products';
             setPath(defaultPath);
             return null;
        }
        return <LoginScreen setPath={setPath} setUser={setUser} setIsLoggedIn={setIsLoggedIn} />;
    }
    
    if (!isLoggedIn) {
        setPath('/');
        return null;
    }

    if (currentUser && currentUser.must_change_password && path !== '/reset-password') {
         setPath('/reset-password');
         return <ResetPasswordScreen currentUser={currentUser} setPath={setPath} />;
    }

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