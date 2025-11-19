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
-- 2. CHÈN DỮ LIỆU MẪU BAN ĐẦU
-- ##################################################################

-- 1. Dữ liệu ROLES
INSERT INTO `roles` (`role_id`, `role_name`, `prefix`, `description`) VALUES
(1, 'Owner', 'OWNER', 'Quản lý toàn bộ hệ thống'),
(3, 'Warehouse', 'WH', 'Quản lý nhập xuất, tồn kho'),
(4, 'Sales', 'SALES', 'Nhân viên bán hàng trực tiếp'),
(5, 'Online Sales', 'OS', 'Nhân viên xử lý đơn hàng online'),
(6, 'Shipper', 'SHIP', 'Nhân viên giao hàng');

-- 2. Dữ liệu USERS (30 bản ghi)
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
('SALES9', 'SALES9', 'SALES9', 4, 'Nguyễn Đức Thiện', 'thien.nd@shop.com', '0926666666', '1996-06-06', '20 Bến Nghé, Q.1', '2024-02-01', 'Full-time', 'Sales', 6800000.00, 0.0150, 'Active', FALSE),
('SALES10', 'SALES10', 'SALES10', 4, 'Trần Thị Kim', 'kim.tt@shop.com', '0927777777', '1990-10-10', '52 Lý Thường Kiệt, Q.10', '2021-03-01', 'Full-time', 'Sales', 6500000.00, 0.0150, 'Active', FALSE),
('OS1', 'OS1', 'OS1', 5, 'Nguyễn Thị Kim', 'kim.nt@shop.com', '0910000000', '1992-12-05', '150 Hoàng Văn Thụ, Tân Bình', '2021-10-01', 'Full-time', 'E-commerce', 8000000.00, 0.0180, 'Active', FALSE),
('OS2', 'OS2', 'OS2', 5, 'Lâm Tấn Lộc', 'loc.lt@shop.com', '0911111111', '1996-02-14', '20 Sư Vạn Hạnh, Q.10', '2022-04-20', 'Full-time', 'E-commerce', 8500000.00, 0.0180, 'Active', FALSE),
('OS3', 'OS3', 'OS3', 5, 'Trần Hoài Mỹ', 'my.th@shop.com', '0912222222', '1999-07-30', '45 Bàu Cát, Tân Bình', '2023-11-01', 'Part-time', 'E-commerce', 7800000.00, 0.0150, 'Active', FALSE),
('OS4', 'OS4', 'OS4', 5, 'Võ Thanh Nga', 'nga.vt@shop.com', '0913333333', '1994-04-04', '88 Trương Công Định, Tân Bình', '2022-01-05', 'Full-time', 'E-commerce', 8200000.00, 0.0180, 'Active', FALSE),
('OS5', 'OS5', 'OS5', 5, 'Dương Thúy Phượng', 'phuong.dt@shop.com', '0914444444', '2000-09-29', '13 Lê Lai, Q.1', '2024-05-01', 'Part-time', 'E-commerce', 7500000.00, 0.0150, 'Active', FALSE),
('OS6', 'OS6', 'OS6', 5, 'Ngô Văn Quyền', 'quyen.nv@shop.com', '0915555555', '1991-01-22', '10 Phan Văn Trị, Gò Vấp', '2021-08-15', 'Full-time', 'E-commerce', 8000000.00, 0.0180, 'Active', FALSE),
('OS7', 'OS7', 'OS7', 5, 'Phan Văn Lực', 'luc.pv@shop.com', '0928888888', '1995-05-05', '100 Vĩnh Viễn, Q.10', '2023-04-15', 'Full-time', 'E-commerce', 7900000.00, 0.0150, 'Active', FALSE),
('OS8', 'OS8', 'OS8', 5, 'Hồ Thị Hà', 'ha.ht@shop.com', '0929999999', '1993-03-03', '30 Trường Sa, Phú Nhuận', '2022-07-20', 'Full-time', 'E-commerce', 8300000.00, 0.0180, 'Active', FALSE),
('WH1', 'WH1', 'WH1', 3, 'Lý Tấn Tài', 'tai.lt@shop.com', '0916666666', '1988-03-08', '25 Nguyễn Đình Chiểu, Q.3', '2020-07-01', 'Full-time', 'Warehouse', 7500000.00, 0.0000, 'Active', FALSE),
('WH2', 'WH2', 'WH2', 3, 'Huỳnh Văn Sang', 'sang.hv@shop.com', '0917777777', '1995-10-10', '350 Trường Chinh, Tân Bình', '2023-04-01', 'Part-time', 'Warehouse', 7000000.00, 0.0000, 'Active', FALSE),
('WH3', 'WH3', 'WH3', 3, 'Đỗ Thị Thúy', 'thuy.dt@shop.com', '0918888888', '1997-01-01', '77 Hoàng Hoa Thám, Phú Nhuận', '2024-02-01', 'Part-time', 'Warehouse', 6500000.00, 0.0000, 'Active', FALSE),
('WH4', 'WH4', 'WH4', 3, 'Hoàng Quang Vinh', 'vinh.hq@shop.com', '0919999999', '1990-12-12', '1A Cao Lỗ, Q.8', '2021-11-20', 'Full-time', 'Warehouse', 7200000.00, 0.0000, 'Active', FALSE),
('WH5', 'WH5', 'WH5', 3, 'Trịnh Đình Huy', 'huy.td@shop.com', '0920000000', '1989-06-01', '52 Bạch Đằng, Bình Thạnh', '2023-09-01', 'Full-time', 'Warehouse', 6800000.00, 0.0000, 'Active', FALSE),
('WH6', 'WH6', 'WH6', 3, 'Nguyễn Văn B', 'b.nv@shop.com', '0930000000', '1998-08-08', '15 CMT8, Q.10', '2024-01-01', 'Full-time', 'Warehouse', 7000000.00, 0.0000, 'Active', FALSE),
('SHIP1', 'SHIP1', 'SHIP1', 6, 'Trần Văn Út', 'ut.tv@shop.com', '0921111111', '1994-08-18', '55 Trần Hưng Đạo, Q.5', '2023-05-20', 'Full-time', 'Logistics', 6000000.00, 0.0000, 'Active', FALSE),
('SHIP2', 'SHIP2', 'SHIP2', 6, 'Nguyễn Tiến Việt', 'viet.nt@shop.com', '0922222222', '1999-04-25', '10 Phan Xích Long, Phú Nhuận', '2024-03-01', 'Part-time', 'Logistics', 5500000.00, 0.0000, 'Active', FALSE),
('SHIP3', 'SHIP3', 'SHIP3', 6, 'Lê Thị Duyên', 'duyen.lt@shop.com', '0923333333', '1997-10-10', '12 Nguyễn Văn Đậu, Bình Thạnh', '2023-01-01', 'Full-time', 'Logistics', 5800000.00, 0.0000, 'Active', FALSE),
('SHIP4', 'SHIP4', 'SHIP4', 6, 'Mai Thanh Tùng', 'tung.mt@shop.com', '0924444444', '1993-03-03', '66 CMT8, Q.3', '2024-06-01', 'Part-time', 'Logistics', 6100000.00, 0.0000, 'Active', FALSE),
('SHIP5', 'SHIP5', 'SHIP5', 6, 'Bùi Văn Đức', 'duc.bv@shop.com', '0925555555', '1995-05-05', '99 Phan Văn Trị, Gò Vấp', '2023-11-11', 'Full-time', 'Logistics', 5900000.00, 0.0000, 'Active', FALSE);


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

