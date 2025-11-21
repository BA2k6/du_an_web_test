// /client/src/pages/ShopScreen.js

import React, { useState, useEffect, useMemo } from 'react';
import { ShoppingCart, Search, Filter, Star } from 'lucide-react';
import { getProducts, getCategories } from '../services/api';
import { formatCurrency, normalizeSearchableValue } from '../utils/helpers';

export const ShopScreen = () => {
    const [products, setProducts] = useState([]);
    const [categories, setCategories] = useState([]);
    const [selectedCategory, setSelectedCategory] = useState('All');
    const [searchTerm, setSearchTerm] = useState('');
    const [cartCount, setCartCount] = useState(0); // Giả lập giỏ hàng
    const [isLoading, setIsLoading] = useState(true);

    // Load dữ liệu khi vào trang
    useEffect(() => {
        const fetchData = async () => {
            try {
                const [prodData, catData] = await Promise.all([
                    getProducts(),
                    getCategories().catch(() => []) // Nếu chưa có API categories thì trả về rỗng
                ]);
                setProducts(prodData);
                setCategories(catData);
            } catch (error) {
                console.error("Lỗi tải dữ liệu shop:", error);
            } finally {
                setIsLoading(false);
            }
        };
        fetchData();
    }, []);

    // Logic Lọc sản phẩm
    const filteredProducts = useMemo(() => {
        return products.filter(p => {
            // 1. Lọc sp đang hoạt động & còn hàng
            if (!p.isActive || p.stockQuantity <= 0) return false;

            // 2. Lọc theo Danh mục
            const matchCategory = selectedCategory === 'All' || p.category_id === parseInt(selectedCategory);

            // 3. Lọc theo Tìm kiếm
            const matchSearch = normalizeSearchableValue(p.name).includes(normalizeSearchableValue(searchTerm));

            return matchCategory && matchSearch;
        });
    }, [products, selectedCategory, searchTerm]);

    const handleAddToCart = (product) => {
        setCartCount(prev => prev + 1);
        alert(`Đã thêm "${product.name}" vào giỏ hàng!`);
    };

    return (
        <div className="min-h-screen bg-gray-50 font-sans">
            
            {/* --- HEADER KHÁCH HÀNG --- */}
            <header className="bg-white shadow-sm sticky top-0 z-20">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
                    <div className="flex items-center">
                         <span className="text-2xl font-bold text-indigo-600">AuraStore</span>
                    </div>
                    
                    {/* Thanh tìm kiếm */}
                    <div className="flex-1 max-w-lg mx-4 hidden md:block">
                        <div className="relative">
                            <input
                                type="text"
                                placeholder="Tìm kiếm sản phẩm..."
                                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-full focus:ring-2 focus:ring-indigo-500 focus:border-transparent outline-none"
                                value={searchTerm}
                                onChange={(e) => setSearchTerm(e.target.value)}
                            />
                            <Search className="w-5 h-5 text-gray-400 absolute left-3 top-2.5" />
                        </div>
                    </div>

                    {/* Giỏ hàng */}
                    <div className="relative cursor-pointer p-2 hover:bg-gray-100 rounded-full">
                        <ShoppingCart className="w-6 h-6 text-gray-700" />
                        {cartCount > 0 && (
                            <span className="absolute top-0 right-0 inline-flex items-center justify-center px-2 py-1 text-xs font-bold leading-none text-white transform translate-x-1/4 -translate-y-1/4 bg-red-600 rounded-full">
                                {cartCount}
                            </span>
                        )}
                    </div>
                </div>
                
                {/* Thanh tìm kiếm Mobile */}
                <div className="md:hidden px-4 pb-3">
                     <div className="relative">
                        <input
                            type="text"
                            placeholder="Tìm kiếm..."
                            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg"
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                        />
                        <Search className="w-5 h-5 text-gray-400 absolute left-3 top-2.5" />
                    </div>
                </div>
            </header>

            <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                <div className="flex flex-col md:flex-row gap-8">
                    
                    {/* --- SIDEBAR DANH MỤC --- */}
                    <aside className="w-full md:w-64 flex-shrink-0">
                        <div className="bg-white p-4 rounded-xl shadow-sm sticky top-24">
                            <h3 className="font-bold text-gray-800 mb-4 flex items-center">
                                <Filter className="w-5 h-5 mr-2" /> Danh mục
                            </h3>
                            <ul className="space-y-2">
                                <li>
                                    <button
                                        onClick={() => setSelectedCategory('All')}
                                        className={`w-full text-left px-3 py-2 rounded-lg transition ${selectedCategory === 'All' ? 'bg-indigo-100 text-indigo-700 font-medium' : 'text-gray-600 hover:bg-gray-50'}`}
                                    >
                                        Tất cả sản phẩm
                                    </button>
                                </li>
                                {categories.map(cat => (
                                    <li key={cat.category_id}>
                                        <button
                                            onClick={() => setSelectedCategory(cat.category_id)}
                                            className={`w-full text-left px-3 py-2 rounded-lg transition ${selectedCategory === cat.category_id ? 'bg-indigo-100 text-indigo-700 font-medium' : 'text-gray-600 hover:bg-gray-50'}`}
                                        >
                                            {cat.category_name}
                                        </button>
                                    </li>
                                ))}
                            </ul>
                        </div>
                    </aside>

                    {/* --- DANH SÁCH SẢN PHẨM --- */}
                    <div className="flex-1">
                        <h2 className="text-xl font-bold text-gray-800 mb-6">
                            {selectedCategory === 'All' ? 'Tất cả sản phẩm' : categories.find(c => c.category_id === selectedCategory)?.category_name}
                            <span className="text-sm font-normal text-gray-500 ml-2">({filteredProducts.length} sản phẩm)</span>
                        </h2>

                        {isLoading ? (
                            <p className="text-center py-10">Đang tải sản phẩm...</p>
                        ) : filteredProducts.length === 0 ? (
                            <div className="text-center py-20 bg-white rounded-xl">
                                <p className="text-gray-500">Không tìm thấy sản phẩm nào.</p>
                            </div>
                        ) : (
                            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                                {filteredProducts.map(product => (
                                    <div key={product.id} className="bg-white rounded-xl shadow-sm hover:shadow-md transition-shadow duration-300 overflow-hidden border border-gray-100 flex flex-col">
                                        {/* Hình ảnh giả lập */}
                                        <div className="h-48 bg-gray-100 relative group">
                                            <img 
                                                src={`https://placehold.co/400x300/e2e8f0/1e293b?text=${product.name.charAt(0)}`} 
                                                alt={product.name} 
                                                className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
                                            />
                                            {/* Badge giảm giá giả lập */}
                                            <span className="absolute top-2 right-2 bg-red-500 text-white text-xs font-bold px-2 py-1 rounded">
                                                Hot
                                            </span>
                                        </div>
                                        
                                        <div className="p-4 flex-1 flex flex-col">
                                            <div className="text-xs text-indigo-500 font-semibold mb-1">
                                                {product.categoryName || 'Sản phẩm'}
                                            </div>
                                            <h3 className="text-gray-900 font-semibold text-lg leading-tight mb-2 line-clamp-2 min-h-[3rem]">
                                                {product.name}
                                            </h3>
                                            
                                            {/* Đánh giá giả lập */}
                                            <div className="flex items-center mb-4">
                                                <Star className="w-4 h-4 text-yellow-400 fill-current" />
                                                <Star className="w-4 h-4 text-yellow-400 fill-current" />
                                                <Star className="w-4 h-4 text-yellow-400 fill-current" />
                                                <Star className="w-4 h-4 text-yellow-400 fill-current" />
                                                <span className="text-xs text-gray-400 ml-1">(4.5)</span>
                                            </div>
                                            
                                            <div className="mt-auto flex items-center justify-between">
                                                <div>
                                                    <p className="text-lg font-bold text-gray-900">{formatCurrency(product.price)}</p>
                                                    {/* Giá gốc giả lập */}
                                                    {/* <p className="text-sm text-gray-400 line-through">{formatCurrency(product.price * 1.2)}</p> */}
                                                </div>
                                                <button 
                                                    onClick={() => handleAddToCart(product)}
                                                    className="p-2 rounded-full bg-indigo-50 text-indigo-600 hover:bg-indigo-600 hover:text-white transition-colors duration-200"
                                                >
                                                    <ShoppingCart className="w-5 h-5" />
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        )}
                    </div>
                </div>
            </main>
        </div>
    );
};