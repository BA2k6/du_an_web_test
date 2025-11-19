// client/src/App.js
import React, { useState, useEffect, useMemo } from 'react';

// Imports từ các file đã tách
import { ROLES, roleToRoutes } from './utils/constants'; 
import { Sidebar } from './components/Sidebar';
import { Navbar } from './components/Navbar';
import { UnauthorizedScreen } from './components/UnauthorizedScreen';

import { LoginScreen } from './pages/LoginScreen';
// Import tất cả các màn hình
import { DashboardScreen } from './pages/DashboardScreen';
import { ProductsScreen } from './pages/ProductsScreen';
import { CustomersScreen } from './pages/CustomersScreen';
import { OrdersScreen } from './pages/OrdersScreen';
import { UsersScreen } from './pages/UsersScreen';
import { SalariesScreen } from './pages/SalariesScreen';
import { ChangePasswordScreen } from './pages/ChangePasswordScreen';
import { ResetPasswordScreen } from './pages/ResetPasswordScreen';
import StockInScreen from './pages/StockInScreen';



// Giả lập hàm lấy thông tin User từ ID (Server sẽ trả về)
const getFullUserFromLocalStorage = (id, roleName) => {
    // Trong môi trường thực, cần gọi API /api/user/:id để lấy đầy đủ thông tin
    // Ở đây, ta giả lập dữ liệu cơ bản từ LocalStorage
    return {
        id: id,
        fullName: localStorage.getItem('user_name'),
        roleName: roleName,
        // Giả định: nếu user_id là SALES1 thì must_change_password là TRUE (theo DB khởi tạo)
        must_change_password: id === 'SALES1' ? true : false, 
    };
};

const AppContent = ({ path, setPath, currentUser, userRoleName }) => {
    // --- KIỂM TRA BẮT BUỘC ĐỔI MẬT KHẨU LẦN ĐẦU ---
    if (currentUser && currentUser.must_change_password && path !== '/reset-password') {
        return <ResetPasswordScreen currentUser={currentUser} setPath={setPath} />;
    }
    // ... (logic chuyển hướng ResetPassword và Unauthorized) ...
    // ... (logic kiểm tra isAuthorized) ...

    switch (path) {
        case '/dashboard': return <DashboardScreen />;
        case '/products': return <ProductsScreen userRoleName={userRoleName} />;
        case '/customers': return <CustomersScreen userRoleName={userRoleName} />;
        case '/orders': {
            // Tính userRoleId từ userRoleName để truyền xuống màn hình Orders
            const roleObj = Object.values(ROLES).find(r => r.name === userRoleName);
            const roleId = roleObj ? roleObj.id : null;
            return <OrdersScreen currentUserId={currentUser?.id} userRoleId={roleId} />;
        }
        case '/users': return <UsersScreen currentUser={currentUser} />;
        case '/salaries': return <SalariesScreen userRoleName={userRoleName} />;
        case '/stockin': return <StockInScreen currentUserId={currentUser?.id} userRoleName={userRoleName} />;
        case '/reset-password': return <ResetPasswordScreen currentUser={currentUser} setPath={setPath} />;
        case '/change-password': return <ChangePasswordScreen currentUser={currentUser} setPath={setPath} />;
        case '/unauthorized': return <UnauthorizedScreen setPath={setPath} />;
        case '/login': return null; // Sẽ được xử lý ở App()
        default:
            const defaultPath = roleToRoutes[userRoleName]?.[0]?.path || '/unauthorized';
            if (path !== defaultPath) {
                 setPath(defaultPath);
            }
            return null;
    }
};


export default function App() {
    const [isLoggedIn, setIsLoggedIn] = useState(false);
    const [currentUser, setCurrentUser] = useState(null);
    const [userRoleName, setUserRoleName] = useState(null);
    const [path, setPath] = useState('/login');

    // Khôi phục trạng thái đăng nhập từ localStorage
    useEffect(() => {
        const roleName = localStorage.getItem('user_role_name');
        const id = localStorage.getItem('user_id'); 
        const token = localStorage.getItem('jwt_token');

        if (roleName && id && token) {
            // Lấy thông tin đầy đủ (giả lập)
            const user = getFullUserFromLocalStorage(id, roleName); 
            
            setIsLoggedIn(true);
            setUserRoleName(roleName);
            setCurrentUser(user);
            
            if (user.must_change_password) {
                setPath('/reset-password');
            } else {
                const defaultPath = roleToRoutes[roleName]?.[0]?.path || '/products';
                setPath(defaultPath);
            }
            return;
        }

        if (!isLoggedIn) {
            setPath('/login');
        }
    }, [isLoggedIn]); 

    const handleLogout = () => {
        localStorage.clear();
        setIsLoggedIn(false);
        setUserRoleName(null);
        setCurrentUser(null);
        setPath('/login');
    };

    const setUser = (user) => {
        setCurrentUser(user);
        setUserRoleName(user.roleName);
    };

    if (!isLoggedIn || path === '/login') {
        return <LoginScreen setPath={setPath} setUser={setUser} setIsLoggedIn={setIsLoggedIn} />;
    }
    
    if (currentUser && currentUser.must_change_password && path !== '/reset-password') {
        setPath('/reset-password');
        return <ResetPasswordScreen currentUser={currentUser} setPath={setPath} />;
    }

    // Render Dashboard Layout
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