-- 4. Dữ liệu CUSTOMERS (20 bản ghi mẫu + 100 bản ghi bổ sung = 120 KH)
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
('KH20', 'Tô Hải Đăng', 'dang.th@mail.com', '0920000000', '150 Phan Xích Long, Phú Nhuận', 1997),
('KH21', 'Nguyễn Văn Đạt', 'dat.nv@mail.com', '0921000001', '100 Lê Văn Sỹ, Q.3', 1990),
('KH22', 'Trần Thị Mai', 'mai.tt@mail.com', '0921000002', '200 Điện Biên Phủ, Q.1', 1995),
('KH23', 'Lê Hữu Phúc', 'phuc.lh@mail.com', '0921000003', '55 Nguyễn Thái Bình, Q.1', 1985),
('KH24', 'Phạm Thanh Thảo', 'thao.pt@mail.com', '0921000004', '120 Nguyễn Văn Cừ, Q.5', 2000),
('KH25', 'Vũ Đình Khang', 'khang.vd@mail.com', '0921000005', '70 Lữ Gia, Q.11', 1992),
('KH26', 'Hoàng Bảo Vy', 'vy.hb@mail.com', '0921000006', '33 Hoàng Việt, Tân Bình', 1997),
('KH27', 'Đinh Công Lý', 'ly.dc@mail.com', '0921000007', '11 Nguyễn Trãi, Q.1', 1988),
('KH28', 'Bùi Thị Hà', 'ha.bt@mail.com', '0921000008', '40 Trường Sơn, Tân Bình', 1993),
('KH29', 'Nguyễn Tấn Tài', 'tai.nt@mail.com', '0921000009', '250 Xô Viết Nghệ Tĩnh, Bình Thạnh', 1996),
('KH30', 'Mai Thị Kim', 'kim.mt@mail.com', '0921000010', '15 Phan Xích Long, Phú Nhuận', 1991),
('KH31', 'Trần Văn Long', 'long.tv@mail.com', '0921000011', '80 Huỳnh Tấn Phát, Q.7', 1994),
('KH32', 'Lý Ngọc Lan', 'lan.ln@mail.com', '0921000012', '100 Đinh Tiên Hoàng, Q.1', 1999),
('KH33', 'Phạm Minh Quân', 'quan.pm@mail.com', '0921000013', '66 Lê Lợi, Q.1', 1987),
('KH34', 'Vũ Thu Trang', 'trang.vt@mail.com', '0921000014', '140 Hai Bà Trưng, Q.3', 1998),
('KH35', 'Hoàng Minh Khôi', 'khoi.hm@mail.com', '0921000015', '20 Nguyễn Huệ, Q.1', 1990),
('KH36', 'Đinh Thanh Tùng', 'tung.dt@mail.com', '0921000016', '45 Bến Nghé, Q.1', 2001),
('KH37', 'Bùi Thị Ngọc', 'ngoc.bt@mail.com', '0921000017', '19 Nguyễn Văn Thủ, Q.1', 1993),
('KH38', 'Ngô Văn Nam', 'nam.nv@mail.com', '0921000018', '210 Pasteur, Q.3', 1996),
('KH39', 'Mai Thị Duyên', 'duyen.mt@mail.com', '0921000019', '17 Lý Tự Trọng, Q.1', 1994),
('KH40', 'Tô Minh Hoàng', 'hoang.tm@mail.com', '0921000020', '150 Đồng Khởi, Q.1', 1997),
('KH41', 'Đỗ Thành Trung', 'trung.dt@mail.com', '0921000021', '10 Phan Kế Bính, Q.1', 1990),
('KH42', 'Lê Kim Oanh', 'oanh.lk@mail.com', '0921000022', '25 Nguyễn Thị Minh Khai, Q.3', 1995),
('KH43', 'Phạm Văn Dũng', 'dung.pv@mail.com', '0921000023', '88 Trường Sa, Phú Nhuận', 1985),
('KH44', 'Vũ Thị Thanh Hương', 'huong.vtt@mail.com', '0921000024', '12 Võ Văn Tần, Q.3', 2000),
('KH45', 'Hoàng Quốc Việt', 'viet.hq@mail.com', '0921000025', '99 Hoàng Diệu, Q.4', 1992),
('KH46', 'Đào Duy Anh', 'anh.dd@mail.com', '0921000026', '55 Bến Vân Đồn, Q.4', 1997),
('KH47', 'Bùi Ngọc Hùng', 'hung.bn@mail.com', '0921000027', '115 Trần Hưng Đạo, Q.5', 1988),
('KH48', 'Nguyễn Thị Thu', 'thu.nt@mail.com', '0921000028', '33 Trần Bình Trọng, Q.5', 1993),
('KH49', 'Mai Chí Tôn', 'ton.mc@mail.com', '0921000029', '200 Hồng Bàng, Q.6', 1996),
('KH50', 'Tô Thanh Thảo', 'thao.tt@mail.com', '0921000030', '15 Lê Văn Sỹ, Phú Nhuận', 1991),
('KH51', 'Trần Minh Quang', 'quang.tm@mail.com', '0921000031', '70 Cộng Hòa, Tân Bình', 1994),
('KH52', 'Lý Kim Ngân', 'ngan.lk@mail.com', '0921000032', '90 Lý Thường Kiệt, Q.10', 1999),
('KH53', 'Phạm Văn Thành', 'thanh.pv@mail.com', '0921000033', '66 Thành Thái, Q.10', 1987),
('KH54', 'Vũ Thị Mai', 'mai.vt@mail.com', '0921000034', '140 Lạc Long Quân, Tân Bình', 1998),
('KH55', 'Hoàng Văn Phong', 'phong.hv@mail.com', '0921000035', '20 Phan Đăng Lưu, Phú Nhuận', 1990),
('KH56', 'Đinh Thanh Hải', 'hai.dt@mail.com', '0921000036', '45 Nguyễn Chí Thanh, Q.5', 2001),
('KH57', 'Bùi Văn Sơn', 'son.bv@mail.com', '0921000037', '19 Phạm Văn Đồng, Gò Vấp', 1993),
('KH58', 'Ngô Thu Hiền', 'hien.nt@mail.com', '0921000038', '210 Quang Trung, Gò Vấp', 1996),
('KH59', 'Mai Văn Tín', 'tin.mv@mail.com', '0921000039', '17 Trường Sa, Bình Thạnh', 1994),
('KH60', 'Tô Thị Liên', 'lien.tt@mail.com', '0921000040', '150 Phan Xích Long, Phú Nhuận', 1997),
('KH61', 'Trần Hữu Duy', 'duy.th@mail.com', '0921000041', '10 Phan Kế Bính, Q.1', 1990),
('KH62', 'Lê Văn Tú', 'tu.lv@mail.com', '0921000042', '25 Nguyễn Thị Minh Khai, Q.3', 1995),
('KH63', 'Phạm Ngọc Thắng', 'thang.pn@mail.com', '0921000043', '88 Trường Sa, Phú Nhuận', 1985),
('KH64', 'Vũ Thị Ngọc Ánh', 'anh.vtn@mail.com', '0921000044', '12 Võ Văn Tần, Q.3', 2000),
('KH65', 'Hoàng Minh Đức', 'duc.hm@mail.com', '0921000045', '99 Hoàng Diệu, Q.4', 1992),
('KH66', 'Đào Thị Hồng', 'hong.dt@mail.com', '0921000046', '55 Bến Vân Đồn, Q.4', 1997),
('KH67', 'Bùi Đức Anh', 'anh.bd@mail.com', '0921000047', '115 Trần Hưng Đạo, Q.5', 1988),
('KH68', 'Nguyễn Thị Thúy', 'thuy.nt@mail.com', '0921000048', '33 Trần Bình Trọng, Q.5', 1993),
('KH69', 'Mai Thị Phương', 'phuong.mt@mail.com', '0921000049', '200 Hồng Bàng, Q.6', 1996),
('KH70', 'Tô Văn Hùng', 'hung.tv@mail.com', '0921000050', '15 Lê Văn Sỹ, Phú Nhuận', 1991),
('KH71', 'Trần Thị Tuyết', 'tuyet.tt@mail.com', '0921000051', '70 Cộng Hòa, Tân Bình', 1994),
('KH72', 'Lý Văn Khoa', 'khoa.lv@mail.com', '0921000052', '90 Lý Thường Kiệt, Q.10', 1999),
('KH73', 'Phạm Duy Nam', 'nam.pd@mail.com', '0921000053', '66 Thành Thái, Q.10', 1987),
('KH74', 'Vũ Văn Long', 'long.vv@mail.com', '0921000054', '140 Lạc Long Quân, Tân Bình', 1998),
('KH75', 'Hoàng Thị Yến', 'yen.ht@mail.com', '0921000055', '20 Phan Đăng Lưu, Phú Nhuận', 1990),
('KH76', 'Đinh Văn Công', 'cong.dv@mail.com', '0921000056', '45 Nguyễn Chí Thanh, Q.5', 2001),
('KH77', 'Bùi Thị Kim', 'kim.bt@mail.com', '0921000057', '19 Phạm Văn Đồng, Gò Vấp', 1993),
('KH78', 'Ngô Thanh Sơn', 'son.nt@mail.com', '0921000058', '210 Quang Trung, Gò Vấp', 1996),
('KH79', 'Mai Văn Chiến', 'chien.mv@mail.com', '0921000059', '17 Trường Sa, Bình Thạnh', 1994),
('KH80', 'Tô Ngọc Hiếu', 'hieu.tn@mail.com', '0921000060', '150 Phan Xích Long, Phú Nhuận', 1997),
('KH81', 'Trần Văn Mạnh', 'manh.tv@mail.com', '0921000061', '10 Phan Kế Bính, Q.1', 1990),
('KH82', 'Lê Thị Thuý', 'thuy.lt@mail.com', '0921000062', '25 Nguyễn Thị Minh Khai, Q.3', 1995),
('KH83', 'Phạm Minh Toàn', 'toan.pm@mail.com', '0921000063', '88 Trường Sa, Phú Nhuận', 1985),
('KH84', 'Vũ Văn Hùng', 'hung.vv@mail.com', '0921000064', '12 Võ Văn Tần, Q.3', 2000),
('KH85', 'Hoàng Thị Tuyết', 'tuyet.ht@mail.com', '0921000065', '99 Hoàng Diệu, Q.4', 1992),
('KH86', 'Đào Quốc Khánh', 'khanh.dq@mail.com', '0921000066', '55 Bến Vân Đồn, Q.4', 1997),
('KH87', 'Bùi Thị Lan', 'lan.bt@mail.com', '0921000067', '115 Trần Hưng Đạo, Q.5', 1988),
('KH88', 'Nguyễn Hữu Trí', 'tri.nh@mail.com', '0921000068', '33 Trần Bình Trọng, Q.5', 1993),
('KH89', 'Mai Thanh Liêm', 'liem.mt@mail.com', '0921000069', '200 Hồng Bàng, Q.6', 1996),
('KH90', 'Tô Hữu Phước', 'phuoc.th@mail.com', '0921000070', '15 Lê Văn Sỹ, Phú Nhuận', 1991),
('KH91', 'Trần Thanh Nam', 'nam.tt@mail.com', '0921000071', '70 Cộng Hòa, Tân Bình', 1994),
('KH92', 'Lý Văn Sang', 'sang.lv@mail.com', '0921000072', '90 Lý Thường Kiệt, Q.10', 1999),
('KH93', 'Phạm Thị Thúy', 'thuy.pt@mail.com', '0921000073', '66 Thành Thái, Q.10', 1987),
('KH94', 'Vũ Minh Anh', 'anh.vm@mail.com', '0921000074', '140 Lạc Long Quân, Tân Bình', 1998),
('KH95', 'Hoàng Văn Trung', 'trung.hv@mail.com', '0921000075', '20 Phan Đăng Lưu, Phú Nhuận', 1990),
('KH96', 'Đinh Ngọc Ánh', 'anh.dn@mail.com', '0921000076', '45 Nguyễn Chí Thanh, Q.5', 2001),
('KH97', 'Bùi Văn Hậu', 'hau.bv@mail.com', '0921000077', '19 Phạm Văn Đồng, Gò Vấp', 1993),
('KH98', 'Ngô Thùy Linh', 'linh.nt@mail.com', '0921000078', '210 Quang Trung, Gò Vấp', 1996),
('KH99', 'Mai Quốc Việt', 'viet.mq@mail.com', '0921000079', '17 Trường Sa, Bình Thạnh', 1994),
('KH100', 'Tô Văn Tuấn', 'tuan.tv@mail.com', '0921000080', '150 Phan Xích Long, Phú Nhuận', 1997),
('KH101', 'Trần Minh Thư', 'thu.tm@mail.com', '0921000081', '20 Bến Nghé, Q.1', 1995),
('KH102', 'Lê Thị Thu Trang', 'trang.ltt@mail.com', '0921000082', '52 Lý Thường Kiệt, Q.10', 1998),
('KH103', 'Phạm Văn Hùng', 'hung.pv@mail.com', '0921000083', '100 Vĩnh Viễn, Q.10', 1992),
('KH104', 'Vũ Thị Thanh Nga', 'nga.vtt@mail.com', '0921000084', '30 Trường Sa, Phú Nhuận', 1997),
('KH105', 'Hoàng Minh Quân', 'quan.hm@mail.com', '0921000085', '15 CMT8, Q.10', 1990),
('KH106', 'Đinh Hữu Phước', 'phuoc.dh@mail.com', '0921000086', '10 Phan Kế Bính, Q.1', 1995),
('KH107', 'Bùi Văn Đạt', 'dat.bv@mail.com', '0921000087', '25 Nguyễn Thị Minh Khai, Q.3', 1985),
('KH108', 'Ngô Thị Thanh Tâm', 'tam.ntt@mail.com', '0921000088', '88 Trường Sa, Phú Nhuận', 2000),
('KH109', 'Mai Văn Vinh', 'vinh.mv@mail.com', '0921000089', '12 Võ Văn Tần, Q.3', 1992),
('KH110', 'Tô Thị Ngọc Mai', 'mai.ttn@mail.com', '0921000090', '99 Hoàng Diệu, Q.4', 1997),
('KH111', 'Trần Văn Phú', 'phu.tv@mail.com', '0921000091', '55 Bến Vân Đồn, Q.4', 1988),
('KH112', 'Lý Thị Hồng Vân', 'van.lth@mail.com', '0921000092', '115 Trần Hưng Đạo, Q.5', 1993),
('KH113', 'Phạm Minh Hải', 'hai.pm@mail.com', '0921000093', '33 Trần Bình Trọng, Q.5', 1996),
('KH114', 'Vũ Thị Thúy An', 'an.vtt@mail.com', '0921000094', '200 Hồng Bàng, Q.6', 1994),
('KH115', 'Hoàng Văn Thắng', 'thang.hv@mail.com', '0921000095', '15 Lê Văn Sỹ, Phú Nhuận', 1991),
('KH116', 'Đinh Minh Nhật', 'nhat.dm@mail.com', '0921000096', '70 Cộng Hòa, Tân Bình', 1994),
('KH117', 'Bùi Thị Loan', 'loan.bt@mail.com', '0921000097', '90 Lý Thường Kiệt, Q.10', 1999),
('KH118', 'Ngô Văn Tùng', 'tung.nv@mail.com', '0921000098', '66 Thành Thái, Q.10', 1987),
('KH119', 'Mai Thị Thu Trang', 'trang.mtt@mail.com', '0921000099', '140 Lạc Long Quân, Tân Bình', 1998),
('KH120', 'Tô Hữu Dũng', 'dung.th@mail.com', '0921000100', '20 Phan Đăng Lưu, Phú Nhuận', 1990);


-- 5. Dữ liệu ORDERS (20 bản ghi mẫu)
INSERT INTO `orders` (`order_id`, `customer_id`, `customer_name`, `customer_phone`, `order_date`, `completed_date`, `order_type`, `total_amount`, `shipping_fee`, `status`, `payment_method`, `sales_user_id`, `shipper_user_id`) VALUES
('DH001', 'KH1', 'Trần Khôi Nguyên', '0901111111', '2025-10-01 10:30:00', '2025-10-01 11:00:00', 'Direct', 600000.00, 0.00, 'Completed', 'Cash', 'SALES1', NULL),
('DH002', 'KH2', 'Lê Hồng Thu', '0902222222', '2025-10-02 11:00:00', '2025-10-02 11:30:00', 'Direct', 1500000.00, 0.00, 'Completed', 'Card', 'SALES2', NULL),
('DH003', 'KH3', 'Phạm Tấn Lộc', '0903333333', '2025-10-03 12:45:00', '2025-10-03 12:45:00', 'Direct', 400000.00, 0.00, 'Completed', 'Cash', 'SALES3', NULL),
('DH004', 'KH4', 'Vũ Thanh Hằng', '0904444444', '2025-10-04 14:00:00', '2025-10-04 14:00:00', 'Direct', 750000.00, 0.00, 'Completed', 'Card', 'SALES1', NULL),
('DH005', 'KH5', 'Hoàng Văn Minh', '0905555555', '2025-10-05 09:15:00', '2025-10-05 09:15:00', 'Direct', 250000.00, 0.00, 'Completed', 'Transfer', 'SALES2', NULL),
('DH006', 'KH6', 'Đào Thị Kiều', '0906666666', '2025-10-06 16:30:00', '2025-10-06 16:30:00', 'Direct', 900000.00, 0.00, 'Completed', 'Cash', 'SALES3', NULL),
('DH007', 'KH7', 'Bùi Chí Tín', '0907777777', '2025-10-11 09:00:00', '2025-10-14 10:00:00', 'Online', 730000.00, 30000.00, 'Completed', 'COD', 'OS1', 'SHIP1'),
('DH008', 'KH8', 'Nguyễn Thanh Nga', '0908888888', '2025-10-12 11:10:00', '2025-10-15 11:10:00', 'Online', 630000.00, 30000.00, 'Completed', 'Transfer', 'OS2', 'SHIP2'),
('DH009', 'KH9', 'Mai Đức Phú', '0909999999', '2025-10-13 14:20:00', '2025-10-16 14:20:00', 'Online', 1840000.00, 40000.00, 'Completed', 'COD', 'OS3', 'SHIP1'),
('DH010', 'KH10', 'Tô Thị Yến', '0910000000', '2025-10-14 10:40:00', '2025-10-17 10:40:00', 'Online', 575000.00, 25000.00, 'Completed', 'COD', 'OS4', 'SHIP2'),
('DH011', 'KH11', 'Trần Văn Tùng', '0911111111', '2025-10-15 15:50:00', '2025-10-19 15:50:00', 'Online', 150000.00, 30000.00, 'Completed', 'Transfer', 'OS5', 'SHIP3'),
('DH012', 'KH12', 'Lý Thị Mỹ', '0912222222', '2025-10-16 12:15:00', '2025-10-19 12:15:00', 'Online', 320000.00, 30000.00, 'Completed', 'COD', 'OS6', 'SHIP4'),
('DH013', 'KH13', 'Phạm Ngọc Duy', '0913333333', '2025-10-17 17:00:00', '2025-10-20 17:00:00', 'Online', 780000.00, 30000.00, 'Completed', 'Transfer', 'OS1', 'SHIP1'),
('DH014', 'KH14', 'Vũ Thị Thanh', '0914444444', '2025-10-18 09:45:00', '2025-10-21 09:45:00', 'Online', 480000.00, 30000.00, 'Completed', 'COD', 'OS2', 'SHIP5'),
('DH015', 'KH15', 'Hoàng Anh Tuấn', '0915555555', '2025-10-19 13:30:00', '2025-10-22 13:30:00', 'Online', 980000.00, 30000.00, 'Completed', 'Transfer', 'OS3', 'SHIP1'),
('DH016', 'KH16', 'Đinh Gia Bảo', '0916666666', '2025-10-20 16:00:00', '2025-10-23 16:00:00', 'Online', 350000.00, 30000.00, 'Completed', 'COD', 'OS4', 'SHIP2'),
('DH017', 'KH17', 'Bùi Việt Đức', '0917777777', '2025-10-21 10:00:00', '2025-10-21 10:00:00', 'Direct', 180000.00, 0.00, 'Completed', 'Cash', 'SALES4', NULL),
('DH018', 'KH18', 'Ngô Thanh Hà', '0918888888', '2025-10-22 11:30:00', '2025-10-22 11:30:00', 'Direct', 1200000.00, 0.00, 'Completed', 'Card', 'SALES5', NULL),
('DH019', 'KH19', 'Mai Văn Thắng', '0919999999', '2025-10-23 13:00:00', '2025-10-23 13:00:00', 'Direct', 480000.00, 0.00, 'Completed', 'Transfer', 'SALES6', NULL),
('DH020', 'KH20', 'Tô Hải Đăng', '0920000000', '2025-10-24 15:00:00', '2025-10-24 15:00:00', 'Direct', 380000.00, 0.00, 'Completed', 'Cash', 'SALES7', NULL);


