-- ##################################################################
-- 1. TẠO DATABASE & CẤU TRÚC BẢNG (DDL)
-- ##################################################################

-- Tắt kiểm tra khóa ngoại để chèn dữ liệu dễ dàng hơn
SET foreign_key_checks = 0; 

-- Tạo Database và sử dụng nó
CREATE DATABASE IF NOT EXISTS `store_management_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `store_management_db`;

-- Xóa các bảng cũ (nếu có) để đảm bảo khởi tạo sạch
DROP TABLE IF EXISTS `salaries`;
DROP TABLE IF EXISTS `stock_in_details`;
DROP TABLE IF EXISTS `stock_in`;
DROP TABLE IF EXISTS `order_details`;
DROP TABLE IF EXISTS `orders`;
DROP TABLE IF EXISTS `customers`;
DROP TABLE IF EXISTS `products`;
DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `roles`;

-- 1. ROLES (Vai trò)
CREATE TABLE `roles` (
  `role_id` INT UNSIGNED NOT NULL PRIMARY KEY,
  `role_name` VARCHAR(50) NOT NULL UNIQUE,
  `prefix` VARCHAR(10) NOT NULL UNIQUE,
  `description` VARCHAR(255) NULL
);

-- 2. USERS (Nhân viên & Tài khoản)
CREATE TABLE `users` (
  `user_id` VARCHAR(15) NOT NULL PRIMARY KEY,
  `username` VARCHAR(50) NOT NULL UNIQUE,
  `password_hash` VARCHAR(255) NOT NULL,
  `role_id` INT UNSIGNED NOT NULL,
  `full_name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(100) NULL UNIQUE,
  `phone` VARCHAR(20) NULL,
  `date_of_birth` DATE NULL,
  `address` VARCHAR(255) NULL,
  `start_date` DATE NOT NULL,
  `employee_type` ENUM('Full-time', 'Part-time', 'Contract') NOT NULL,
  `department` VARCHAR(50) NOT NULL,
  `base_salary` DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
  `commission_rate` DECIMAL(5, 4) NOT NULL DEFAULT 0.0000,
  `status` ENUM('Active', 'Inactive') NOT NULL DEFAULT 'Active',
  `must_change_password` BOOLEAN NOT NULL DEFAULT TRUE,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`role_id`) REFERENCES `roles`(`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. PRODUCTS (Sản phẩm)
CREATE TABLE `products` (
  `product_id` VARCHAR(20) NOT NULL PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  `price` DECIMAL(18, 2) NOT NULL,
  `cost_price` DECIMAL(18, 2) NOT NULL,
  `stock_quantity` INT NOT NULL DEFAULT 0,
  `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. CUSTOMERS (Khách hàng)
CREATE TABLE `customers` (
  `customer_id` VARCHAR(15) NOT NULL PRIMARY KEY,
  `full_name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(100) NULL,
  `phone` VARCHAR(20) NOT NULL UNIQUE,
  `address` VARCHAR(255) NULL,
  `dob_year` YEAR NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. ORDERS (Đơn hàng)
CREATE TABLE `orders` (
  `order_id` VARCHAR(20) NOT NULL PRIMARY KEY,
  `customer_id` VARCHAR(15) NULL,
  `customer_name` VARCHAR(100) NOT NULL,
  `customer_phone` VARCHAR(20) NULL,
  `order_date` DATETIME NOT NULL,
  `completed_date` DATETIME NULL,
  `order_type` ENUM('Direct', 'Online') NOT NULL,
  `total_amount` DECIMAL(18, 2) NOT NULL,
  `shipping_fee` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
  `status` ENUM('Pending', 'Processing', 'Shipping', 'Completed', 'Cancelled') NOT NULL DEFAULT 'Pending',
  `payment_method` ENUM('Cash', 'Card', 'Transfer', 'COD') NOT NULL,
  `sales_user_id` VARCHAR(15) NOT NULL,
  `shipper_user_id` VARCHAR(15) NULL,
  FOREIGN KEY (`customer_id`) REFERENCES `customers`(`customer_id`),
  FOREIGN KEY (`sales_user_id`) REFERENCES `users`(`user_id`),
  FOREIGN KEY (`shipper_user_id`) REFERENCES `users`(`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. ORDER_DETAILS (Chi tiết đơn hàng)
CREATE TABLE `order_details` (
  `order_id` VARCHAR(20) NOT NULL,
  `product_id` VARCHAR(20) NOT NULL,
  `quantity` INT NOT NULL,
  `price_at_order` DECIMAL(18, 2) NOT NULL,
  PRIMARY KEY (`order_id`, `product_id`),
  FOREIGN KEY (`order_id`) REFERENCES `orders`(`order_id`),
  FOREIGN KEY (`product_id`) REFERENCES `products`(`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. STOCK_IN (Phiếu nhập kho)
CREATE TABLE `stock_in` (
  `stock_in_id` VARCHAR(20) NOT NULL PRIMARY KEY,
  `supplier_name` VARCHAR(100) NOT NULL,
  `import_date` DATETIME NOT NULL,
  `total_cost` DECIMAL(18, 2) NOT NULL,
  `user_id` VARCHAR(15) NOT NULL,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. STOCK_IN_DETAILS (Chi tiết phiếu nhập kho)
CREATE TABLE `stock_in_details` (
  `stock_in_id` VARCHAR(20) NOT NULL,
  `product_id` VARCHAR(20) NOT NULL,
  `quantity` INT NOT NULL,
  `cost_price` DECIMAL(18, 2) NOT NULL,
  PRIMARY KEY (`stock_in_id`, `product_id`),
  FOREIGN KEY (`stock_in_id`) REFERENCES `stock_in`(`stock_in_id`),
  FOREIGN KEY (`product_id`) REFERENCES `products`(`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. SALARIES (Bảng lương đã chi trả)
CREATE TABLE `salaries` (
  `salary_id` VARCHAR(50) NOT NULL PRIMARY KEY,
  `user_id` VARCHAR(15) NOT NULL,
  `month_year` DATE NOT NULL,
  `base_salary` DECIMAL(18, 2) NOT NULL,
  `sales_commission` DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
  `bonus` DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
  `deductions` DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
  `net_salary` DECIMAL(18, 2) NOT NULL,
  `calculated_by_user_id` VARCHAR(15) NOT NULL,
  `paid_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_user_month` (`user_id`, `month_year`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`user_id`),
  FOREIGN KEY (`calculated_by_user_id`) REFERENCES `users`(`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
-- ##################################################################
-- 2. CHÈN DỮ LIỆU MẪU (Tối thiểu 15 bản ghi/bảng chính)
-- ##################################################################

-- 1. Dữ liệu ROLES
INSERT INTO `roles` (`role_id`, `role_name`, `prefix`, `description`) VALUES
(1, 'Owner', 'OWNER', 'Quản lý toàn bộ hệ thống'), 
(3, 'Warehouse', 'WH', 'Quản lý nhập xuất, tồn kho'),
(4, 'Sales', 'SALES', 'Nhân viên bán hàng trực tiếp'), 
(5, 'Online Sales', 'OS', 'Nhân viên xử lý đơn hàng online'),
(6, 'Shipper', 'SHIP', 'Nhân viên giao hàng');

-- 2. Dữ liệu USERS (30 bản ghi)
-- CHÚ Ý: password_hash = username/user_id (plaintext)
INSERT INTO `users` (`user_id`, `username`, `password_hash`, `role_id`, `full_name`, `email`, `phone`, `date_of_birth`, `address`, `start_date`, `employee_type`, `department`, `base_salary`, `commission_rate`, `status`, `must_change_password`) VALUES
('OWNER1', 'OWNER1', 'OWNER1', 1, 'Nguyễn Minh A', 'owner@shop.com', '0901111111', '1980-05-15', '180 CMT8, Q.3', '2019-01-01', 'Full-time', 'Management', 35000000.00, 0.0000, 'Active', FALSE),
('SALES1', 'SALES1', 'SALES1', 4, 'Lê Văn Cường', 'cuong.lv@shop.com', '0903333333', '1995-11-01', '50 Hùng Vương, Q.5', '2022-05-01', 'Full-time', 'Sales', 6000000.00, 0.0150, 'Active', FALSE),
('SALES2', 'SALES2', 'SALES2', 4, 'Phạm Thị Diệp', 'diep.pt@shop.com', '0904444444', '1998-02-28', '110 Cộng Hòa, Tân Bình', '2023-01-15', 'Full-time', 'Sales', 6500000.00, 0.0150, 'Active', TRUE),
('SALES3', 'SALES3', 'SALES3', 4, 'Vũ Anh Em', 'em.va@shop.com', '0905555555', '1996-04-10', '200 Lạc Long Quân, Q.Tân Phú', '2023-08-01', 'Part-time', 'Sales', 5500000.00, 0.0120, 'Active', FALSE),
('SALES4', 'SALES4', 'SALES4', 4, 'Hoàng Ngọc Giang', 'giang.hn@shop.com', '0906666666', '1993-06-05', '75 Cao Thắng, Q.10', '2022-03-20', 'Full-time', 'Sales', 7000000.00, 0.0150, 'Active', FALSE),
('SALES5', 'SALES5', 'SALES5', 4, 'Đinh Thanh Hải', 'hai.dt@shop.com', '0907777777', '1997-09-19', '120 Thạch Thị Thanh, Q.1', '2024-01-10', 'Part-time', 'Sales', 5800000.00, 0.0120, 'Active', FALSE),
('SALES6', 'SALES6', 'SALES6', 4, 'Bùi Thị Hương', 'huong.bt@shop.com', '0908888888', '2000-01-01', '33 Bà Hom, Q.6', '2023-07-07', 'Full-time', 'Sales', 6500000.00, 0.0150, 'Active', FALSE),
('SALES7', 'SALES7', 'SALES7', 4, 'Mai Công Khanh', 'khanh.mc@shop.com', '0909999999', '1994-03-17', '99 Phan Đăng Lưu, Phú Nhuận', '2022-09-09', 'Full-time', 'Sales', 7000000.00, 0.0150, 'Active', FALSE),
('SALES8', 'SALES8', 'SALES8', 4, 'Trần Ngọc Loan', 'loan.tn@shop.com', '0900000001', '1991-08-25', '18 Lê Lai, Q.1', '2021-06-10', 'Full-time', 'Sales', 6200000.00, 0.0150, 'Active', FALSE),
('OS1', 'OS1', 'OS1', 5, 'Nguyễn Thị Kim', 'kim.nt@shop.com', '0910000000', '1992-12-05', '150 Hoàng Văn Thụ, Tân Bình', '2021-10-01', 'Full-time', 'E-commerce', 8000000.00, 0.0180, 'Active', FALSE),
('OS2', 'OS2', 'OS2', 5, 'Lâm Tấn Lộc', 'loc.lt@shop.com', '0911111111', '1996-02-14', '20 Sư Vạn Hạnh, Q.10', '2022-04-20', 'Full-time', 'E-commerce', 8500000.00, 0.0180, 'Active', FALSE),
('OS3', 'OS3', 'OS3', 5, 'Trần Hoài Mỹ', 'my.th@shop.com', '0912222222', '1999-07-30', '45 Bàu Cát, Tân Bình', '2023-11-01', 'Part-time', 'E-commerce', 7800000.00, 0.0150, 'Active', FALSE),
('OS4', 'OS4', 'OS4', 5, 'Võ Thanh Nga', 'nga.vt@shop.com', '0913333333', '1994-04-04', '88 Trương Công Định, Tân Bình', '2022-01-05', 'Full-time', 'E-commerce', 8200000.00, 0.0180, 'Active', FALSE),
('OS5', 'OS5', 'OS5', 5, 'Dương Thúy Phượng', 'phuong.dt@shop.com', '0914444444', '2000-09-29', '13 Lê Lai, Q.1', '2024-05-01', 'Part-time', 'E-commerce', 7500000.00, 0.0150, 'Active', FALSE),
('OS6', 'OS6', 'OS6', 5, 'Ngô Văn Quyền', 'quyen.nv@shop.com', '0915555555', '1991-01-22', '10 Phan Văn Trị, Gò Vấp', '2021-08-15', 'Full-time', 'E-commerce', 8000000.00, 0.0180, 'Active', FALSE),
('WH1', 'WH1', 'WH1', 3, 'Lý Tấn Tài', 'tai.lt@shop.com', '0916666666', '1988-03-08', '25 Nguyễn Đình Chiểu, Q.3', '2020-07-01', 'Full-time', 'Warehouse', 7500000.00, 0.0000, 'Active', FALSE),
('WH2', 'WH2', 'WH2', 3, 'Huỳnh Văn Sang', 'sang.hv@shop.com', '0917777777', '1995-10-10', '350 Trường Chinh, Tân Bình', '2023-04-01', 'Part-time', 'Warehouse', 7000000.00, 0.0000, 'Active', FALSE),
('WH3', 'WH3', 'WH3', 3, 'Đỗ Thị Thúy', 'thuy.dt@shop.com', '0918888888', '1997-01-01', '77 Hoàng Hoa Thám, Phú Nhuận', '2024-02-01', 'Part-time', 'Warehouse', 6500000.00, 0.0000, 'Active', FALSE),
('WH4', 'WH4', 'WH4', 3, 'Hoàng Quang Vinh', 'vinh.hq@shop.com', '0919999999', '1990-12-12', '1A Cao Lỗ, Q.8', '2021-11-20', 'Full-time', 'Warehouse', 7200000.00, 0.0000, 'Active', FALSE),
('WH5', 'WH5', 'WH5', 3, 'Trịnh Đình Huy', 'huy.td@shop.com', '0920000000', '1989-06-01', '52 Bạch Đằng, Bình Thạnh', '2023-09-01', 'Full-time', 'Warehouse', 6800000.00, 0.0000, 'Active', FALSE),
('SHIP1', 'SHIP1', 'SHIP1', 6, 'Trần Văn Út', 'ut.tv@shop.com', '0921111111', '1994-08-18', '55 Trần Hưng Đạo, Q.5', '2023-05-20', 'Full-time', 'Logistics', 6000000.00, 0.0000, 'Active', FALSE),
('SHIP2', 'SHIP2', 'SHIP2', 6, 'Nguyễn Tiến Việt', 'viet.nt@shop.com', '0922222222', '1999-04-25', '10 Phan Xích Long, Phú Nhuận', '2024-03-01', 'Part-time', 'Logistics', 5500000.00, 0.0000, 'Active', FALSE),
('SHIP3', 'SHIP3', 'SHIP3', 6, 'Lê Thị Duyên', 'duyen.lt@shop.com', '0923333333', '1997-10-10', '12 Nguyễn Văn Đậu, Bình Thạnh', '2023-01-01', 'Full-time', 'Logistics', 5800000.00, 0.0000, 'Active', FALSE),
('SHIP4', 'SHIP4', 'SHIP4', 6, 'Mai Thanh Tùng', 'tung.mt@shop.com', '0924444444', '1993-03-03', '66 CMT8, Q.3', '2024-06-01', 'Part-time', 'Logistics', 6100000.00, 0.0000, 'Active', FALSE),
('SHIP5', 'SHIP5', 'SHIP5', 6, 'Bùi Văn Đức', 'duc.bv@shop.com', '0925555555', '1995-05-05', '99 Phan Văn Trị, Gò Vấp', '2023-11-11', 'Full-time', 'Logistics', 5900000.00, 0.0000, 'Active', FALSE),
('SALES9', 'SALES9', 'SALES9', 4, 'Nguyễn Đức Thiện', 'thien.nd@shop.com', '0926666666', '1996-06-06', '20 Bến Nghé, Q.1', '2024-02-01', 'Full-time', 'Sales', 6800000.00, 0.0150, 'Active', FALSE),
('SALES10', 'SALES10', 'SALES10', 4, 'Trần Thị Kim', 'kim.tt@shop.com', '0927777777', '1990-10-10', '52 Lý Thường Kiệt, Q.10', '2021-03-01', 'Full-time', 'Sales', 6500000.00, 0.0150, 'Active', FALSE),
('OS7', 'OS7', 'OS7', 5, 'Phan Văn Lực', 'luc.pv@shop.com', '0928888888', '1995-05-05', '100 Vĩnh Viễn, Q.10', '2023-04-15', 'Full-time', 'E-commerce', 7900000.00, 0.0150, 'Active', FALSE),
('OS8', 'OS8', 'OS8', 5, 'Hồ Thị Hà', 'ha.ht@shop.com', '0929999999', '1993-03-03', '30 Trường Sa, Phú Nhuận', '2022-07-20', 'Full-time', 'E-commerce', 8300000.00, 0.0180, 'Active', FALSE),
('WH6', 'WH6', 'WH6', 3, 'Nguyễn Văn B', 'b.nv@shop.com', '0930000000', '1998-08-08', '15 CMT8, Q.10', '2024-01-01', 'Full-time', 'Warehouse', 7000000.00, 0.0000, 'Active', FALSE);


-- 3. Dữ liệu PRODUCTS (20 bản ghi)
INSERT INTO `products` (`product_id`, `name`, `price`, `cost_price`, `stock_quantity`, `is_active`) VALUES
('SP1', 'Áo Thun Cotton Đen', 150000.00, 80000.00, 300, TRUE),
('SP2', 'Quần Jeans Slim Fit Xanh', 450000.00, 250000.00, 250, TRUE),
('SP3', 'Giày Sneaker Trắng Basic', 700000.00, 400000.00, 180, TRUE),
('SP4', 'Túi Xách Da Công Sở', 950000.00, 550000.00, 100, TRUE),
('SP5', 'Váy Maxi Họa Tiết', 600000.00, 350000.00, 120, TRUE),
('SP6', 'Áo Sơ Mi Linen Trắng', 320000.00, 150000.00, 220, TRUE),
('SP7', 'Đồng Hồ Thể Thao Đa Năng', 1200000.00, 800000.00, 50, TRUE),
('SP8', 'Thắt Lưng Da Bò', 280000.00, 150000.00, 150, TRUE),
('SP9', 'Kính Mát Phân Cực', 400000.00, 200000.00, 80, TRUE),
('SP10', 'Bộ Đồ Thể Thao Cao Cấp', 850000.00, 500000.00, 90, TRUE),
('SP11', 'Áo Khoác Bomber', 750000.00, 400000.00, 110, TRUE),
('SP12', 'Quần Kaki Ống Đứng', 480000.00, 280000.00, 130, TRUE),
('SP13', 'Giày Tây Da Lộn', 1500000.00, 1000000.00, 40, TRUE),
('SP14', 'Nước Hoa Unisex 50ml', 1800000.00, 1200000.00, 60, TRUE),
('SP15', 'Mũ Lưỡi Trai Logo', 120000.00, 50000.00, 250, TRUE),
('SP16', 'Sổ Tay Bìa Da A5', 180000.00, 90000.00, 180, TRUE),
('SP17', 'Balo Laptop Chống Nước', 550000.00, 300000.00, 140, TRUE),
('SP18', 'Khăn Quàng Cổ Lụa', 200000.00, 100000.00, 90, TRUE),
('SP19', 'Áo Polo Xám', 290000.00, 140000.00, 210, TRUE),
('SP20', 'Dép Da Cao Cấp', 380000.00, 200000.00, 160, TRUE);

-- 4. Dữ liệu CUSTOMERS (20 bản ghi)
INSERT INTO `customers` (`customer_id`, `full_name`, `email`, `phone`, `address`, `dob_year`) VALUES
('KH1', 'Trần Khôi Nguyên', 'nguyen.tk@mail.com', '0901111111', '10 Phan Kế Bính, Q.1', 1990),
('KH2', 'Lê Hồng Thu', 'thu.lh@mail.com', '0902222222', '25 Nguyễn Thị Minh Khai, Q.3', 1995),
('KH3', 'Phạm Tấn Lộc', 'loc.pt@mail.com', '0903333333', '88 Trường Sa, Phú Nhuận', 1985),
('KH4', 'Vũ Thanh Hằng', 'hang.vt@mail.com', '0904444444', '12 Võ Văn Tần, Q.3', 2000),
('KH5', 'Hoàng Văn Minh', 'minh.hv@mail.com', '0905555555', '99 Hoàng Diệu, Q.4', 1992),
('KH6', 'Đào Thị Kiều', 'kieu.dt@mail.com', '0906666666', '55 Bến Vân Đồn, Q.4', 1997),
('KH7', 'Bùi Chí Tín', 'tin.bc@mail.com', '0907777777', '115 Trần Hưng Đạo, Q.5', 1988),
('KH8', 'Nguyễn Thanh Nga', 'nga.nt@mail.com', '0908888888', '33 Trần Bình Trọng, Q.5', 1993),
('KH9', 'Mai Đức Phú', 'phu.md@mail.com', '0909999999', '200 Hồng Bàng, Q.6', 1996),
('KH10', 'Tô Thị Yến', 'yen.tt@mail.com', '0910000000', '15 Lê Văn Sỹ, Phú Nhuận', 1991),
('KH11', 'Trần Văn Tùng', 'tung.tv@mail.com', '0911111111', '70 Cộng Hòa, Tân Bình', 1994),
('KH12', 'Lý Thị Mỹ', 'my.lt@mail.com', '0912222222', '90 Lý Thường Kiệt, Q.10', 1999),
('KH13', 'Phạm Ngọc Duy', 'duy.pn@mail.com', '0913333333', '66 Thành Thái, Q.10', 1987),
('KH14', 'Vũ Thị Thanh', 'thanh.vt@mail.com', '0914444444', '140 Lạc Long Quân, Tân Bình', 1998),
('KH15', 'Hoàng Anh Tuấn', 'tuan.ha@mail.com', '0915555555', '20 Phan Đăng Lưu, Phú Nhuận', 1990),
('KH16', 'Đinh Gia Bảo', 'bao.dg@mail.com', '0916666666', '45 Nguyễn Chí Thanh, Q.5', 2001),
('KH17', 'Bùi Việt Đức', 'duc.bv@mail.com', '0917777777', '19 Phạm Văn Đồng, Gò Vấp', 1993),
('KH18', 'Ngô Thanh Hà', 'ha.nt@mail.com', '0918888888', '210 Quang Trung, Gò Vấp', 1996),
('KH19', 'Mai Văn Thắng', 'thang.mv@mail.com', '0919999999', '17 Trường Sa, Bình Thạnh', 1994),
('KH20', 'Tô Hải Đăng', 'dang.th@mail.com', '0920000000', '150 Phan Xích Long, Phú Nhuận', 1997);


-- 5. Dữ liệu ORDERS (20 bản ghi)
INSERT INTO `orders` (`order_id`, `customer_id`, `customer_name`, `customer_phone`, `order_date`, `completed_date`, `order_type`, `total_amount`, `shipping_fee`, `status`, `payment_method`, `sales_user_id`, `shipper_user_id`) VALUES
('DH01', 'KH1', 'Trần Khôi Nguyên', '0901111111', '2025-10-01 10:30:00', '2025-10-01 11:00:00', 'Direct', 600000.00, 0.00, 'Completed', 'Cash', 'SALES1', NULL),
('DH02', 'KH2', 'Lê Hồng Thu', '0902222222', '2025-10-02 11:00:00', '2025-10-02 11:30:00', 'Direct', 1500000.00, 0.00, 'Completed', 'Card', 'SALES2', NULL),
('DH03', 'KH3', 'Phạm Tấn Lộc', '0903333333', '2025-10-03 12:45:00', '2025-10-03 12:45:00', 'Direct', 400000.00, 0.00, 'Completed', 'Cash', 'SALES3', NULL),
('DH04', 'KH4', 'Vũ Thanh Hằng', '0904444444', '2025-10-04 14:00:00', '2025-10-04 14:00:00', 'Direct', 750000.00, 0.00, 'Completed', 'Card', 'SALES1', NULL),
('DH05', 'KH5', 'Hoàng Văn Minh', '0905555555', '2025-10-05 09:15:00', '2025-10-05 09:15:00', 'Direct', 250000.00, 0.00, 'Completed', 'Transfer', 'SALES2', NULL),
('DH06', 'KH6', 'Đào Thị Kiều', '0906666666', '2025-10-06 16:30:00', '2025-10-06 16:30:00', 'Direct', 900000.00, 0.00, 'Completed', 'Cash', 'SALES3', NULL),
('DH07', 'KH7', 'Bùi Chí Tín', '0907777777', '2025-10-11 09:00:00', NULL, 'Online', 730000.00, 30000.00, 'Shipping', 'COD', 'OS1', 'SHIP1'),
('DH08', 'KH8', 'Nguyễn Thanh Nga', '0908888888', '2025-10-12 11:10:00', NULL, 'Online', 630000.00, 30000.00, 'Shipping', 'Transfer', 'OS2', 'SHIP2'),
('DH09', 'KH9', 'Mai Đức Phú', '0909999999', '2025-10-13 14:20:00', NULL, 'Online', 1840000.00, 40000.00, 'Shipping', 'COD', 'OS3', 'SHIP1'),
('DH10', 'KH10', 'Tô Thị Yến', '0910000000', '2025-10-14 10:40:00', '2025-10-17 10:40:00', 'Online', 575000.00, 25000.00, 'Completed', 'COD', 'OS4', 'SHIP2'),
('DH11', 'KH11', 'Trần Văn Tùng', '0911111111', '2025-10-15 15:50:00', NULL, 'Online', 150000.00, 30000.00, 'Pending', 'Transfer', 'OS5', 'SHIP3'),
('DH12', 'KH12', 'Lý Thị Mỹ', '0912222222', '2025-10-16 12:15:00', NULL, 'Online', 320000.00, 30000.00, 'Processing', 'COD', 'OS6', 'SHIP4'),
('DH13', 'KH13', 'Phạm Ngọc Duy', '0913333333', '2025-10-17 17:00:00', '2025-10-20 17:00:00', 'Online', 780000.00, 30000.00, 'Completed', 'Transfer', 'OS1', 'SHIP1'),
('DH14', 'KH14', 'Vũ Thị Thanh', '0914444444', '2025-10-18 09:45:00', NULL, 'Online', 480000.00, 30000.00, 'Shipping', 'COD', 'OS2', 'SHIP5'),
('DH15', 'KH15', 'Hoàng Anh Tuấn', '0915555555', '2025-10-19 13:30:00', NULL, 'Online', 980000.00, 30000.00, 'Processing', 'Transfer', 'OS3', 'SHIP1'),
('DH16', 'KH16', 'Đinh Gia Bảo', '0916666666', '2025-10-20 16:00:00', NULL, 'Online', 350000.00, 30000.00, 'Pending', 'COD', 'OS4', 'SHIP2'),
('DH17', 'KH17', 'Bùi Việt Đức', '0917777777', '2025-10-21 10:00:00', '2025-10-21 10:00:00', 'Direct', 180000.00, 0.00, 'Completed', 'Cash', 'SALES4', NULL),
('DH18', 'KH18', 'Ngô Thanh Hà', '0918888888', '2025-10-22 11:30:00', '2025-10-22 11:30:00', 'Direct', 1200000.00, 0.00, 'Completed', 'Card', 'SALES5', NULL),
('DH19', 'KH19', 'Mai Văn Thắng', '0919999999', '2025-10-23 13:00:00', '2025-10-23 13:00:00', 'Direct', 480000.00, 0.00, 'Completed', 'Transfer', 'SALES6', NULL),
('DH20', 'KH20', 'Tô Hải Đăng', '0920000000', '2025-10-24 15:00:00', '2025-10-24 15:00:00', 'Direct', 380000.00, 0.00, 'Completed', 'Cash', 'SALES7', NULL);


-- 6. Dữ liệu ORDER_DETAILS (25 bản ghi)
INSERT INTO `order_details` (`order_id`, `product_id`, `quantity`, `price_at_order`) VALUES
('DH01', 'SP1', 4, 150000.00),
('DH02', 'SP4', 1, 950000.00),
('DH02', 'SP9', 1, 400000.00),
('DH03', 'SP9', 1, 400000.00),
('DH04', 'SP11', 1, 750000.00),
('DH05', 'SP1', 1, 150000.00),
('DH05', 'SP15', 1, 100000.00),
('DH06', 'SP10', 1, 850000.00),
('DH06', 'SP15', 1, 50000.00),
('DH07', 'SP3', 1, 700000.00),
('DH08', 'SP5', 1, 600000.00),
('DH09', 'SP14', 1, 1800000.00),
('DH10', 'SP17', 1, 550000.00),
('DH11', 'SP15', 1, 120000.00),
('DH12', 'SP19', 1, 290000.00),
('DH13', 'SP11', 1, 750000.00),
('DH14', 'SP2', 1, 450000.00),
('DH15', 'SP4', 1, 950000.00),
('DH16', 'SP6', 1, 320000.00),
('DH17', 'SP16', 1, 180000.00),
('DH18', 'SP7', 1, 1200000.00),
('DH19', 'SP12', 1, 480000.00),
('DH20', 'SP20', 1, 380000.00),
('DH13', 'SP8', 1, 30000.00),
('DH13', 'SP18', 1, 30000.00);


-- 7. Dữ liệu STOCK_IN (5 Phiếu nhập)
INSERT INTO `stock_in` (`stock_in_id`, `supplier_name`, `import_date`, `total_cost`, `user_id`) VALUES
('NK1', 'NCC A - Tổng hợp', '2025-09-25 10:00:00', 15000000.00, 'WH1'),
('NK2', 'NCC B - Phụ kiện', '2025-10-05 14:00:00', 5000000.00, 'WH2'),
('NK3', 'NCC C - Giày dép', '2025-10-10 09:00:00', 10000000.00, 'WH3'),
('NK4', 'NCC D - Áo khoác', '2025-11-01 11:00:00', 8000000.00, 'WH4'),
('NK5', 'NCC E - Mỹ phẩm', '2025-11-15 15:00:00', 24000000.00, 'WH5');


-- 8. Dữ liệu STOCK_IN_DETAILS (15 bản ghi)
INSERT INTO `stock_in_details` (`stock_in_id`, `product_id`, `quantity`, `cost_price`) VALUES
('NK1', 'SP1', 100, 80000.00),
('NK1', 'SP2', 50, 250000.00),
('NK1', 'SP6', 50, 150000.00),
('NK2', 'SP15', 100, 50000.00),
('NK2', 'SP8', 50, 150000.00),
('NK3', 'SP3', 20, 400000.00),
('NK3', 'SP20', 30, 200000.00),
('NK4', 'SP11', 40, 400000.00),
('NK4', 'SP19', 40, 140000.00),
('NK5', 'SP14', 20, 1200000.00),
('NK5', 'SP17', 10, 300000.00),
('NK5', 'SP4', 5, 550000.00),
('NK5', 'SP13', 5, 1000000.00),
('NK5', 'SP7', 2, 800000.00),
('NK5', 'SP9', 2, 200000.00);


-- 9. Dữ liệu SALARIES (29 bản ghi - Lương tháng 10/2025)
-- ##################################################################
-- CHÈN DỮ LIỆU BẢNG SALARIES (29 bản ghi - Lương tháng 10/2025)
-- ##################################################################

INSERT INTO `salaries` (`salary_id`, `user_id`, `month_year`, `base_salary`, `sales_commission`, `bonus`, `deductions`, `net_salary`, `calculated_by_user_id`) VALUES 
('SALES1-2025-10', 'SALES1', '2025-10-01', 6000000, 20250, 200000, 50000, 6170250, 'OWNER1'), 
('SALES2-2025-10', 'SALES2', '2025-10-01', 6500000, 26250, 200000, 50000, 6676250, 'OWNER1'), 
('SALES3-2025-10', 'SALES3', '2025-10-01', 5500000, 4800, 200000, 50000, 5654800, 'OWNER1'), 
('SALES4-2025-10', 'SALES4', '2025-10-01', 7000000, 27000, 200000, 50000, 7177000, 'OWNER1'), 
('SALES5-2025-10', 'SALES5', '2025-10-01', 5800000, 35000, 200000, 50000, 5985000, 'OWNER1'), 
('SALES6-2025-10', 'SALES6', '2025-10-01', 6500000, 32000, 200000, 50000, 6682000, 'OWNER1'), 
('SALES7-2025-10', 'SALES7', '2025-10-01', 7000000, 12000, 200000, 50000, 7162000, 'OWNER1'), 
('SALES8-2025-10', 'SALES8', '2025-10-01', 6200000, 0, 200000, 50000, 6350000, 'OWNER1'), 
('SALES9-2025-10', 'SALES9', '2025-10-01', 6800000, 0, 200000, 50000, 6950000, 'OWNER1'), 
('SALES10-2025-10', 'SALES10', '2025-10-01', 6500000, 0, 200000, 50000, 6650000, 'OWNER1'), 
('OS1-2025-10', 'OS1', '2025-10-01', 8000000, 27540, 500000, 100000, 8327540, 'OWNER1'), 
('OS2-2025-10', 'OS2', '2025-10-01', 8500000, 16500, 500000, 100000, 8884500, 'OWNER1'), 
('OS3-2025-10', 'OS3', '2025-10-01', 7800000, 14700, 500000, 100000, 8184700, 'OWNER1'), 
('OS4-2025-10', 'OS4', '2025-10-01', 8200000, 10350, 500000, 100000, 8500350, 'OWNER1'), 
('OS5-2025-10', 'OS5', '2025-10-01', 7500000, 0, 500000, 100000, 7900000, 'OWNER1'), 
('OS6-2025-10', 'OS6', '2025-10-01', 8000000, 0, 500000, 100000, 8400000, 'OWNER1'), 
('OS7-2025-10', 'OS7', '2025-10-01', 7900000, 0, 500000, 100000, 8300000, 'OWNER1'), 
('OS8-2025-10', 'OS8', '2025-10-01', 8300000, 0, 500000, 100000, 8700000, 'OWNER1'), 
('WH1-2025-10', 'WH1', '2025-10-01', 7500000, 0, 0, 20000, 7480000, 'OWNER1'), 
('WH2-2025-10', 'WH2', '2025-10-01', 7000000, 0, 0, 20000, 6980000, 'OWNER1'), 
('WH3-2025-10', 'WH3', '2025-10-01', 6500000, 0, 0, 20000, 6480000, 'OWNER1'), 
('WH4-2025-10', 'WH4', '2025-10-01', 7200000, 0, 0, 20000, 7180000, 'OWNER1'), 
('WH5-2025-10', 'WH5', '2025-10-01', 6800000, 0, 0, 20000, 6780000, 'OWNER1'), 
('WH6-2025-10', 'WH6', '2025-10-01', 7000000, 0, 0, 20000, 6980000, 'OWNER1'), 
('SHIP1-2025-10', 'SHIP1', '2025-10-01', 6000000, 0, 50000, 0, 6050000, 'OWNER1'), 
('SHIP2-2025-10', 'SHIP2', '2025-10-01', 5500000, 0, 50000, 0, 5550000, 'OWNER1'), 
('SHIP3-2025-10', 'SHIP3', '2025-10-01', 5800000, 0, 50000, 0, 5850000, 'OWNER1'), 
('SHIP4-2025-10', 'SHIP4', '2025-10-01', 6100000, 0, 50000, 0, 6150000, 'OWNER1'), 
('SHIP5-2025-10', 'SHIP5', '2025-10-01', 5900000, 0, 50000, 0, 5950000, 'OWNER1');

-- Bật lại kiểm tra khóa ngoại
SET foreign_key_checks = 1;