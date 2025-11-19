const orderModel = require('../models/orderModel');

const orderController = {
    listOrders: async (req, res) => {
        try {
            const orders = await orderModel.getAllOrders();
            return res.status(200).json(orders);
        } catch (error) {
            return res.status(500).json({
                message: 'Lỗi SQL khi truy vấn đơn hàng.',
                details: error.message
            });
        }
    }
};

module.exports = orderController;