-- 6. Dữ liệu ORDER_DETAILS (25 bản ghi mẫu)
INSERT INTO `order_details` (`order_id`, `product_id`, `quantity`, `price_at_order`) VALUES
('DH001', 'SP1', 4, 150000.00),
('DH002', 'SP4', 1, 950000.00),
('DH002', 'SP9', 1, 400000.00),
('DH003', 'SP9', 1, 400000.00),
('DH004', 'SP11', 1, 750000.00),
('DH005', 'SP1', 1, 150000.00),
('DH005', 'SP15', 1, 100000.00),
('DH006', 'SP10', 1, 850000.00),
('DH006', 'SP15', 1, 50000.00),
('DH007', 'SP3', 1, 700000.00),
('DH008', 'SP5', 1, 600000.00),
('DH009', 'SP14', 1, 1800000.00),
('DH010', 'SP17', 1, 550000.00),
('DH011', 'SP15', 1, 120000.00),
('DH012', 'SP19', 1, 290000.00),
('DH013', 'SP11', 1, 750000.00),
('DH014', 'SP2', 1, 450000.00),
('DH015', 'SP4', 1, 950000.00),
('DH016', 'SP6', 1, 320000.00),
('DH017', 'SP16', 1, 180000.00),
('DH018', 'SP7', 1, 1200000.00),
('DH019', 'SP12', 1, 480000.00),
('DH020', 'SP20', 1, 380000.00),
('DH013', 'SP8', 1, 30000.00),
('DH013', 'SP18', 1, 30000.00);


-- 7. Dữ liệu STOCK_IN (5 Phiếu nhập mẫu)
INSERT INTO `stock_in` (`stock_in_id`, `supplier_name`, `import_date`, `total_cost`, `user_id`) VALUES
('NK01', 'NCC A - Tổng hợp', '2025-09-25 10:00:00', 15000000.00, 'WH1'),
('NK02', 'NCC B - Phụ kiện', '2025-10-05 14:00:00', 5000000.00, 'WH2'),
('NK03', 'NCC C - Giày dép', '2025-10-10 09:00:00', 10000000.00, 'WH3'),
('NK04', 'NCC D - Áo khoác', '2025-11-01 11:00:00', 8000000.00, 'WH4'),
('NK05', 'NCC E - Mỹ phẩm', '2025-11-15 15:00:00', 24000000.00, 'WH5');


-- 8. Dữ liệu STOCK_IN_DETAILS (15 bản ghi mẫu)
INSERT INTO `stock_in_details` (`stock_in_id`, `product_id`, `quantity`, `cost_price`) VALUES
('NK01', 'SP1', 100, 80000.00),
('NK01', 'SP2', 50, 250000.00),
('NK01', 'SP6', 50, 150000.00),
('NK02', 'SP15', 100, 50000.00),
('NK02', 'SP8', 50, 150000.00),
('NK03', 'SP3', 20, 400000.00),
('NK03', 'SP20', 30, 200000.00),
('NK04', 'SP11', 40, 400000.00),
('NK04', 'SP19', 40, 140000.00),
('NK05', 'SP14', 20, 1200000.00),
('NK05', 'SP17', 10, 300000.00),
('NK05', 'SP4', 5, 550000.00),
('NK05', 'SP13', 5, 1000000.00),
('NK05', 'SP7', 2, 800000.00),
('NK05', 'SP9', 2, 200000.00);


-- 9. Dữ liệu SALARIES (29 bản ghi - Lương tháng 10/2025)
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

---
## 3. CHÈN DỮ LIỆU BỔ SUNG: 200 ORDERS
---
-- Tổng cộng 200 đơn hàng mới, trong đó 120 đơn (DH021-DH140) phân bổ 10 bản ghi/tháng trong 12 tháng
-- 1. 10 Orders/Tháng (120 bản ghi) từ 2024-11-19 đến 2025-11-18

INSERT INTO `orders` (`order_id`, `customer_id`, `customer_name`, `customer_phone`, `order_date`, `completed_date`, `order_type`, `total_amount`, `shipping_fee`, `status`, `payment_method`, `sales_user_id`, `shipper_user_id`) VALUES
-- Tháng 11/2024 (10 bản ghi: DH021 - DH030)
('DH021', 'KH22', 'Trần Thị Mai', '0921000002', '2024-11-19 15:20:00', '2024-11-23 15:20:00', 'Online', 650000.00, 30000.00, 'Completed', 'COD', 'OS1', 'SHIP1'),
('DH022', 'KH85', 'Hoàng Thị Tuyết', '0921000065', '2024-11-20 10:05:00', '2024-11-20 10:05:00', 'Direct', 750000.00, 0.00, 'Completed', 'Card', 'SALES10', NULL),
('DH023', 'KH101', 'Trần Minh Thư', '0921000081', '2024-11-21 11:45:00', '2024-11-21 11:45:00', 'Direct', 400000.00, 0.00, 'Completed', 'Cash', 'SALES5', NULL),
('DH024', 'KH34', 'Vũ Thu Trang', '0921000014', '2024-11-22 14:30:00', '2024-11-26 14:30:00', 'Online', 1580000.00, 30000.00, 'Completed', 'Transfer', 'OS8', 'SHIP5'),
('DH025', 'KH115', 'Hoàng Văn Thắng', '0921000095', '2024-11-23 16:10:00', '2024-11-23 16:10:00', 'Direct', 1400000.00, 0.00, 'Completed', 'COD', 'SALES6', NULL), -- Direct order - COD/Cash/Card/Transfer OK
('DH026', 'KH47', 'Bùi Ngọc Hùng', '0921000027', '2024-11-24 10:50:00', '2024-11-27 10:50:00', 'Online', 900000.00, 30000.00, 'Completed', 'Transfer', 'OS5', 'SHIP3'),
('DH027', 'KH56', 'Đinh Thanh Hải', '0921000036', '2024-11-25 09:25:00', '2024-11-25 09:25:00', 'Direct', 870000.00, 0.00, 'Completed', 'Cash', 'SALES7', NULL),
('DH028', 'KH70', 'Tô Văn Hùng', '0921000050', '2024-11-26 12:15:00', '2024-11-29 12:15:00', 'Online', 150000.00, 30000.00, 'Completed', 'COD', 'OS7', 'SHIP4'),
('DH029', 'KH82', 'Lê Thị Thuý', '0921000062', '2024-11-27 14:55:00', '2024-11-27 14:55:00', 'Direct', 700000.00, 0.00, 'Completed', 'Card', 'SALES1', NULL),
('DH030', 'KH109', 'Mai Văn Vinh', '0921000089', '2024-11-28 17:35:00', '2024-12-01 17:35:00', 'Online', 180000.00, 30000.00, 'Completed', 'Transfer', 'OS2', 'SHIP1'),

-- Tháng 12/2024 (10 bản ghi: DH031 - DH040)
('DH031', 'KH44', 'Vũ Thị Thanh Hương', '0921000024', '2024-12-01 09:00:00', '2024-12-04 09:00:00', 'Online', 480000.00, 30000.00, 'Completed', 'COD', 'OS4', 'SHIP2'),
('DH032', 'KH15', 'Hoàng Anh Tuấn', '0915555555', '2024-12-03 11:30:00', '2024-12-03 11:30:00', 'Direct', 1230000.00, 0.00, 'Completed', 'Transfer', 'SALES8', NULL),
('DH033', 'KH99', 'Mai Quốc Việt', '0921000079', '2024-12-05 15:40:00', '2024-12-05 15:40:00', 'Direct', 600000.00, 0.00, 'Completed', 'Cash', 'SALES3', NULL),
('DH034', 'KH66', 'Đào Thị Hồng', '0921000046', '2024-12-07 19:10:00', '2024-12-10 19:10:00', 'Online', 980000.00, 30000.00, 'Completed', 'COD', 'OS6', 'SHIP5'),
('DH035', 'KH120', 'Tô Hữu Dũng', '0921000100', '2024-12-09 08:40:00', '2024-12-09 08:40:00', 'Direct', 380000.00, 0.00, 'Completed', 'Card', 'SALES4', NULL),
('DH036', 'KH27', 'Đinh Công Lý', '0921000007', '2024-12-11 13:20:00', '2024-12-14 13:20:00', 'Online', 1200000.00, 20000.00, 'Completed', 'Transfer', 'OS8', 'SHIP1'),
('DH037', 'KH53', 'Phạm Văn Thành', '0921000033', '2024-12-13 16:50:00', '2024-12-13 16:50:00', 'Direct', 150000.00, 0.00, 'Completed', 'Cash', 'SALES1', NULL),
('DH038', 'KH75', 'Hoàng Thị Yến', '0921000055', '2024-12-15 10:10:00', '2024-12-18 10:10:00', 'Online', 640000.00, 30000.00, 'Completed', 'COD', 'OS2', 'SHIP2'),
('DH039', 'KH88', 'Nguyễn Hữu Trí', '0921000068', '2024-12-17 12:45:00', '2024-12-17 12:45:00', 'Direct', 290000.00, 0.00, 'Completed', 'Card', 'SALES9', NULL),
('DH040', 'KH104', 'Vũ Thị Thanh Nga', '0921000084', '2024-12-18 14:20:00', '2024-12-18 14:20:00', 'Direct', 850000.00, 0.00, 'Completed', 'Cash', 'SALES10', NULL),

-- Tháng 01/2025 (10 bản ghi: DH041 - DH050)
('DH041', 'KH3', 'Phạm Tấn Lộc', '0903333333', '2025-01-01 17:00:00', '2025-01-04 17:00:00', 'Online', 1500000.00, 40000.00, 'Completed', 'Transfer', 'OS3', 'SHIP3'),
('DH042', 'KH111', 'Trần Văn Phú', '0921000091', '2025-01-03 09:30:00', '2025-01-03 09:30:00', 'Direct', 150000.00, 0.00, 'Completed', 'Cash', 'SALES4', NULL),
('DH043', 'KH59', 'Mai Văn Tín', '0921000039', '2025-01-05 11:50:00', '2025-01-08 11:50:00', 'Online', 450000.00, 30000.00, 'Completed', 'COD', 'OS5', 'SHIP4'),
('DH044', 'KH93', 'Phạm Thị Thúy', '0921000073', '2025-01-07 13:40:00', '2025-01-07 13:40:00', 'Direct', 700000.00, 0.00, 'Completed', 'Card', 'SALES5', NULL),
('DH045', 'KH18', 'Ngô Thanh Hà', '0918888888', '2025-01-09 15:55:00', '2025-01-12 15:55:00', 'Online', 280000.00, 30000.00, 'Completed', 'Transfer', 'OS7', 'SHIP1'),
('DH046', 'KH36', 'Đinh Thanh Tùng', '0921000016', '2025-01-11 10:20:00', '2025-01-11 10:20:00', 'Direct', 1200000.00, 0.00, 'Completed', 'Cash', 'SALES6', NULL),
('DH047', 'KH77', 'Bùi Thị Kim', '0921000057', '2025-01-13 12:40:00', '2025-01-16 12:40:00', 'Online', 400000.00, 30000.00, 'Completed', 'COD', 'OS2', 'SHIP2'),
('DH048', 'KH103', 'Phạm Văn Hùng', '0921000083', '2025-01-15 14:35:00', '2025-01-15 14:35:00', 'Direct', 600000.00, 0.00, 'Completed', 'Transfer', 'SALES7', NULL),
('DH049', 'KH42', 'Lê Kim Oanh', '0921000022', '2025-01-17 16:15:00', '2025-01-20 16:15:00', 'Online', 150000.00, 20000.00, 'Completed', 'COD', 'OS4', 'SHIP3'),
('DH050', 'KH68', 'Nguyễn Thị Thúy', '0921000048', '2025-01-18 09:00:00', '2025-01-18 09:00:00', 'Direct', 550000.00, 0.00, 'Completed', 'Cash', 'SALES8', NULL),

