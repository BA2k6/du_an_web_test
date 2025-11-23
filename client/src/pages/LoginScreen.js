import React, { useState } from 'react';
import { Eye, EyeOff, Facebook, UserPlus, LogIn, Phone, User, Lock } from 'lucide-react'; 
import { login, register } from '../services/api'; 
import { roleToRoutes, ROLES } from '../utils/constants';
import ShopLogo from '../assets/shop-logo-konen.png'; 

// --- FIX LỖI: Đưa InputField ra ngoài component chính để không bị mất focus ---
const InputField = ({ label, type, value, onChange, placeholder, icon: Icon, showToggle, onToggle, isShow }) => (
    <div className="mb-4">
        <label className="block text-sm font-medium text-gray-700 mb-1">{label}</label>
        <div className="relative">
            {Icon && <Icon className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-5 h-5" />}
            <input
                type={type}
                value={value}
                onChange={onChange}
                placeholder={placeholder}
                className={`w-full ${Icon ? 'pl-10' : 'pl-4'} ${showToggle ? 'pr-10' : 'pr-4'} py-2 border border-gray-300 rounded-lg focus:ring-yellow-500 focus:border-yellow-500 transition duration-150`}
                required
            />
            {showToggle && (
                <button
                    type="button"
                    onClick={onToggle}
                    className="absolute inset-y-0 right-0 flex items-center pr-3 text-gray-600 hover:text-gray-800 focus:outline-none"
                >
                    {isShow ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
                </button>
            )}
        </div>
    </div>
);

export const LoginScreen = ({ setPath, setUser, setIsLoggedIn }) => {
    // --- STATE CHUNG ---
    const [isRegistering, setIsRegistering] = useState(false);
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState('');

    // --- STATE ĐĂNG NHẬP ---
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [showPassword, setShowPassword] = useState(false); 

    // --- STATE ĐĂNG KÝ ---
    const [regFullName, setRegFullName] = useState('');
    const [regPhone, setRegPhone] = useState('');
    const [regPassword, setRegPassword] = useState('');
    const [regConfirmPassword, setRegConfirmPassword] = useState('');
    
    // State hiển thị mật khẩu
    const [showRegPassword, setShowRegPassword] = useState(false);
    const [showRegConfirmPassword, setShowRegConfirmPassword] = useState(false); // Thêm state cho ô xác nhận

    // ==========================================
    // XỬ LÝ ĐĂNG NHẬP
    // ==========================================
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
            } else if (user.roleName === 'Customer' || user.roleName === ROLES.CUSTOMER.name) { 
                setPath('/shop');
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

    // ==========================================
    // XỬ LÝ ĐĂNG KÝ
    // ==========================================
    const handleRegister = async (e) => {
        e.preventDefault();
        setError('');

        if (!regFullName.trim() || !regPhone.trim() || !regPassword.trim()) {
            return setError('Vui lòng điền đầy đủ thông tin.');
        }
        if (regPassword.length < 6) {
            return setError('Mật khẩu phải có ít nhất 6 ký tự.');
        }
        if (regPassword !== regConfirmPassword) {
            return setError('Mật khẩu xác nhận không khớp.');
        }

        setIsLoading(true);

        try {
            await register(regFullName, regPhone, regPassword);
            
            alert('Đăng ký thành công! Vui lòng đăng nhập bằng số điện thoại vừa tạo.');
            
            setIsRegistering(false);
            setUsername(regPhone); 
            setPassword('');
            setRegFullName('');
            setRegPhone('');
            setRegPassword('');
            setRegConfirmPassword('');
            setShowRegPassword(false);
            setShowRegConfirmPassword(false);

        } catch (err) {
            setError(err.message || 'Đăng ký thất bại. Số điện thoại có thể đã tồn tại.');
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

    return (
        <div className="min-h-screen flex items-center justify-center bg-gray-100 p-4">
            <div className="w-full max-w-md bg-white rounded-xl shadow-2xl p-8 transform transition-all duration-300">
                <div className="text-center mb-6">
                    <img 
                        src={ShopLogo} 
                        alt="Store Logo" 
                        className="w-24 h-24 mx-auto mb-2 object-contain" 
                    />
                    <h2 className="text-2xl font-bold text-gray-800">
                        {isRegistering ? 'Đăng Ký Thành Viên' : 'Đăng Nhập'}
                    </h2>
                    <p className="text-sm text-gray-500">
                        {isRegistering ? 'Tạo tài khoản để mua sắm ngay' : 'Chào mừng bạn quay trở lại!'}
                    </p>
                </div>
                
                {isRegistering ? (
                    // ================= FORM ĐĂNG KÝ =================
                    <form onSubmit={handleRegister}>
                        <InputField 
                            label="Họ và Tên" 
                            type="text" 
                            value={regFullName} 
                            onChange={(e) => setRegFullName(e.target.value)} 
                            placeholder="Ví dụ: Nguyễn Văn A"
                            icon={User}
                        />

                        <InputField 
                            label="Số điện thoại (Dùng để đăng nhập)" 
                            type="text" 
                            value={regPhone} 
                            onChange={(e) => setRegPhone(e.target.value)} 
                            placeholder="Nhập số điện thoại"
                            icon={Phone}
                        />

                        <InputField 
                            label="Mật khẩu" 
                            type={showRegPassword ? "text" : "password"} 
                            value={regPassword} 
                            onChange={(e) => setRegPassword(e.target.value)} 
                            placeholder="Mật khẩu (tối thiểu 6 ký tự)"
                            icon={Lock}
                            showToggle={true}
                            onToggle={() => setShowRegPassword(!showRegPassword)}
                            isShow={showRegPassword}
                        />

                        <InputField 
                            label="Xác nhận mật khẩu" 
                            type={showRegConfirmPassword ? "text" : "password"} 
                            value={regConfirmPassword} 
                            onChange={(e) => setRegConfirmPassword(e.target.value)} 
                            placeholder="Nhập lại mật khẩu"
                            icon={Lock}
                            showToggle={true}
                            onToggle={() => setShowRegConfirmPassword(!showRegConfirmPassword)}
                            isShow={showRegConfirmPassword}
                        />

                        {error && (
                            <div className="mb-4 p-3 text-sm text-red-700 bg-red-100 rounded-lg border border-red-300">
                                {error}
                            </div>
                        )}

                        <button
                            type="submit"
                            disabled={isLoading}
                            className={`w-full py-2 px-4 rounded-lg text-white font-semibold shadow-md transition duration-300 ${
                                isLoading ? 'bg-gray-400 cursor-not-allowed' : 'bg-green-600 hover:bg-green-700'
                            }`}
                        >
                            {isLoading ? 'Đang tạo tài khoản...' : 'Đăng Ký Ngay'}
                        </button>

                        <div className="mt-4 text-center">
                            <button 
                                type="button"
                                onClick={() => { setIsRegistering(false); setError(''); }}
                                className="text-sm text-indigo-600 hover:underline flex items-center justify-center w-full focus:outline-none"
                            >
                                <LogIn className="w-4 h-4 mr-1" /> Quay lại Đăng nhập
                            </button>
                        </div>
                    </form>
                ) : (
                    // ================= FORM ĐĂNG NHẬP =================
                    <form onSubmit={handleLogin}>
                        <InputField 
                            label="Tài khoản / SĐT" 
                            type="text" 
                            value={username} 
                            onChange={(e) => setUsername(e.target.value)} 
                            placeholder="Nhập SĐT hoặc tên đăng nhập"
                            icon={User}
                        />

                        <InputField 
                            label="Mật khẩu" 
                            type={showPassword ? "text" : "password"} 
                            value={password} 
                            onChange={(e) => setPassword(e.target.value)} 
                            placeholder="Nhập mật khẩu"
                            icon={Lock}
                            showToggle={true}
                            onToggle={() => setShowPassword(!showPassword)}
                            isShow={showPassword}
                        />

                        {error && (
                            <div className="mb-4 p-3 text-sm text-red-700 bg-red-100 rounded-lg border border-red-300">
                                {error}
                            </div>
                        )}

                        <button
                            type="submit"
                            disabled={isLoading}
                            className={`w-full py-2 px-4 rounded-lg text-white font-semibold shadow-md transition duration-300 ${
                                isLoading ? 'bg-yellow-400 cursor-not-allowed' : 'bg-yellow-600 hover:bg-yellow-700'
                            }`}
                        >
                            {isLoading ? 'Đang đăng nhập...' : 'Đăng Nhập'}
                        </button>

                        {/* Social Login */}
                        <div className="mt-6">
                            <div className="relative flex justify-center text-sm">
                                <span className="px-2 bg-white text-gray-500">Hoặc tiếp tục với</span>
                            </div>
                            <div className="mt-4 grid grid-cols-2 gap-3">
                                <button type="button" onClick={handleGoogleLogin} className="w-full inline-flex justify-center items-center py-2 px-4 border border-gray-300 rounded-lg bg-white text-sm font-medium text-gray-500 hover:bg-gray-50 focus:outline-none">
                                    <svg className="h-5 w-5 mr-2" viewBox="0 0 24 24"><path d="M12.0003 20.45c-4.6667 0-8.45-3.7833-8.45-8.45 0-4.6667 3.7833-8.45 8.45-8.45 2.2833 0 4.35 0.8333 5.9667 2.35l-2.3833 2.3833c-0.9333-0.9-2.1667-1.45-3.5833-1.45-2.85 0-5.1667 2.3167-5.1667 5.1667s2.3167 5.1667 5.1667 5.1667c2.6167 0 4.4333-1.8833 4.5833-4.4833h-4.5833v-3.2667h7.9167c0.0833 0.5 0.1167 1.0333 0.1167 1.6 0 4.8833-3.5167 8.3833-8.3833 8.3833z" fill="#EA4335" /></svg>
                                    Google
                                </button>
                                <button type="button" onClick={handleFacebookLogin} className="w-full inline-flex justify-center items-center py-2 px-4 border border-gray-300 rounded-lg bg-white text-sm font-medium text-gray-500 hover:bg-gray-50 focus:outline-none">
                                    <Facebook className="h-5 w-5 mr-2 text-blue-600" />
                                    Facebook
                                </button>
                            </div>
                        </div>

                        {/* Switch to Register */}
                        <div className="mt-6 text-center">
                            <p className="text-sm text-gray-600">
                                Chưa có tài khoản?{' '}
                                <button 
                                    type="button"
                                    onClick={() => { setIsRegistering(true); setError(''); }}
                                    className="font-medium text-yellow-600 hover:text-yellow-500 hover:underline transition duration-150 inline-flex items-center focus:outline-none"
                                >
                                    <UserPlus className="w-4 h-4 mr-1" /> Đăng ký ngay
                                </button>
                            </p>
                        </div>
                    </form>
                )}
            </div>
        </div>
    );
};