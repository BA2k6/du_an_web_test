// /server/controllers/orderController.js
const orderModel = require('../models/orderModel');

const orderController = {
    listOrders: async (req, res) => {
        // TODO: Cần middleware kiểm tra Auth/Permission
        try {
            const orders = await orderModel.getAllOrders(); // Gọi Model
            res.status(200).json(orders);
        } catch (error) {
            console.error("Error listing orders:", error);
            res.status(500).json({ message: 'Lỗi khi lấy danh sách đơn hàng.' });
        }
    }
};

module.exports = orderController;