-- Tháng 02/2025 (10 bản ghi: DH051 - DH060)
('DH051', 'KH90', 'Tô Hữu Phước', '0921000070', '2025-02-01 11:20:00', '2025-02-04 11:20:00', 'Online', 1530000.00, 30000.00, 'Completed', 'Transfer', 'OS6', 'SHIP4'),
('DH052', 'KH117', 'Bùi Thị Loan', '0921000097', '2025-02-03 13:40:00', '2025-02-03 13:40:00', 'Direct', 950000.00, 0.00, 'Completed', 'Card', 'SALES9', NULL),
('DH053', 'KH25', 'Vũ Đình Khang', '0921000005', '2025-02-05 15:50:00', '2025-02-08 15:50:00', 'Online', 480000.00, 30000.00, 'Completed', 'COD', 'OS8', 'SHIP5'),
('DH054', 'KH49', 'Mai Chí Tôn', '0921000029', '2025-02-07 10:10:00', '2025-02-07 10:10:00', 'Direct', 600000.00, 0.00, 'Completed', 'Transfer', 'SALES10', NULL),
('DH055', 'KH71', 'Trần Thị Tuyết', '0921000051', '2025-02-09 12:35:00', '2025-02-12 12:35:00', 'Online', 380000.00, 30000.00, 'Completed', 'Transfer', 'OS1', 'SHIP1'),
('DH056', 'KH95', 'Hoàng Văn Trung', '0921000075', '2025-02-11 14:20:00', '2025-02-11 14:20:00', 'Direct', 120000.00, 0.00, 'Completed', 'Cash', 'SALES1', NULL),
('DH057', 'KH112', 'Lý Thị Hồng Vân', '0921000092', '2025-02-13 16:00:00', '2025-02-16 16:00:00', 'Online', 200000.00, 30000.00, 'Completed', 'COD', 'OS3', 'SHIP2'),
('DH058', 'KH2', 'Lê Hồng Thu', '0902222222', '2025-02-15 09:45:00', '2025-02-15 09:45:00', 'Direct', 750000.00, 0.00, 'Completed', 'Card', 'SALES2', NULL),
('DH059', 'KH29', 'Nguyễn Tấn Tài', '0921000009', '2025-02-16 11:25:00', '2025-02-19 11:25:00', 'Online', 150000.00, 30000.00, 'Completed', 'Transfer', 'OS5', 'SHIP3'),
('DH060', 'KH40', 'Tô Minh Hoàng', '0921000020', '2025-02-18 13:50:00', '2025-02-18 13:50:00', 'Direct', 950000.00, 0.00, 'Completed', 'Cash', 'SALES3', NULL),

-- Tháng 03/2025 (10 bản ghi: DH061 - DH070)
('DH061', 'KH63', 'Phạm Ngọc Thắng', '0921000043', '2025-03-01 15:30:00', '2025-03-04 15:30:00', 'Online', 1840000.00, 40000.00, 'Completed', 'COD', 'OS7', 'SHIP4'),
('DH062', 'KH86', 'Đào Quốc Khánh', '0921000066', '2025-03-03 17:10:00', '2025-03-03 17:10:00', 'Direct', 320000.00, 0.00, 'Completed', 'Transfer', 'SALES4', NULL),
('DH063', 'KH107', 'Bùi Văn Đạt', '0921000087', '2025-03-05 09:00:00', '2025-03-08 09:00:00', 'Online', 700000.00, 30000.00, 'Completed', 'COD', 'OS2', 'SHIP5'),
('DH064', 'KH37', 'Bùi Thị Ngọc', '0921000017', '2025-03-07 11:20:00', '2025-03-07 11:20:00', 'Direct', 450000.00, 0.00, 'Completed', 'Card', 'SALES5', NULL),
('DH065', 'KH58', 'Ngô Thu Hiền', '0921000038', '2025-03-09 13:40:00', '2025-03-12 13:40:00', 'Online', 480000.00, 30000.00, 'Completed', 'Transfer', 'OS4', 'SHIP1'),
('DH066', 'KH79', 'Mai Văn Chiến', '0921000059', '2025-03-11 15:20:00', '2025-03-11 15:20:00', 'Direct', 120000.00, 0.00, 'Completed', 'Cash', 'SALES6', NULL),
('DH067', 'KH100', 'Tô Văn Tuấn', '0921000080', '2025-03-13 17:00:00', '2025-03-16 17:00:00', 'Online', 1540000.00, 40000.00, 'Completed', 'COD', 'OS6', 'SHIP2'),
('DH068', 'KH23', 'Lê Hữu Phúc', '0921000003', '2025-03-15 09:10:00', '2025-03-15 09:10:00', 'Direct', 750000.00, 0.00, 'Completed', 'Transfer', 'SALES7', NULL),
('DH069', 'KH45', 'Hoàng Quốc Việt', '0921000025', '2025-03-16 11:30:00', '2025-03-19 11:30:00', 'Online', 570000.00, 20000.00, 'Completed', 'COD', 'OS8', 'SHIP3'),
('DH070', 'KH67', 'Bùi Đức Anh', '0921000047', '2025-03-17 13:50:00', '2025-03-17 13:50:00', 'Direct', 850000.00, 0.00, 'Completed', 'Cash', 'SALES9', NULL),

-- Tháng 04/2025 (10 bản ghi: DH071 - DH080)
('DH071', 'KH89', 'Mai Thanh Liêm', '0921000069', '2025-04-01 10:25:00', '2025-04-04 10:25:00', 'Online', 630000.00, 30000.00, 'Completed', 'Transfer', 'OS1', 'SHIP4'),
('DH072', 'KH113', 'Phạm Minh Hải', '0921000093', '2025-04-03 12:45:00', '2025-04-03 12:45:00', 'Direct', 180000.00, 0.00, 'Completed', 'Card', 'SALES10', NULL),
('DH073', 'KH50', 'Tô Thanh Thảo', '0921000030', '2025-04-05 14:30:00', '2025-04-08 14:30:00', 'Online', 480000.00, 30000.00, 'Completed', 'COD', 'OS3', 'SHIP5'),
('DH074', 'KH72', 'Lý Văn Khoa', '0921000052', '2025-04-07 16:15:00', '2025-04-07 16:15:00', 'Direct', 700000.00, 0.00, 'Completed', 'Cash', 'SALES1', NULL),
('DH075', 'KH96', 'Đinh Ngọc Ánh', '0921000076', '2025-04-09 09:30:00', '2025-04-12 09:30:00', 'Online', 1240000.00, 40000.00, 'Completed', 'Transfer', 'OS5', 'SHIP1'),
('DH076', 'KH119', 'Mai Thị Thu Trang', '0921000099', '2025-04-11 11:50:00', '2025-04-11 11:50:00', 'Direct', 380000.00, 0.00, 'Completed', 'Card', 'SALES2', NULL),
('DH077', 'KH5', 'Hoàng Văn Minh', '0905555555', '2025-04-13 13:40:00', '2025-04-16 13:40:00', 'Online', 980000.00, 30000.00, 'Completed', 'COD', 'OS7', 'SHIP2'),
('DH078', 'KH24', 'Phạm Thanh Thảo', '0921000004', '2025-04-15 15:20:00', '2025-04-15 15:20:00', 'Direct', 600000.00, 0.00, 'Completed', 'Cash', 'SALES3', NULL),
('DH079', 'KH46', 'Đào Duy Anh', '0921000026', '2025-04-16 17:00:00', '2025-04-19 17:00:00', 'Online', 450000.00, 30000.00, 'Completed', 'Transfer', 'OS2', 'SHIP3'),
('DH080', 'KH69', 'Mai Thị Phương', '0921000049', '2025-04-17 09:10:00', '2025-04-17 09:10:00', 'Direct', 150000.00, 0.00, 'Completed', 'Card', 'SALES4', NULL),

-- Tháng 05/2025 (10 bản ghi: DH081 - DH090)
('DH081', 'KH91', 'Trần Thanh Nam', '0921000071', '2025-05-01 11:30:00', '2025-05-04 11:30:00', 'Online', 770000.00, 20000.00, 'Completed', 'COD', 'OS4', 'SHIP4'),
('DH082', 'KH114', 'Vũ Thị Thúy An', '0921000094', '2025-05-03 13:50:00', '2025-05-03 13:50:00', 'Direct', 1500000.00, 0.00, 'Completed', 'Cash', 'SALES5', NULL),
('DH083', 'KH26', 'Hoàng Bảo Vy', '0921000006', '2025-05-05 15:30:00', '2025-05-08 15:30:00', 'Online', 660000.00, 30000.00, 'Completed', 'Transfer', 'OS6', 'SHIP5'),
('DH084', 'KH48', 'Nguyễn Thị Thu', '0921000028', '2025-05-07 17:10:00', '2025-05-07 17:10:00', 'Direct', 400000.00, 0.00, 'Completed', 'Card', 'SALES6', NULL),
('DH085', 'KH70', 'Tô Văn Hùng', '0921000050', '2025-05-09 09:00:00', '2025-05-12 09:00:00', 'Online', 1840000.00, 40000.00, 'Completed', 'COD', 'OS8', 'SHIP1'),
('DH086', 'KH92', 'Lý Văn Sang', '0921000072', '2025-05-11 11:20:00', '2025-05-11 11:20:00', 'Direct', 480000.00, 0.00, 'Completed', 'Cash', 'SALES7', NULL),
('DH087', 'KH116', 'Đinh Minh Nhật', '0921000096', '2025-05-13 10:20:00', '2025-05-16 10:20:00', 'Online', 350000.00, 30000.00, 'Completed', 'Transfer', 'OS1', 'SHIP2'),
('DH088', 'KH21', 'Nguyễn Văn Đạt', '0921000001', '2025-05-15 12:35:00', '2025-05-15 12:35:00', 'Direct', 750000.00, 0.00, 'Completed', 'Card', 'SALES8', NULL),
('DH089', 'KH43', 'Phạm Văn Dũng', '0921000023', '2025-05-17 14:15:00', '2025-05-20 14:15:00', 'Online', 630000.00, 30000.00, 'Completed', 'COD', 'OS3', 'SHIP3'),
('DH090', 'KH65', 'Hoàng Minh Đức', '0921000045', '2025-05-18 16:00:00', '2025-05-18 16:00:00', 'Direct', 280000.00, 0.00, 'Completed', 'Cash', 'SALES9', NULL),

-- Tháng 06/2025 (10 bản ghi: DH091 - DH100)
('DH091', 'KH87', 'Bùi Thị Lan', '0921000067', '2025-06-01 09:20:00', '2025-06-04 09:20:00', 'Online', 570000.00, 20000.00, 'Completed', 'Transfer', 'OS5', 'SHIP4'),
('DH092', 'KH110', 'Tô Thị Ngọc Mai', '0921000090', '2025-06-03 11:40:00', '2025-06-03 11:40:00', 'Direct', 150000.00, 0.00, 'Completed', 'Card', 'SALES10', NULL),
('DH093', 'KH28', 'Bùi Thị Hà', '0921000008', '2025-06-05 13:30:00', '2025-06-08 13:30:00', 'Online', 730000.00, 30000.00, 'Completed', 'COD', 'OS7', 'SHIP5'),
('DH094', 'KH51', 'Trần Minh Quang', '0921000031', '2025-06-07 15:15:00', '2025-06-07 15:15:00', 'Direct', 450000.00, 0.00, 'Completed', 'Cash', 'SALES1', NULL),
('DH095', 'KH73', 'Phạm Duy Nam', '0921000053', '2025-06-09 17:00:00', '2025-06-12 17:00:00', 'Online', 1840000.00, 40000.00, 'Completed', 'Transfer', 'OS2', 'SHIP1'),
('DH096', 'KH94', 'Vũ Minh Anh', '0921000074', '2025-06-11 09:05:00', '2025-06-11 09:05:00', 'Direct', 480000.00, 0.00, 'Completed', 'Card', 'SALES2', NULL),
('DH097', 'KH118', 'Ngô Văn Tùng', '0921000098', '2025-06-13 11:25:00', '2025-06-16 11:25:00', 'Online', 150000.00, 30000.00, 'Completed', 'COD', 'OS4', 'SHIP2'),
('DH098', 'KH30', 'Mai Thị Kim', '0921000010', '2025-06-15 13:45:00', '2025-06-15 13:45:00', 'Direct', 750000.00, 0.00, 'Completed', 'Cash', 'SALES3', NULL),
('DH099', 'KH52', 'Lý Kim Ngân', '0921000032', '2025-06-16 15:30:00', '2025-06-19 15:30:00', 'Online', 630000.00, 30000.00, 'Completed', 'Transfer', 'OS6', 'SHIP3'),
('DH100', 'KH74', 'Vũ Văn Long', '0921000054', '2025-06-17 17:10:00', '2025-06-17 17:10:00', 'Direct', 400000.00, 0.00, 'Completed', 'Card', 'SALES4', NULL),

