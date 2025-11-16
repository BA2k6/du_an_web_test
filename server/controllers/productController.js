// /server/controllers/productController.js
const productModel = require('../models/productModel');
const productController = {
    listProducts: async (req, res) => {
        // TODO: Cần middleware kiểm tra Auth/Permission
        try {
            const products = await productModel.getAllProducts();
            res.status(200).json(products);
        } catch (error) {
            res.status(500).json({ message: 'Lỗi khi lấy danh sách sản phẩm.' });
        }
    }
};
module.exports = productController;