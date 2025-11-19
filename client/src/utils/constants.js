// /client/src/utils/constants.js

import {
    Home, UserCheck, Package, Users, ShoppingCart, Truck, DollarSign as Dollar, Globe, Store
} from 'lucide-react';

export const ROLES = {
    OWNER: { id: 1, name: 'Owner', prefix: 'OWNER', description: 'Quản lý toàn bộ hệ thống' },
    WAREHOUSE: { id: 3, name: 'Warehouse', prefix: 'WH', description: 'Quản lý nhập xuất, tồn kho' },
    SALES: { id: 4, name: 'Sales', prefix: 'SALES', description: 'Nhân viên bán hàng trực tiếp' },
    ONLINE_SALES: { id: 5, name: 'Online Sales', prefix: 'OS', description: 'Nhân viên xử lý đơn hàng online' },
    SHIPPER: { id: 6, name: 'Shipper', prefix: 'SHIP', description: 'Nhân viên giao hàng' },
};

export const roleToRoutes = {
    [ROLES.OWNER.name]: [
        { path: '/dashboard', name: 'Dashboard', icon: Home },
        { path: '/users', name: 'Nhân viên & Phân quyền', icon: UserCheck },
        { path: '/products', name: 'Sản phẩm', icon: Package },
        { path: '/customers', name: 'Khách hàng', icon: Users },
        { path: '/orders', name: 'Bán hàng & Đơn hàng', icon: ShoppingCart },
        { path: '/stockin', name: 'Nhập kho', icon: Truck },
        { path: '/salaries', name: 'Quản lý Lương', icon: Dollar },
    ],
    [ROLES.SALES.name]: [
        { path: '/orders', name: 'Đơn hàng Trực tiếp', icon: Store },
        { path: '/products', name: 'Sản phẩm', icon: Package },
        { path: '/customers', name: 'Khách hàng', icon: Users },
    ],
    [ROLES.WAREHOUSE.name]: [
        { path: '/products', name: 'Sản phẩm', icon: Package },
        { path: '/stockin', name: 'Nhập kho', icon: Truck },
    ],
    [ROLES.SHIPPER.name]: [
        { path: '/orders', name: 'Đơn hàng cần giao', icon: ShoppingCart },
        { path: '/customers', name: 'Khách hàng', icon: Users },
    ],
    [ROLES.ONLINE_SALES.name]: [
        { path: '/orders', name: 'Đơn hàng Online', icon: Globe },
        { path: '/products', name: 'Sản phẩm', icon: Package },
        { path: '/customers', name: 'Khách hàng', icon: Users },
    ],
};