-- Tháng 07/2025 (10 bản ghi: DH101 - DH110)
('DH101', 'KH97', 'Bùi Văn Hậu', '0921000077', '2025-07-01 09:00:00', '2025-07-04 09:00:00', 'Online', 480000.00, 30000.00, 'Completed', 'COD', 'OS8', 'SHIP4'),
('DH102', 'KH10', 'Tô Thị Yến', '0910000000', '2025-07-03 11:20:00', '2025-07-03 11:20:00', 'Direct', 1500000.00, 0.00, 'Completed', 'Cash', 'SALES5', NULL),
('DH103', 'KH32', 'Lý Ngọc Lan', '0921000012', '2025-07-05 13:40:00', '2025-07-08 13:40:00', 'Online', 730000.00, 30000.00, 'Completed', 'Transfer', 'OS1', 'SHIP5'),
('DH104', 'KH54', 'Vũ Thị Mai', '0921000034', '2025-07-07 15:30:00', '2025-07-07 15:30:00', 'Direct', 600000.00, 0.00, 'Completed', 'Card', 'SALES6', NULL),
('DH105', 'KH76', 'Đinh Văn Công', '0921000056', '2025-07-09 10:20:00', '2025-07-12 10:20:00', 'Online', 180000.00, 30000.00, 'Completed', 'COD', 'OS3', 'SHIP1'),
('DH106', 'KH98', 'Ngô Thùy Linh', '0921000078', '2025-07-11 12:35:00', '2025-07-11 12:35:00', 'Direct', 750000.00, 0.00, 'Completed', 'Cash', 'SALES7', NULL),
('DH107', 'KH120', 'Tô Hữu Dũng', '0921000100', '2025-07-13 14:15:00', '2025-07-16 14:15:00', 'Online', 990000.00, 40000.00, 'Completed', 'Transfer', 'OS5', 'SHIP2'),
('DH108', 'KH23', 'Lê Hữu Phúc', '0921000003', '2025-07-15 16:00:00', '2025-07-15 16:00:00', 'Direct', 380000.00, 0.00, 'Completed', 'Card', 'SALES8', NULL),
('DH109', 'KH45', 'Hoàng Quốc Việt', '0921000025', '2025-07-17 09:20:00', '2025-07-20 09:20:00', 'Online', 1230000.00, 30000.00, 'Completed', 'COD', 'OS7', 'SHIP3'),
('DH110', 'KH67', 'Bùi Đức Anh', '0921000047', '2025-07-18 11:40:00', '2025-07-18 11:40:00', 'Direct', 400000.00, 0.00, 'Completed', 'Cash', 'SALES9', NULL),

-- Tháng 08/2025 (10 bản ghi: DH111 - DH120)
('DH111', 'KH89', 'Mai Thanh Liêm', '0921000069', '2025-08-01 13:30:00', '2025-08-04 13:30:00', 'Online', 480000.00, 30000.00, 'Completed', 'Transfer', 'OS2', 'SHIP4'),
('DH112', 'KH111', 'Trần Văn Phú', '0921000091', '2025-08-03 15:15:00', '2025-08-03 15:15:00', 'Direct', 150000.00, 0.00, 'Completed', 'Card', 'SALES10', NULL),
('DH113', 'KH24', 'Phạm Thanh Thảo', '0921000004', '2025-08-05 17:00:00', '2025-08-08 17:00:00', 'Online', 780000.00, 30000.00, 'Completed', 'COD', 'OS4', 'SHIP5'),
('DH114', 'KH46', 'Đào Duy Anh', '0921000026', '2025-08-07 09:05:00', '2025-08-07 09:05:00', 'Direct', 600000.00, 0.00, 'Completed', 'Cash', 'SALES1', NULL),
('DH115', 'KH68', 'Nguyễn Thị Thúy', '0921000048', '2025-08-09 11:25:00', '2025-08-12 11:25:00', 'Online', 350000.00, 20000.00, 'Completed', 'Transfer', 'OS6', 'SHIP1'),
('DH116', 'KH90', 'Tô Hữu Phước', '0921000070', '2025-08-11 13:45:00', '2025-08-11 13:45:00', 'Direct', 950000.00, 0.00, 'Completed', 'Card', 'SALES2', NULL),
('DH117', 'KH112', 'Lý Thị Hồng Vân', '0921000092', '2025-08-13 15:30:00', '2025-08-16 15:30:00', 'Online', 480000.00, 30000.00, 'Completed', 'COD', 'OS8', 'SHIP2'),
('DH118', 'KH25', 'Vũ Đình Khang', '0921000005', '2025-08-15 17:10:00', '2025-08-15 17:10:00', 'Direct', 700000.00, 0.00, 'Completed', 'Cash', 'SALES3', NULL),
('DH119', 'KH47', 'Bùi Ngọc Hùng', '0921000027', '2025-08-16 09:00:00', '2025-08-19 09:00:00', 'Online', 1530000.00, 40000.00, 'Completed', 'Transfer', 'OS1', 'SHIP3'),
('DH120', 'KH69', 'Mai Thị Phương', '0921000049', '2025-08-17 11:20:00', '2025-08-17 11:20:00', 'Direct', 480000.00, 0.00, 'Completed', 'Card', 'SALES4', NULL),

-- Tháng 09/2025 (10 bản ghi: DH121 - DH130)
('DH121', 'KH91', 'Trần Thanh Nam', '0921000071', '2025-09-01 10:20:00', '2025-09-04 10:20:00', 'Online', 630000.00, 30000.00, 'Completed', 'COD', 'OS3', 'SHIP4'),
('DH122', 'KH113', 'Phạm Minh Hải', '0921000093', '2025-09-03 12:35:00', '2025-09-03 12:35:00', 'Direct', 180000.00, 0.00, 'Completed', 'Cash', 'SALES5', NULL),
('DH123', 'KH26', 'Hoàng Bảo Vy', '0921000006', '2025-09-05 14:15:00', '2025-09-08 14:15:00', 'Online', 780000.00, 30000.00, 'Completed', 'Transfer', 'OS5', 'SHIP5'),
('DH124', 'KH48', 'Nguyễn Thị Thu', '0921000028', '2025-09-07 16:00:00', '2025-09-07 16:00:00', 'Direct', 380000.00, 0.00, 'Completed', 'Card', 'SALES6', NULL),
('DH125', 'KH70', 'Tô Văn Hùng', '0921000050', '2025-09-09 09:20:00', '2025-09-12 09:20:00', 'Online', 480000.00, 30000.00, 'Completed', 'COD', 'OS7', 'SHIP1'),
('DH126', 'KH92', 'Lý Văn Sang', '0921000072', '2025-09-11 11:40:00', '2025-09-11 11:40:00', 'Direct', 1200000.00, 0.00, 'Completed', 'Cash', 'SALES7', NULL),
('DH127', 'KH114', 'Vũ Thị Thúy An', '0921000094', '2025-09-13 13:30:00', '2025-09-16 13:30:00', 'Online', 430000.00, 30000.00, 'Completed', 'Transfer', 'OS2', 'SHIP2'),
('DH128', 'KH28', 'Bùi Thị Hà', '0921000008', '2025-09-15 15:15:00', '2025-09-15 15:15:00', 'Direct', 150000.00, 0.00, 'Completed', 'Card', 'SALES8', NULL),
('DH129', 'KH50', 'Tô Thanh Thảo', '0921000030', '2025-09-16 17:00:00', '2025-09-19 17:00:00', 'Online', 780000.00, 30000.00, 'Completed', 'COD', 'OS4', 'SHIP3'),
('DH130', 'KH72', 'Lý Văn Khoa', '0921000052', '2025-09-17 09:05:00', '2025-09-17 09:05:00', 'Direct', 600000.00, 0.00, 'Completed', 'Cash', 'SALES9', NULL),

-- Tháng 10/2025 (10 bản ghi: DH131 - DH140)
('DH131', 'KH94', 'Vũ Minh Anh', '0921000074', '2025-10-25 10:20:00', '2025-10-28 10:20:00', 'Online', 990000.00, 40000.00, 'Completed', 'Transfer', 'OS6', 'SHIP4'),
('DH132', 'KH116', 'Đinh Minh Nhật', '0921000096', '2025-10-26 12:35:00', '2025-10-26 12:35:00', 'Direct', 450000.00, 0.00, 'Completed', 'Card', 'SALES10', NULL),
('DH133', 'KH21', 'Nguyễn Văn Đạt', '0921000001', '2025-10-27 14:15:00', '2025-10-30 14:15:00', 'Online', 350000.00, 30000.00, 'Completed', 'COD', 'OS8', 'SHIP5'),
('DH134', 'KH43', 'Phạm Văn Dũng', '0921000023', '2025-10-28 16:00:00', '2025-10-28 16:00:00', 'Direct', 700000.00, 0.00, 'Completed', 'Cash', 'SALES1', NULL),
('DH135', 'KH65', 'Hoàng Minh Đức', '0921000045', '2025-10-29 09:20:00', '2025-11-01 09:20:00', 'Online', 1840000.00, 40000.00, 'Completed', 'Transfer', 'OS1', 'SHIP1'),
('DH136', 'KH87', 'Bùi Thị Lan', '0921000067', '2025-10-30 11:40:00', '2025-10-30 11:40:00', 'Direct', 480000.00, 0.00, 'Completed', 'Card', 'SALES2', NULL),
('DH137', 'KH110', 'Tô Thị Ngọc Mai', '0921000090', '2025-10-31 13:30:00', '2025-11-03 13:30:00', 'Online', 150000.00, 30000.00, 'Completed', 'COD', 'OS3', 'SHIP2'),
('DH138', 'KH30', 'Mai Thị Kim', '0921000010', '2025-11-01 10:20:00', '2025-11-01 10:20:00', 'Direct', 750000.00, 0.00, 'Completed', 'Cash', 'SALES3', NULL),
('DH139', 'KH52', 'Lý Kim Ngân', '0921000032', '2025-11-02 12:35:00', '2025-11-05 12:35:00', 'Online', 480000.00, 30000.00, 'Completed', 'Transfer', 'OS5', 'SHIP3'),
('DH140', 'KH74', 'Vũ Văn Long', '0921000054', '2025-11-03 14:15:00', '2025-11-03 14:15:00', 'Direct', 380000.00, 0.00, 'Completed', 'Card', 'SALES4', NULL),

-- 2. 80 Orders còn lại (DH141 -> DH220) - Phân bổ ngẫu nhiên trong 12 tháng
-- Các đơn này dùng để lấp đầy số lượng 200 bản ghi Orders bổ sung.

