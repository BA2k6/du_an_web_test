// /client/src/services/api.js 

import axios from 'axios';

const api = axios.create({
    // Sử dụng Proxy đã cấu hình trong package.json
    baseURL: '/api', 
    headers: {
        'Content-Type': 'application/json',
    },
    // Chấp nhận status code 4xx để Frontend tự xử lý lỗi (catch) thay vì Axios tự động throw
    validateStatus: (status) => status >= 200 && status < 500, 
});

// INTERCEPTOR: Tự động đính kèm JWT Token vào Header 'Authorization: Bearer <token>'
api.interceptors.request.use((config) => {
    const token = localStorage.getItem('jwt_token');
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
}, (error) => {
    return Promise.reject(error);
});

// ##################################################################
// 1. AUTH API (Đăng nhập, Đổi mật khẩu)
// ##################################################################

// POST /api/auth/login
export const login = async (username, password) => {
    const response = await api.post('/auth/login', { username, password });
    if (response.status !== 200) {
        // Ném lỗi với thông báo từ Server (response.data)
        throw response.data || { message: 'Đăng nhập thất bại. Vui lòng kiểm tra Server.' };
    }
    return response.data;
};

// POST /api/auth/change-password
export const updatePassword = async (userId, oldPassword, newPassword) => {
    // Lưu ý: Backend cần kiểm tra oldPassword
    const response = await api.post('/auth/change-password', { userId, oldPassword, newPassword });
    if (response.status !== 200) {
        throw response.data || { message: 'Đổi mật khẩu thất bại.' };
    }
    return response.data;
};

// POST /api/auth/reset-password (Dùng cho lần đăng nhập đầu tiên)
export const resetPassword = async (userId, newPassword) => {
    const response = await api.post('/auth/reset-password', { userId, newPassword });
    if (response.status !== 200) {
        throw response.data || { message: 'Đặt lại mật khẩu thất bại.' };
    }
    return response.data;
};


// ##################################################################
// 2. DATA LISTING API (Lấy danh sách các bảng)
// ##################################################################

// GET /api/products
export const getProducts = async () => {
    const response = await api.get('/products');
    if (response.status !== 200) {
        throw response.data || { message: 'Lỗi khi tải sản phẩm.' };
    }
    return response.data;
};

// GET /api/customers
export const getCustomers = async () => {
    const response = await api.get('/customers');
    if (response.status !== 200) {
        throw response.data || { message: 'Lỗi khi tải khách hàng.' };
    }
    return response.data;
};

// GET /api/users
export const getUsers = async () => {
    const response = await api.get('/users');
    if (response.status !== 200) {
        throw response.data || { message: 'Lỗi khi tải danh sách nhân viên.' };
    }
    return response.data;
};

// GET /api/orders
export const getOrders = async () => {
    const response = await api.get('/orders');
    if (response.status !== 200) {
        throw response.data || { message: 'Lỗi khi tải đơn hàng.' };
    }
    return response.data;
};

// GET /api/salaries
export const getSalaries = async () => {
    const response = await api.get('/salaries');
    if (response.status !== 200) {
        throw response.data || { message: 'Lỗi khi tải bảng lương.' };
    }
    return response.data;
};

// GET /api/stockin
export const getStockInReceipts = async () => {
    const response = await api.get('/stockin');
    if (response.status !== 200) {
        throw response.data || { message: 'Lỗi khi tải phiếu nhập kho.' };
    }
    return response.data;
};
// GET /api/dashboard/summary

export const getMonthlySummaryData = async (year) => {
    // PHẢI TRUYỀN THAM SỐ year VÀO URL
    const response = await api.get(`/dashboard/summary?year=${year}`); 
    if (response.status !== 200) {
        throw response.data || { message: 'Lỗi khi tải dữ liệu tổng hợp Dashboard.' };
    }
    // Backend trả về mảng 12 tháng
    return response.data;
};

// GET /api/dashboard/current-stats
export const getDashboardCurrentStats = async () => {
    const response = await api.get('/dashboard/current-stats'); 
    if (response.status !== 200) {
        throw response.data || { message: 'Lỗi khi tải chỉ số thống kê tổng hợp.' };
    }
    // Backend trả về object Stats
    return response.data;
};

export default api;