('DH141', 'KH96', 'Đinh Ngọc Ánh', '0921000076', '2024-11-20 18:00:00', '2024-11-24 18:00:00', 'Online', 1240000.00, 40000.00, 'Completed', 'COD', 'OS7', 'SHIP4'),
('DH142', 'KH118', 'Ngô Văn Tùng', '0921000098', '2024-12-04 10:30:00', '2024-12-04 10:30:00', 'Direct', 600000.00, 0.00, 'Completed', 'Cash', 'SALES5', NULL),
('DH143', 'KH32', 'Lý Ngọc Lan', '0921000012', '2024-12-19 14:45:00', '2024-12-22 14:45:00', 'Online', 630000.00, 30000.00, 'Completed', 'Transfer', 'OS8', 'SHIP5'),
('DH144', 'KH54', 'Vũ Thị Mai', '0925555555', '2025-01-08 18:00:00', '2025-01-08 18:00:00', 'Direct', 400000.00, 0.00, 'Completed', 'Card', 'SALES6', NULL),
('DH145', 'KH76', 'Đinh Văn Công', '0921000056', '2025-01-22 10:00:00', '2025-01-25 10:00:00', 'Online', 480000.00, 30000.00, 'Completed', 'COD', 'OS1', 'SHIP1'),
('DH146', 'KH98', 'Ngô Thùy Linh', '0921000078', '2025-02-06 14:00:00', '2025-02-06 14:00:00', 'Direct', 150000.00, 0.00, 'Completed', 'Cash', 'SALES7', NULL),
('DH147', 'KH120', 'Tô Hữu Dũng', '0921000100', '2025-02-20 16:30:00', '2025-02-23 16:30:00', 'Online', 780000.00, 30000.00, 'Completed', 'Transfer', 'OS3', 'SHIP2'),
('DH148', 'KH21', 'Nguyễn Văn Đạt', '0921000001', '2025-03-04 09:00:00', '2025-03-04 09:00:00', 'Direct', 600000.00, 0.00, 'Completed', 'Card', 'SALES8', NULL),
('DH149', 'KH43', 'Phạm Văn Dũng', '0921000023', '2025-03-21 12:00:00', '2025-03-24 12:00:00', 'Online', 950000.00, 40000.00, 'Completed', 'COD', 'OS5', 'SHIP3'),
('DH150', 'KH65', 'Hoàng Minh Đức', '0921000045', '2025-04-02 14:00:00', '2025-04-02 14:00:00', 'Direct', 450000.00, 0.00, 'Completed', 'Cash', 'SALES9', NULL),
('DH151', 'KH87', 'Bùi Thị Lan', '0921000067', '2025-04-20 17:00:00', '2025-04-23 17:00:00', 'Online', 350000.00, 30000.00, 'Completed', 'Transfer', 'OS7', 'SHIP4'),
('DH152', 'KH110', 'Tô Thị Ngọc Mai', '0921000090', '2025-05-06 10:45:00', '2025-05-06 10:45:00', 'Direct', 700000.00, 0.00, 'Completed', 'Card', 'SALES10', NULL),
('DH153', 'KH30', 'Mai Thị Kim', '0921000010', '2025-05-21 13:00:00', '2025-05-24 13:00:00', 'Online', 1840000.00, 40000.00, 'Completed', 'COD', 'OS2', 'SHIP5'),
('DH154', 'KH52', 'Lý Kim Ngân', '0921000032', '2025-06-08 11:00:00', '2025-06-08 11:00:00', 'Direct', 480000.00, 0.00, 'Completed', 'Cash', 'SALES1', NULL),
('DH155', 'KH74', 'Vũ Văn Long', '0921000054', '2025-06-22 15:00:00', '2025-06-25 15:00:00', 'Online', 150000.00, 30000.00, 'Completed', 'Transfer', 'OS4', 'SHIP1'),
('DH156', 'KH96', 'Đinh Ngọc Ánh', '0921000076', '2025-07-06 12:15:00', '2025-07-06 12:15:00', 'Direct', 750000.00, 0.00, 'Completed', 'Card', 'SALES2', NULL),
('DH157', 'KH118', 'Ngô Văn Tùng', '0921000098', '2025-07-21 16:00:00', '2025-07-24 16:00:00', 'Online', 630000.00, 30000.00, 'Completed', 'COD', 'OS6', 'SHIP2'),
('DH158', 'KH32', 'Lý Ngọc Lan', '0921000012', '2025-08-04 14:00:00', '2025-08-04 14:00:00', 'Direct', 400000.00, 0.00, 'Completed', 'Cash', 'SALES3', NULL),
('DH159', 'KH54', 'Vũ Thị Mai', '0921000034', '2025-08-20 17:30:00', '2025-08-23 17:30:00', 'Online', 480000.00, 30000.00, 'Completed', 'Transfer', 'OS8', 'SHIP3'),
('DH160', 'KH76', 'Đinh Văn Công', '0921000056', '2025-09-02 10:00:00', '2025-09-02 10:00:00', 'Direct', 150000.00, 0.00, 'Completed', 'Card', 'SALES4', NULL),
('DH161', 'KH98', 'Ngô Thùy Linh', '0921000078', '2025-09-22 13:00:00', '2025-09-25 13:00:00', 'Online', 780000.00, 30000.00, 'Completed', 'COD', 'OS1', 'SHIP4'),
('DH162', 'KH120', 'Tô Hữu Dũng', '0921000100', '2025-10-06 11:00:00', '2025-10-06 11:00:00', 'Direct', 600000.00, 0.00, 'Completed', 'Cash', 'SALES5', NULL),
('DH163', 'KH23', 'Lê Hữu Phúc', '0921000003', '2025-10-29 14:00:00', '2025-11-01 14:00:00', 'Online', 950000.00, 40000.00, 'Completed', 'Transfer', 'OS3', 'SHIP5'),
('DH164', 'KH45', 'Hoàng Quốc Việt', '0921000025', '2025-11-04 12:00:00', '2025-11-04 12:00:00', 'Direct', 450000.00, 0.00, 'Completed', 'Card', 'SALES6', NULL),
('DH165', 'KH67', 'Bùi Đức Anh', '0921000047', '2025-11-08 16:00:00', '2025-11-12 16:00:00', 'Online', 350000.00, 30000.00, 'Shipping', 'COD', 'OS5', 'SHIP1'), -- Shipping
('DH166', 'KH89', 'Mai Thanh Liêm', '0921000069', '2025-11-10 10:30:00', '2025-11-10 10:30:00', 'Direct', 700000.00, 0.00, 'Completed', 'Cash', 'SALES7', NULL),
('DH167', 'KH111', 'Trần Văn Phú', '0921000091', '2025-11-12 15:00:00', '2025-11-15 15:00:00', 'Online', 1840000.00, 40000.00, 'Completed', 'Transfer', 'OS7', 'SHIP2'),
('DH168', 'KH24', 'Phạm Thanh Thảo', '0921000004', '2025-11-14 09:00:00', '2025-11-14 09:00:00', 'Direct', 480000.00, 0.00, 'Completed', 'Card', 'SALES8', NULL),
('DH169', 'KH46', 'Đào Duy Anh', '0921000026', '2025-11-15 11:30:00', NULL, 'Online', 150000.00, 30000.00, 'Pending', 'COD', 'OS2', NULL), -- Pending
('DH170', 'KH68', 'Nguyễn Thị Thúy', '0921000048', '2025-11-16 13:45:00', NULL, 'Online', 750000.00, 30000.00, 'Processing', 'Transfer', 'OS4', NULL), -- Processing
('DH171', 'KH90', 'Tô Hữu Phước', '0921000070', '2025-11-17 15:00:00', '2025-11-17 15:00:00', 'Direct', 630000.00, 0.00, 'Completed', 'Cash', 'SALES9', NULL),
('DH172', 'KH112', 'Lý Thị Hồng Vân', '0921000092', '2025-11-18 17:00:00', NULL, 'Online', 400000.00, 30000.00, 'Shipping', 'COD', 'OS6', 'SHIP3'); -- Shipping

-- 3. 50 Orders ngẫu nhiên khác (DH173 -> DH220) để đạt đủ 220 đơn hàng
('DH173', 'KH25', 'Vũ Đình Khang', '0921000005', '2024-12-25 10:00:00', '2024-12-25 10:00:00', 'Direct', 1500000.00, 0.00, 'Completed', 'Card', 'SALES10', NULL),
('DH174', 'KH47', 'Bùi Ngọc Hùng', '0921000027', '2025-01-02 14:00:00', '2025-01-05 14:00:00', 'Online', 480000.00, 30000.00, 'Completed', 'Transfer', 'OS8', 'SHIP4'),
('DH175', 'KH69', 'Mai Thị Phương', '0921000049', '2025-02-10 16:30:00', '2025-02-10 16:30:00', 'Direct', 700000.00, 0.00, 'Completed', 'Cash', 'SALES1', NULL),
('DH176', 'KH91', 'Trần Thanh Nam', '0921000071', '2025-03-08 11:00:00', '2025-03-11 11:00:00', 'Online', 630000.00, 30000.00, 'Completed', 'COD', 'OS3', 'SHIP5'),
('DH177', 'KH113', 'Phạm Minh Hải', '0921000093', '2025-04-10 13:00:00', '2025-04-10 13:00:00', 'Direct', 400000.00, 0.00, 'Completed', 'Card', 'SALES2', NULL),
('DH178', 'KH26', 'Hoàng Bảo Vy', '0921000006', '2025-05-18 09:00:00', '2025-05-21 09:00:00', 'Online', 480000.00, 30000.00, 'Completed', 'Transfer', 'OS5', 'SHIP1'),
('DH179', 'KH48', 'Nguyễn Thị Thu', '0921000028', '2025-06-02 14:30:00', '2025-06-02 14:30:00', 'Direct', 150000.00, 0.00, 'Completed', 'Cash', 'SALES3', NULL),
('DH180', 'KH70', 'Tô Văn Hùng', '0921000050', '2025-07-08 17:00:00', '2025-07-11 17:00:00', 'Online', 780000.00, 30000.00, 'Completed', 'COD', 'OS7', 'SHIP2'),
('DH181', 'KH92', 'Lý Văn Sang', '0921000072', '2025-08-16 10:00:00', '2025-08-16 10:00:00', 'Direct', 600000.00, 0.00, 'Completed', 'Card', 'SALES4', NULL),
('DH182', 'KH114', 'Vũ Thị Thúy An', '0921000094', '2025-09-04 13:00:00', '2025-09-07 13:00:00', 'Online', 950000.00, 40000.00, 'Completed', 'Transfer', 'OS2', 'SHIP3'),
('DH183', 'KH28', 'Bùi Thị Hà', '0921000008', '2025-10-09 15:00:00', '2025-10-09 15:00:00', 'Direct', 450000.00, 0.00, 'Completed', 'Cash', 'SALES5', NULL),
('DH184', 'KH50', 'Tô Thanh Thảo', '0921000030', '2024-11-28 12:00:00', '2024-12-01 12:00:00', 'Online', 350000.00, 30000.00, 'Completed', 'COD', 'OS4', 'SHIP5'),
('DH185', 'KH72', 'Lý Văn Khoa', '0921000052', '2024-12-28 16:00:00', '2024-12-28 16:00:00', 'Direct', 700000.00, 0.00, 'Completed', 'Card', 'SALES6', NULL),
('DH186', 'KH94', 'Vũ Minh Anh', '0921000074', '2025-01-20 11:30:00', '2025-01-23 11:30:00', 'Online', 1840000.00, 40000.00, 'Completed', 'Transfer', 'OS6', 'SHIP1'),
('DH187', 'KH116', 'Đinh Minh Nhật', '0921000096', '2025-02-18 10:00:00', '2025-02-18 10:00:00', 'Direct', 480000.00, 0.00, 'Completed', 'Cash', 'SALES7', NULL),
('DH188', 'KH21', 'Nguyễn Văn Đạt', '0921000001', '2025-03-25 15:00:00', '2025-03-28 15:00:00', 'Online', 150000.00, 30000.00, 'Completed', 'COD', 'OS8', 'SHIP2'),
('DH189', 'KH43', 'Phạm Văn Dũng', '0921000023', '2025-04-18 11:00:00', '2025-04-18 11:00:00', 'Direct', 750000.00, 0.00, 'Completed', 'Card', 'SALES8', NULL),
('DH190', 'KH65', 'Hoàng Minh Đức', '0921000045', '2025-05-24 14:00:00', '2025-05-27 14:00:00', 'Online', 630000.00, 30000.00, 'Completed', 'Transfer', 'OS1', 'SHIP3'),
('DH191', 'KH87', 'Bùi Thị Lan', '0921000067', '2025-06-18 16:30:00', '2025-06-18 16:30:00', 'Direct', 400000.00, 0.00, 'Completed', 'Cash', 'SALES9', NULL),
('DH192', 'KH110', 'Tô Thị Ngọc Mai', '0921000090', '2025-07-25 10:00:00', '2025-07-28 10:00:00', 'Online', 480000.00, 30000.00, 'Completed', 'COD', 'OS3', 'SHIP4'),
('DH193', 'KH30', 'Mai Thị Kim', '0921000010', '2025-08-01 12:00:00', '2025-08-01 12:00:00', 'Direct', 150000.00, 0.00, 'Completed', 'Card', 'SALES10', NULL),
('DH194', 'KH52', 'Lý Kim Ngân', '0921000032', '2025-09-28 14:30:00', '2025-10-01 14:30:00', 'Online', 750000.00, 30000.00, 'Completed', 'Transfer', 'OS5', 'SHIP5'),
('DH195', 'KH74', 'Vũ Văn Long', '0921000054', '2025-10-10 16:00:00', '2025-10-10 16:00:00', 'Direct', 600000.00, 0.00, 'Completed', 'Cash', 'SALES1', NULL),
('DH196', 'KH96', 'Đinh Ngọc Ánh', '0921000076', '2025-11-03 10:00:00', '2025-11-06 10:00:00', 'Online', 950000.00, 40000.00, 'Completed', 'COD', 'OS7', 'SHIP1'),
('DH197', 'KH118', 'Ngô Văn Tùng', '0921000098', '2024-11-24 10:00:00', '2024-11-24 10:00:00', 'Direct', 450000.00, 0.00, 'Completed', 'Card', 'SALES2', NULL),
('DH198', 'KH32', 'Lý Ngọc Lan', '0921000012', '2024-12-22 15:30:00', '2024-12-25 15:30:00', 'Online', 350000.00, 30000.00, 'Completed', 'Transfer', 'OS2', 'SHIP2'),
('DH199', 'KH54', 'Vũ Thị Mai', '0921000034', '2025-01-14 10:30:00', '2025-01-14 10:30:00', 'Direct', 700000.00, 0.00, 'Completed', 'Cash', 'SALES3', NULL),
('DH200', 'KH76', 'Đinh Văn Công', '0921000056', '2025-02-05 15:00:00', '2025-02-08 15:00:00', 'Online', 1840000.00, 40000.00, 'Completed', 'COD', 'OS4', 'SHIP3'),
('DH201', 'KH98', 'Ngô Thùy Linh', '0921000078', '2025-03-12 11:30:00', '2025-03-12 11:30:00', 'Direct', 480000.00, 0.00, 'Completed', 'Card', 'SALES4', NULL),
('DH202', 'KH120', 'Tô Hữu Dũng', '0921000100', '2025-04-14 14:30:00', '2025-04-17 14:30:00', 'Online', 150000.00, 30000.00, 'Completed', 'Transfer', 'OS6', 'SHIP4'),
('DH203', 'KH23', 'Lê Hữu Phúc', '0921000003', '2025-05-10 10:00:00', '2025-05-10 10:00:00', 'Direct', 750000.00, 0.00, 'Completed', 'Cash', 'SALES5', NULL),
('DH204', 'KH45', 'Hoàng Quốc Việt', '0921000025', '2025-06-14 16:30:00', '2025-06-17 16:30:00', 'Online', 630000.00, 30000.00, 'Completed', 'COD', 'OS8', 'SHIP5'),
('DH205', 'KH67', 'Bùi Đức Anh', '0921000047', '2025-07-28 11:30:00', '2025-07-28 11:30:00', 'Direct', 400000.00, 0.00, 'Completed', 'Card', 'SALES6', NULL),
('DH206', 'KH89', 'Mai Thanh Liêm', '0921000069', '2025-08-25 15:00:00', '2025-08-28 15:00:00', 'Online', 480000.00, 30000.00, 'Completed', 'Transfer', 'OS1', 'SHIP1'),
('DH207', 'KH111', 'Trần Văn Phú', '0921000091', '2025-09-08 10:30:00', '2025-09-08 10:30:00', 'Direct', 150000.00, 0.00, 'Completed', 'Cash', 'SALES7', NULL),
('DH208', 'KH24', 'Phạm Thanh Thảo', '0921000004', '2025-10-18 14:00:00', '2025-10-21 14:00:00', 'Online', 750000.00, 30000.00, 'Completed', 'COD', 'OS3', 'SHIP2'),
('DH209', 'KH46', 'Đào Duy Anh', '0921000026', '2025-11-01 10:00:00', '2025-11-01 10:00:00', 'Direct', 600000.00, 0.00, 'Completed', 'Card', 'SALES8', NULL),
('DH210', 'KH68', 'Nguyễn Thị Thúy', '0921000048', '2025-08-09 14:30:00', '2025-08-12 14:30:00', 'Online', 950000.00, 40000.00, 'Completed', 'Transfer', 'OS5', 'SHIP3'),
('DH211', 'KH90', 'Tô Hữu Phước', '0921000070', '2025-09-20 16:00:00', '2025-09-20 16:00:00', 'Direct', 450000.00, 0.00, 'Completed', 'Cash', 'SALES9', NULL),
('DH212', 'KH112', 'Lý Thị Hồng Vân', '0921000092', '2025-10-22 17:30:00', '2025-10-25 17:30:00', 'Online', 350000.00, 30000.00, 'Completed', 'COD', 'OS7', 'SHIP4'),
('DH213', 'KH25', 'Vũ Đình Khang', '0921000005', '2024-12-15 11:30:00', '2024-12-15 11:30:00', 'Direct', 700000.00, 0.00, 'Completed', 'Card', 'SALES10', NULL),
('DH214', 'KH47', 'Bùi Ngọc Hùng', '0921000027', '2025-01-28 14:00:00', '2025-01-31 14:00:00', 'Online', 1840000.00, 40000.00, 'Completed', 'Transfer', 'OS2', 'SHIP5'),
('DH215', 'KH69', 'Mai Thị Phương', '0921000049', '2025-02-24 16:00:00', '2025-02-24 16:00:00', 'Direct', 480000.00, 0.00, 'Completed', 'Cash', 'SALES1', NULL),
('DH216', 'KH91', 'Trần Thanh Nam', '0921000071', '2025-03-19 10:30:00', '2025-03-22 10:30:00', 'Online', 150000.00, 30000.00, 'Completed', 'COD', 'OS4', 'SHIP1'),
('DH217', 'KH113', 'Phạm Minh Hải', '0921000093', '2025-04-25 15:00:00', '2025-04-25 15:00:00', 'Direct', 750000.00, 0.00, 'Completed', 'Card', 'SALES2', NULL),
('DH218', 'KH26', 'Hoàng Bảo Vy', '0921000006', '2025-05-02 11:00:00', '2025-05-02 11:00:00', 'Direct', 600000.00, 0.00, 'Completed', 'Cash', 'SALES3', NULL),
('DH219', 'KH48', 'Nguyễn Thị Thu', '0921000028', '2025-06-28 14:00:00', '2025-07-01 14:00:00', 'Online', 950000.00, 40000.00, 'Completed', 'Transfer', 'OS6', 'SHIP2'),
('DH220', 'KH70', 'Tô Văn Hùng', '0921000050', '2025-07-15 16:30:00', '2025-07-15 16:30:00', 'Direct', 450000.00, 0.00, 'Completed', 'Card', 'SALES4', NULL);


-- Chi tiết cho 200 đơn hàng mới (DH021 -> DH220)
INSERT INTO `order_details` (`order_id`, `product_id`, `quantity`, `price_at_order`) VALUES
('DH021', 'SP3', 1, 700000.00), ('DH022', 'SP11', 1, 750000.00), ('DH023', 'SP9', 1, 400000.00), ('DH024', 'SP7', 1, 1200000.00), ('DH024', 'SP10', 1, 350000.00), ('DH024', 'SP15', 1, 30000.00),
('DH025', 'SP4', 1, 950000.00), ('DH025', 'SP14', 1, 450000.00), ('DH026', 'SP10', 1, 850000.00), ('DH026', 'SP15', 1, 50000.00), ('DH027', 'SP6', 1, 320000.00), ('DH028', 'SP1', 1, 150000.00),
('DH029', 'SP3', 1, 700000.00), ('DH030', 'SP16', 1, 180000.00), ('DH031', 'SP2', 1, 450000.00), ('DH032', 'SP13', 1, 1500000.00), ('DH033', 'SP5', 1, 600000.00), ('DH034', 'SP4', 1, 950000.00),
('DH035', 'SP20', 1, 380000.00), ('DH036', 'SP7', 1, 1200000.00), ('DH037', 'SP1', 1, 150000.00), ('DH038', 'SP6', 2, 320000.00), ('DH039', 'SP19', 1, 290000.00), ('DH040', 'SP10', 1, 850000.00),
('DH041', 'SP13', 1, 1500000.00), ('DH042', 'SP1', 1, 150000.00), ('DH043', 'SP2', 1, 450000.00), ('DH044', 'SP3', 1, 700000.00), ('DH045', 'SP8', 1, 280000.00), ('DH046', 'SP7', 1, 1200000.00),
('DH047', 'SP9', 1, 400000.00), ('DH048', 'SP5', 1, 600000.00), ('DH049', 'SP1', 1, 150000.00), ('DH050', 'SP17', 1, 550000.00), ('DH051', 'SP13', 1, 1500000.00), ('DH051', 'SP15', 1, 30000.00),
('DH052', 'SP4', 1, 950000.00), ('DH053', 'SP2', 1, 450000.00), ('DH054', 'SP5', 1, 600000.00), ('DH055', 'SP20', 1, 380000.00), ('DH056', 'SP15', 1, 120000.00), ('DH057', 'SP18', 1, 200000.00),
('DH058', 'SP11', 1, 750000.00), ('DH059', 'SP1', 1, 150000.00), ('DH060', 'SP4', 1, 950000.00), ('DH061', 'SP14', 1, 1800000.00), ('DH062', 'SP6', 1, 320000.00), ('DH063', 'SP3', 1, 700000.00),
('DH064', 'SP2', 1, 450000.00), ('DH065', 'SP12', 1, 480000.00), ('DH066', 'SP15', 1, 120000.00), ('DH067', 'SP13', 1, 1500000.00), ('DH067', 'SP9', 1, 40000.00), ('DH068', 'SP11', 1, 750000.00),
('DH069', 'SP17', 1, 550000.00), ('DH069', 'SP15', 1, 20000.00), ('DH070', 'SP10', 1, 850000.00), ('DH071', 'SP5', 1, 600000.00), ('DH071', 'SP15', 1, 30000.00), ('DH072', 'SP16', 1, 180000.00),
('DH073', 'SP2', 1, 450000.00), ('DH074', 'SP3', 1, 700000.00), ('DH075', 'SP7', 1, 1200000.00), ('DH076', 'SP20', 1, 380000.00), ('DH076', 'SP18', 1, 40000.00), ('DH077', 'SP4', 1, 950000.00),
('DH078', 'SP5', 1, 600000.00), ('DH079', 'SP2', 1, 450000.00), ('DH080', 'SP1', 1, 150000.00), ('DH081', 'SP11', 1, 750000.00), ('DH082', 'SP13', 1, 1500000.00), ('DH083', 'SP5', 1, 600000.00),
('DH083', 'SP15', 1, 30000.00), ('DH084', 'SP9', 1, 400000.00), ('DH085', 'SP14', 1, 1800000.00), ('DH086', 'SP12', 1, 480000.00), ('DH087', 'SP6', 1, 320000.00), ('DH088', 'SP11', 1, 750000.00),
('DH089', 'SP5', 1, 600000.00), ('DH089', 'SP15', 1, 30000.00), ('DH090', 'SP8', 1, 280000.00), ('DH091', 'SP17', 1, 550000.00), ('DH092', 'SP1', 1, 150000.00), ('DH093', 'SP3', 1, 700000.00),
('DH094', 'SP2', 1, 450000.00), ('DH095', 'SP14', 1, 1800000.00), ('DH096', 'SP12', 1, 480000.00), ('DH097', 'SP15', 1, 120000.00), ('DH098', 'SP11', 1, 750000.00), ('DH099', 'SP5', 1, 600000.00), ('DH099', 'SP15', 1, 30000.00),
('DH100', 'SP9', 1, 400000.00), ('DH101', 'SP2', 1, 450000.00), ('DH102', 'SP13', 1, 1500000.00), ('DH103', 'SP3', 1, 700000.00), ('DH103', 'SP8', 1, 30000.00), ('DH104', 'SP5', 1, 600000.00),
('DH105', 'SP16', 1, 180000.00), ('DH106', 'SP11', 1, 750000.00), ('DH107', 'SP4', 1, 950000.00), ('DH107', 'SP18', 1, 40000.00), ('DH108', 'SP20', 1, 380000.00), ('DH109', 'SP7', 1, 1200000.00), ('DH109', 'SP15', 1, 30000.00),
('DH110', 'SP9', 1, 400000.00), ('DH111', 'SP2', 1, 450000.00), ('DH112', 'SP1', 1, 150000.00), ('DH113', 'SP11', 1, 750000.00), ('DH114', 'SP5', 1, 600000.00), ('DH115', 'SP6', 1, 320000.00),
('DH116', 'SP4', 1, 950000.00), ('DH117', 'SP2', 1, 450000.00), ('DH118', 'SP3', 1, 700000.00), ('DH119', 'SP13', 1, 1500000.00), ('DH120', 'SP12', 1, 480000.00), ('DH121', 'SP5', 1, 600000.00), ('DH121', 'SP15', 1, 30000.00),
('DH122', 'SP16', 1, 180000.00), ('DH123', 'SP11', 1, 750000.00), ('DH124', 'SP20', 1, 380000.00), ('DH125', 'SP9', 1, 400000.00), ('DH126', 'SP7', 1, 1200000.00), ('DH127', 'SP9', 1, 400000.00),
('DH128', 'SP1', 1, 150000.00), ('DH129', 'SP11', 1, 750000.00), ('DH130', 'SP5', 1, 600000.00), ('DH131', 'SP4', 1, 950000.00), ('DH131', 'SP18', 1, 40000.00), ('DH132', 'SP2', 1, 450000.00),
('DH133', 'SP6', 1, 320000.00), ('DH134', 'SP3', 1, 700000.00), ('DH135', 'SP14', 1, 1800000.00), ('DH136', 'SP12', 1, 480000.00), ('DH137', 'SP15', 1, 120000.00), ('DH138', 'SP11', 1, 750000.00),
('DH139', 'SP2', 1, 450000.00), ('DH140', 'SP20', 1, 380000.00), ('DH141', 'SP7', 1, 1200000.00), ('DH141', 'SP15', 1, 40000.00), ('DH142', 'SP5', 1, 600000.00), ('DH143', 'SP5', 1, 600000.00), ('DH143', 'SP15', 1, 30000.00),
('DH144', 'SP9', 1, 400000.00), ('DH145', 'SP2', 1, 450000.00), ('DH146', 'SP1', 1, 150000.00), ('DH147', 'SP11', 1, 750000.00), ('DH148', 'SP5', 1, 600000.00), ('DH149', 'SP4', 1, 950000.00),
('DH150', 'SP2', 1, 450000.00), ('DH151', 'SP6', 1, 320000.00), ('DH152', 'SP3', 1, 700000.00), ('DH153', 'SP14', 1, 1800000.00), ('DH154', 'SP12', 1, 480000.00), ('DH155', 'SP1', 1, 150000.00),
('DH156', 'SP11', 1, 750000.00), ('DH157', 'SP5', 1, 600000.00), ('DH157', 'SP15', 1, 30000.00), ('DH158', 'SP9', 1, 400000.00), ('DH159', 'SP2', 1, 450000.00), ('DH160', 'SP1', 1, 150000.00),
('DH161', 'SP11', 1, 750000.00), ('DH162', 'SP5', 1, 600000.00), ('DH163', 'SP4', 1, 950000.00), ('DH163', 'SP15', 1, 40000.00), ('DH164', 'SP2', 1, 450000.00), ('DH165', 'SP6', 1, 320000.00),
('DH166', 'SP3', 1, 700000.00), ('DH167', 'SP14', 1, 1800000.00), ('DH168', 'SP12', 1, 480000.00), ('DH169', 'SP1', 1, 150000.00), ('DH170', 'SP11', 1, 750000.00), ('DH171', 'SP5', 1, 600000.00),
('DH172', 'SP9', 1, 400000.00), ('DH173', 'SP13', 1, 1500000.00), ('DH174', 'SP12', 1, 480000.00), ('DH175', 'SP3', 1, 700000.00), ('DH176', 'SP5', 1, 600000.00), ('DH176', 'SP15', 1, 30000.00),
('DH177', 'SP9', 1, 400000.00), ('DH178', 'SP12', 1, 480000.00), ('DH178', 'SP15', 1, 30000.00), ('DH179', 'SP1', 1, 150000.00), ('DH180', 'SP3', 1, 700000.00), ('DH181', 'SP5', 1, 600000.00),
('DH182', 'SP4', 1, 950000.00), ('DH183', 'SP2', 1, 450000.00), ('DH184', 'SP6', 1, 320000.00), ('DH185', 'SP3', 1, 700000.00), ('DH186', 'SP14', 1, 1800000.00), ('DH187', 'SP12', 1, 480000.00),
('DH188', 'SP1', 1, 150000.00), ('DH189', 'SP11', 1, 750000.00), ('DH190', 'SP5', 1, 600000.00), ('DH190', 'SP15', 1, 30000.00), ('DH191', 'SP9', 1, 400000.00), ('DH192', 'SP2', 1, 450000.00),
('DH193', 'SP1', 1, 150000.00), ('DH194', 'SP11', 1, 750000.00), ('DH195', 'SP5', 1, 600000.00), ('DH196', 'SP4', 1, 950000.00), ('DH196', 'SP15', 1, 30000.00), ('DH197', 'SP2', 1, 450000.00),
('DH198', 'SP6', 1, 320000.00), ('DH199', 'SP3', 1, 700000.00), ('DH200', 'SP14', 1, 1800000.00), ('DH201', 'SP12', 1, 480000.00), ('DH202', 'SP1', 1, 150000.00), ('DH203', 'SP11', 1, 750000.00),
('DH204', 'SP5', 1, 600000.00), ('DH204', 'SP15', 1, 30000.00), ('DH205', 'SP9', 1, 400000.00), ('DH206', 'SP2', 1, 450000.00), ('DH207', 'SP1', 1, 150000.00), ('DH208', 'SP11', 1, 750000.00),
('DH209', 'SP5', 1, 600000.00), ('DH210', 'SP7', 1, 1200000.00), ('DH211', 'SP4', 1, 950000.00), ('DH212', 'SP2', 1, 450000.00), ('DH213', 'SP3', 1, 700000.00), ('DH214', 'SP14', 1, 1800000.00),
('DH215', 'SP12', 1, 480000.00), ('DH216', 'SP1', 1, 150000.00), ('DH217', 'SP11', 1, 750000.00), ('DH218', 'SP5', 1, 600000.00), ('DH219', 'SP4', 1, 950000.00), ('DH220', 'SP2', 1, 450000.00);


---
## 4. CẬP NHẬT DỮ LIỆU TỒN KHO VÀ NHẬP KHO BỔ SUNG
---

-- 7. Dữ liệu STOCK_IN bổ sung (12 phiếu nhập, 1 phiếu/tháng)
INSERT INTO `stock_in` (`stock_in_id`, `supplier_name`, `import_date`, `total_cost`, `user_id`) VALUES
('NK06', 'NCC F - Tháng 11/2024', '2024-11-20 09:00:00', 10000000.00, 'WH6'),
('NK07', 'NCC G - Tháng 12/2024', '2024-12-19 14:00:00', 12500000.00, 'WH1'),
('NK08', 'NCC H - Tháng 01/2025', '2025-01-20 10:00:00', 15000000.00, 'WH2'),
('NK09', 'NCC I - Tháng 02/2025', '2025-02-18 11:00:00', 11000000.00, 'WH3'),
('NK10', 'NCC J - Tháng 03/2025', '2025-03-20 15:00:00', 13500000.00, 'WH4'),
('NK11', 'NCC K - Tháng 04/2025', '2025-04-19 09:00:00', 16000000.00, 'WH5'),
('NK12', 'NCC L - Tháng 05/2025', '2025-05-20 14:00:00', 10500000.00, 'WH6'),
('NK13', 'NCC M - Tháng 06/2025', '2025-06-19 10:00:00', 12000000.00, 'WH1'),
('NK14', 'NCC N - Tháng 07/2025', '2025-07-20 11:00:00', 14500000.00, 'WH2'),
('NK15', 'NCC O - Tháng 08/2025', '2025-08-19 15:00:00', 11500000.00, 'WH3'),
('NK16', 'NCC P - Tháng 09/2025', '2025-09-20 09:00:00', 13000000.00, 'WH4'),
('NK17', 'NCC Q - Tháng 10/2025', '2025-10-20 14:00:00', 15500000.00, 'WH5');

-- 8. Dữ liệu STOCK_IN_DETAILS bổ sung (Chi tiết 12 phiếu nhập mới)
INSERT INTO `stock_in_details` (`stock_in_id`, `product_id`, `quantity`, `cost_price`) VALUES
('NK06', 'SP1', 50, 80000.00), ('NK06', 'SP11', 50, 400000.00), ('NK07', 'SP2', 50, 250000.00), ('NK07', 'SP12', 30, 280000.00),
('NK08', 'SP3', 40, 400000.00), ('NK08', 'SP14', 10, 1200000.00), ('NK09', 'SP5', 40, 350000.00), ('NK09', 'SP15', 50, 50000.00),
('NK10', 'SP6', 30, 150000.00), ('NK10', 'SP17', 20, 300000.00), ('NK11', 'SP7', 10, 800000.00), ('NK11', 'SP4', 10, 550000.00),
('NK12', 'SP8', 40, 150000.00), ('NK12', 'SP19', 30, 140000.00), ('NK13', 'SP10', 20, 500000.00), ('NK13', 'SP20', 20, 200000.00),
('NK14', 'SP13', 10, 1000000.00), ('NK14', 'SP9', 10, 200000.00), ('NK15', 'SP16', 30, 90000.00), ('NK15', 'SP18', 30, 100000.00),
('NK16', 'SP1', 50, 80000.00), ('NK16', 'SP2', 50, 250000.00), ('NK17', 'SP3', 40, 400000.00), ('NK17', 'SP11', 50, 400000.00);


-- 9. Dữ liệu SALARIES bổ sung (Lương tháng 11/2025)
INSERT INTO `salaries` (`salary_id`, `user_id`, `month_year`, `base_salary`, `sales_commission`, `bonus`, `deductions`, `net_salary`, `calculated_by_user_id`) VALUES
('SALES1-2025-11', 'SALES1', '2025-11-01', 6000000, 28000.00, 200000, 50000, 6178000.00, 'OWNER1'), -- Tính toán lại cho 11/2025
('SALES2-2025-11', 'SALES2', '2025-11-01', 6500000, 11250.00, 200000, 50000, 6661250.00, 'OWNER1'),
('SALES3-2025-11', 'SALES3', '2025-11-01', 5500000, 11250.00, 200000, 50000, 5661250.00, 'OWNER1'),
('SALES4-2025-11', 'SALES4', '2025-11-01', 7000000, 5700.00, 200000, 50000, 7155700.00, 'OWNER1'),
('SALES5-2025-11', 'SALES5', '2025-11-01', 5800000, 0.00, 200000, 50000, 5950000.00, 'OWNER1'),
('SALES6-2025-11', 'SALES6', '2025-11-01', 6500000, 0.00, 200000, 50000, 6650000.00, 'OWNER1'),
('SALES7-2025-11', 'SALES7', '2025-11-01', 7000000, 0.00, 200000, 50000, 7150000.00, 'OWNER1'),
('SALES8-2025-11', 'SALES8', '2025-11-01', 6200000, 7200.00, 200000, 50000, 6357200.00, 'OWNER1'),
('SALES9-2025-11', 'SALES9', '2025-11-01', 6800000, 10500.00, 200000, 50000, 6950500.00, 'OWNER1'),
('SALES10-2025-11', 'SALES10', '2025-11-01', 6500000, 0.00, 200000, 50000, 6650000.00, 'OWNER1'),
('OS1-2025-11', 'OS1', '2025-11-01', 8000000, 0.00, 500000, 100000, 8400000.00, 'OWNER1'),
('OS2-2025-11', 'OS2', '2025-11-01', 8500000, 0.00, 500000, 100000, 8800000.00, 'OWNER1'),
('OS3-2025-11', 'OS3', '2025-11-01', 117000, 500000, 100000, 8317000.00, 'OWNER1'),
('OS4-2025-11', 'OS4', '2025-11-01', 8200000, 13500.00, 500000, 100000, 8613500.00, 'OWNER1'),
('OS5-2025-11', 'OS5', '2025-11-01', 7500000, 0.00, 500000, 100000, 7900000.00, 'OWNER1'),
('OS6-2025-11', 'OS6', '2025-11-01', 8000000, 0.00, 500000, 100000, 8400000.00, 'OWNER1'),
('OS7-2025-11', 'OS7', '2025-11-01', 7900000, 0.00, 500000, 100000, 8300000.00, 'OWNER1'),
('OS8-2025-11', 'OS8', '2025-11-01', 8300000, 0.00, 500000, 100000, 8700000.00, 'OWNER1'),
('WH1-2025-11', 'WH1', '2025-11-01', 7500000, 0, 0, 20000, 7480000, 'OWNER1'),
('WH2-2025-11', 'WH2', '2025-11-01', 7000000, 0, 0, 20000, 6980000, 'OWNER1'),
('WH3-2025-11', 'WH3', '2025-11-01', 6500000, 0, 0, 20000, 6480000, 'OWNER1'),
('WH4-2025-11', 'WH4', '2025-11-01', 7200000, 0, 0, 20000, 7180000, 'OWNER1'),
('WH5-2025-11', 'WH5', '2025-11-01', 6800000, 0, 0, 20000, 6780000, 'OWNER1'),
('WH6-2025-11', 'WH6', '2025-11-01', 7000000, 0, 0, 20000, 6980000, 'OWNER1'),
('SHIP1-2025-11', 'SHIP1', '2025-11-01', 6000000, 0, 50000, 0, 6050000, 'OWNER1'),
('SHIP2-2025-11', 'SHIP2', '2025-11-01', 5500000, 0, 50000, 0, 5550000, 'OWNER1'),
('SHIP3-2025-11', 'SHIP3', '2025-11-01', 5800000, 0, 50000, 0, 5850000, 'OWNER1'),
('SHIP4-2025-11', 'SHIP4', '2025-11-01', 6100000, 0, 50000, 0, 6150000, 'OWNER1'),
('SHIP5-2025-11', 'SHIP5', '2025-11-01', 5900000, 0, 50000, 0, 5950000, 'OWNER1');

---
## 5. CẬP NHẬT TỒN KHO CUỐI CÙNG
---
-- Tắt Safe Update để cho phép UPDATE toàn bộ bảng
SET SQL_SAFE_UPDATES = 0;

-- 1. Khởi tạo lại tồn kho
UPDATE `products` SET `stock_quantity` = 0;

-- 2. Cập nhật tồn kho từ STOCK_IN (Tổng cộng 17 phiếu: 5 cũ + 12 mới)
UPDATE products p
JOIN (
    SELECT product_id, SUM(quantity) AS total_imported
    FROM stock_in_details
    GROUP BY product_id
) AS sid ON p.product_id = sid.product_id
SET p.stock_quantity = p.stock_quantity + sid.total_imported;

-- 3. Cập nhật tồn kho từ ORDERS đã HOÀN TẤT (Tổng cộng 20 + 175 = 195 đơn Completed)
UPDATE products p
JOIN (
    SELECT product_id, SUM(quantity) AS total_ordered
    FROM order_details od
    JOIN orders o ON od.order_id = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY product_id
) AS od_sum ON p.product_id = od_sum.product_id
SET p.stock_quantity = p.stock_quantity - total_ordered;

-- Bật lại kiểm tra khóa ngoại
SET foreign_key_checks = 1;
SET SQL_SAFE_UPDATES = 1;