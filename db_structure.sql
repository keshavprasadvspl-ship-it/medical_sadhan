-- ============================================
-- MEDICAL B2B PROCUREMENT PLATFORM DATABASE
-- ============================================

-- Create database
CREATE DATABASE IF NOT EXISTS medical_b2b_platform;
USE medical_b2b_platform;

-- ============================================
-- 1. USERS & AUTHENTICATION TABLES
-- ============================================

-- User types enumeration
CREATE TABLE IF NOT EXISTS user_types (
    id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default user types
INSERT INTO user_types (type_name, description) VALUES
('buyer', 'Hospitals, Clinics, Medical Stores, Pharmacies'),
('vendor', 'Distributors, Wholesalers, Manufacturers'),
('admin', 'Platform Administrators'),
('operations', 'Operations Team');

-- Main users table
CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_type_id INT NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    business_name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(100),
    gst_number VARCHAR(20),
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    pincode VARCHAR(10),
    country VARCHAR(100) DEFAULT 'India',
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    profile_image VARCHAR(500),
    verification_token VARCHAR(100),
    reset_token VARCHAR(100),
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_type_id) REFERENCES user_types(id) ON DELETE RESTRICT
);

-- Buyer-specific details
CREATE TABLE IF NOT EXISTS buyer_details (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT UNIQUE NOT NULL,
    business_type ENUM('hospital', 'clinic', 'medical_store', 'pharmacy_chain', 'individual_pharmacy') NOT NULL,
    license_number VARCHAR(100),
    establishment_year YEAR,
    total_branches INT DEFAULT 1,
    average_monthly_purchase DECIMAL(12,2) DEFAULT 0,
    credit_limit DECIMAL(12,2) DEFAULT 0,
    credit_used DECIMAL(12,2) DEFAULT 0,
    preferred_payment_method ENUM('credit', 'prepaid', 'both') DEFAULT 'both',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Vendor-specific details
CREATE TABLE IF NOT EXISTS vendor_details (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT UNIQUE NOT NULL,
    business_type ENUM('distributor', 'wholesaler', 'manufacturer', 'super_stockist') NOT NULL,
    company_registration_number VARCHAR(100),
    year_of_establishment YEAR,
    warehouse_address TEXT,
    operational_cities TEXT,
    delivery_radius_km INT,
    min_order_value DECIMAL(12,2) DEFAULT 0,
    delivery_time_days INT DEFAULT 2,
    return_policy TEXT,
    vendor_rating DECIMAL(3,2) DEFAULT 0,
    total_ratings INT DEFAULT 0,
    is_preferred_vendor BOOLEAN DEFAULT FALSE,
    account_manager_id INT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (account_manager_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Vendor integration settings
CREATE TABLE IF NOT EXISTS vendor_integrations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    vendor_id INT NOT NULL,
    integration_type ENUM('tally', 'custom_erp', 'billing_software', 'manual') NOT NULL,
    integration_method ENUM('api', 'xml', 'json', 'excel', 'manual') NOT NULL,
    api_endpoint VARCHAR(500),
    api_key VARCHAR(255),
    api_secret VARCHAR(255),
    tally_company_name VARCHAR(255),
    erp_name VARCHAR(100),
    sync_frequency ENUM('realtime', 'hourly', 'daily', 'manual') DEFAULT 'realtime',
    last_sync_time TIMESTAMP NULL,
    sync_status ENUM('active', 'inactive', 'failed') DEFAULT 'active',
    settings_json JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (vendor_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================
-- 2. PRODUCT CATALOG TABLES
-- ============================================

-- Product categories
CREATE TABLE IF NOT EXISTS product_categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    category_code VARCHAR(50) UNIQUE,
    parent_category_id INT NULL,
    description TEXT,
    image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id) REFERENCES product_categories(id) ON DELETE SET NULL
);

-- Product master (generic products)
CREATE TABLE IF NOT EXISTS products_master (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(255) NOT NULL,
    generic_name VARCHAR(255),
    salt_composition TEXT,
    brand_name VARCHAR(100),
    dosage_form ENUM('tablet', 'capsule', 'syrup', 'injection', 'cream', 'ointment', 'device', 'surgical', 'other'),
    category_id INT NOT NULL,
    hsn_code VARCHAR(10),
    gst_percentage DECIMAL(5,2) DEFAULT 0,
    description TEXT,
    side_effects TEXT,
    storage_instructions TEXT,
    image_url VARCHAR(500),
    is_prescription_required BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES product_categories(id) ON DELETE RESTRICT
);

-- Vendor-specific product listings
CREATE TABLE IF NOT EXISTS vendor_products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    vendor_id INT NOT NULL,
    product_master_id INT NOT NULL,
    packing_type ENUM('strip', 'box', 'bottle', 'vial', 'packet', 'other') NOT NULL,
    pack_size VARCHAR(50),
    units_per_pack INT DEFAULT 1,
    mrp DECIMAL(10,2) NOT NULL,
    selling_price DECIMAL(10,2) NOT NULL,
    batch_number VARCHAR(100) NOT NULL,
    manufacturing_date DATE,
    expiry_date DATE NOT NULL,
    stock_quantity INT NOT NULL,
    min_order_quantity INT DEFAULT 1,
    max_order_quantity INT,
    is_available BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    discount_percentage DECIMAL(5,2) DEFAULT 0,
    special_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_vendor_product (vendor_id, product_master_id, batch_number),
    FOREIGN KEY (vendor_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_master_id) REFERENCES products_master(id) ON DELETE RESTRICT
);

-- Product images
CREATE TABLE IF NOT EXISTS product_images (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_master_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    image_type ENUM('primary', 'secondary', 'packaging', 'usage') DEFAULT 'primary',
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_master_id) REFERENCES products_master(id) ON DELETE CASCADE
);

-- ============================================
-- 3. ORDER MANAGEMENT TABLES
-- ============================================

-- Cart table
CREATE TABLE IF NOT EXISTS carts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    vendor_id INT NOT NULL,
    session_id VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (vendor_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Cart items
CREATE TABLE IF NOT EXISTS cart_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cart_id INT NOT NULL,
    vendor_product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cart_id) REFERENCES carts(id) ON DELETE CASCADE,
    FOREIGN KEY (vendor_product_id) REFERENCES vendor_products(id) ON DELETE RESTRICT
);

-- Orders master
CREATE TABLE IF NOT EXISTS orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    buyer_id INT NOT NULL,
    vendor_id INT NOT NULL,
    cart_id INT,
    total_amount DECIMAL(12,2) NOT NULL,
    discount_amount DECIMAL(12,2) DEFAULT 0,
    gst_amount DECIMAL(12,2) DEFAULT 0,
    shipping_charge DECIMAL(10,2) DEFAULT 0,
    final_amount DECIMAL(12,2) NOT NULL,
    payment_status ENUM('pending', 'paid', 'partially_paid', 'cancelled') DEFAULT 'pending',
    order_status ENUM('draft', 'placed', 'confirmed', 'processing', 'dispatched', 'delivered', 'cancelled', 'returned') DEFAULT 'draft',
    payment_method ENUM('cash_on_delivery', 'online', 'credit', 'bank_transfer') DEFAULT 'credit',
    delivery_address TEXT NOT NULL,
    delivery_city VARCHAR(100),
    delivery_state VARCHAR(100),
    delivery_pincode VARCHAR(10),
    delivery_instructions TEXT,
    expected_delivery_date DATE,
    actual_delivery_date DATE,
    vendor_notes TEXT,
    buyer_notes TEXT,
    cancellation_reason TEXT,
    cancelled_by INT,
    integration_status ENUM('pending', 'synced', 'failed', 'not_required') DEFAULT 'pending',
    tally_order_number VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_order_number (order_number),
    INDEX idx_buyer_id (buyer_id),
    INDEX idx_vendor_id (vendor_id),
    FOREIGN KEY (buyer_id) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (vendor_id) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (cart_id) REFERENCES carts(id) ON DELETE SET NULL,
    FOREIGN KEY (cancelled_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Order items
CREATE TABLE IF NOT EXISTS order_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    vendor_product_id INT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    batch_number VARCHAR(100) NOT NULL,
    expiry_date DATE NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    gst_percentage DECIMAL(5,2) NOT NULL,
    gst_amount DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    return_quantity INT DEFAULT 0,
    return_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (vendor_product_id) REFERENCES vendor_products(id) ON DELETE RESTRICT
);

-- Order status history
CREATE TABLE IF NOT EXISTS order_status_history (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    status ENUM('draft', 'placed', 'confirmed', 'processing', 'dispatched', 'delivered', 'cancelled', 'returned') NOT NULL,
    changed_by INT NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE RESTRICT
);

-- ============================================
-- 4. INVOICE & PAYMENT TABLES
-- ============================================

-- Invoices
CREATE TABLE IF NOT EXISTS invoices (
    id INT PRIMARY KEY AUTO_INCREMENT,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    order_id INT NOT NULL,
    vendor_id INT NOT NULL,
    buyer_id INT NOT NULL,
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,
    gst_amount DECIMAL(12,2) NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    amount_paid DECIMAL(12,2) DEFAULT 0,
    balance_due DECIMAL(12,2) NOT NULL,
    payment_status ENUM('pending', 'partial', 'paid', 'overdue') DEFAULT 'pending',
    tally_invoice_number VARCHAR(100),
    invoice_pdf_url VARCHAR(500),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_invoice_number (invoice_number),
    INDEX idx_order_id (order_id),
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE RESTRICT,
    FOREIGN KEY (vendor_id) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (buyer_id) REFERENCES users(id) ON DELETE RESTRICT
);

-- Invoice items
CREATE TABLE IF NOT EXISTS invoice_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    invoice_id INT NOT NULL,
    order_item_id INT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    batch_number VARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    gst_percentage DECIMAL(5,2) NOT NULL,
    gst_amount DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE,
    FOREIGN KEY (order_item_id) REFERENCES order_items(id) ON DELETE RESTRICT
);

-- Payments
CREATE TABLE IF NOT EXISTS payments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    payment_reference VARCHAR(100) UNIQUE NOT NULL,
    invoice_id INT NOT NULL,
    order_id INT NOT NULL,
    buyer_id INT NOT NULL,
    vendor_id INT NOT NULL,
    payment_method ENUM('credit', 'online', 'cash', 'bank_transfer', 'cheque') NOT NULL,
    payment_gateway VARCHAR(100),
    transaction_id VARCHAR(200),
    amount DECIMAL(12,2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
    payment_notes TEXT,
    receipt_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_payment_reference (payment_reference),
    FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE RESTRICT,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE RESTRICT,
    FOREIGN KEY (buyer_id) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (vendor_id) REFERENCES users(id) ON DELETE RESTRICT
);

-- Buyer credit transactions
CREATE TABLE IF NOT EXISTS credit_transactions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    buyer_id INT NOT NULL,
    order_id INT,
    invoice_id INT,
    transaction_type ENUM('credit_purchase', 'payment', 'adjustment', 'refund') NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    balance_before DECIMAL(12,2) NOT NULL,
    balance_after DECIMAL(12,2) NOT NULL,
    transaction_date DATE NOT NULL,
    notes TEXT,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (buyer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE SET NULL,
    FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

-- ============================================
-- 5. INTEGRATION & SYNC TABLES
-- ============================================

-- Integration logs
CREATE TABLE IF NOT EXISTS integration_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    vendor_id INT NOT NULL,
    integration_type ENUM('tally', 'erp', 'billing') NOT NULL,
    operation_type ENUM('order_sync', 'invoice_sync', 'product_sync', 'stock_update') NOT NULL,
    entity_id INT, -- Could be order_id, invoice_id, etc.
    entity_type VARCHAR(50),
    request_data JSON,
    response_data JSON,
    status ENUM('success', 'failed', 'pending') DEFAULT 'pending',
    error_message TEXT,
    retry_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_vendor_id (vendor_id),
    INDEX idx_status (status),
    FOREIGN KEY (vendor_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Sync queue for background processing
CREATE TABLE IF NOT EXISTS sync_queue (
    id INT PRIMARY KEY AUTO_INCREMENT,
    vendor_id INT NOT NULL,
    entity_type ENUM('order', 'invoice', 'product', 'stock') NOT NULL,
    entity_id INT NOT NULL,
    operation ENUM('create', 'update', 'delete') NOT NULL,
    priority INT DEFAULT 5, -- 1=highest, 10=lowest
    status ENUM('pending', 'processing', 'completed', 'failed') DEFAULT 'pending',
    attempts INT DEFAULT 0,
    next_attempt_time TIMESTAMP NULL,
    last_error TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP NULL,
    INDEX idx_status_priority (status, priority),
    INDEX idx_vendor_entity (vendor_id, entity_type, entity_id),
    FOREIGN KEY (vendor_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================
-- 6. NOTIFICATION & COMMUNICATION TABLES
-- ============================================

-- Notifications
CREATE TABLE IF NOT EXISTS notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    notification_type ENUM('order', 'invoice', 'payment', 'stock', 'system', 'promotional') NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    data_json JSON,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    channel ENUM('app', 'sms', 'email', 'whatsapp', 'all') DEFAULT 'app',
    sent_status ENUM('pending', 'sent', 'failed') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_is_read (is_read),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- SMS logs
CREATE TABLE IF NOT EXISTS sms_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    phone_number VARCHAR(20) NOT NULL,
    message TEXT NOT NULL,
    template_id VARCHAR(100),
    sms_type ENUM('otp', 'order_update', 'promotional', 'transactional') NOT NULL,
    status ENUM('pending', 'sent', 'delivered', 'failed') DEFAULT 'pending',
    provider_response TEXT,
    message_id VARCHAR(100),
    sent_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_phone_number (phone_number),
    INDEX idx_status (status),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- ============================================
-- 7. REPORTS & ANALYTICS TABLES
-- ============================================

-- Platform commission settings
CREATE TABLE IF NOT EXISTS commission_settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    commission_type ENUM('percentage', 'fixed') DEFAULT 'percentage',
    commission_value DECIMAL(10,2) NOT NULL,
    min_order_value DECIMAL(12,2) DEFAULT 0,
    applicable_to ENUM('all', 'vendor', 'category', 'product') DEFAULT 'all',
    vendor_id INT NULL,
    category_id INT NULL,
    product_master_id INT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    effective_from DATE NOT NULL,
    effective_to DATE NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (vendor_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES product_categories(id) ON DELETE CASCADE,
    FOREIGN KEY (product_master_id) REFERENCES products_master(id) ON DELETE CASCADE
);

-- Commission transactions
CREATE TABLE IF NOT EXISTS commission_transactions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    vendor_id INT NOT NULL,
    commission_setting_id INT NOT NULL,
    order_amount DECIMAL(12,2) NOT NULL,
    commission_amount DECIMAL(12,2) NOT NULL,
    commission_status ENUM('pending', 'calculated', 'paid', 'cancelled') DEFAULT 'pending',
    payment_date DATE NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE RESTRICT,
    FOREIGN KEY (vendor_id) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (commission_setting_id) REFERENCES commission_settings(id) ON DELETE RESTRICT
);

-- Platform analytics (could be populated by a scheduled job)
CREATE TABLE IF NOT EXISTS platform_analytics (
    id INT PRIMARY KEY AUTO_INCREMENT,
    analytics_date DATE NOT NULL,
    total_users INT DEFAULT 0,
    active_users INT DEFAULT 0,
    total_orders INT DEFAULT 0,
    orders_placed INT DEFAULT 0,
    orders_delivered INT DEFAULT 0,
    total_order_value DECIMAL(15,2) DEFAULT 0,
    total_commission DECIMAL(15,2) DEFAULT 0,
    average_order_value DECIMAL(10,2) DEFAULT 0,
    new_buyers INT DEFAULT 0,
    new_vendors INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_analytics_date (analytics_date)
);

-- ============================================
-- 8. SYSTEM & ADMINISTRATION TABLES
-- ============================================

-- Admin actions log
CREATE TABLE IF NOT EXISTS admin_audit_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    admin_id INT NOT NULL,
    action_type VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id INT,
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_admin_id (admin_id),
    INDEX idx_action_type (action_type),
    FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE RESTRICT
);

-- System settings
CREATE TABLE IF NOT EXISTS system_settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT NOT NULL,
    setting_type ENUM('string', 'integer', 'boolean', 'json', 'decimal') DEFAULT 'string',
    category VARCHAR(50) DEFAULT 'general',
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- App versions for mobile apps
CREATE TABLE IF NOT EXISTS app_versions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    platform ENUM('android', 'ios') NOT NULL,
    version_code VARCHAR(20) NOT NULL,
    version_name VARCHAR(20) NOT NULL,
    is_mandatory BOOLEAN DEFAULT FALSE,
    release_notes TEXT,
    download_url VARCHAR(500),
    released_at DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 9. INDEXES FOR PERFORMANCE
-- ============================================

-- Add additional indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_orders_status ON orders(order_status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_vendor_products_stock ON vendor_products(stock_quantity, is_available);
CREATE INDEX idx_vendor_products_expiry ON vendor_products(expiry_date);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);

-- ============================================
-- 10. SAMPLE DATA INSERTION (OPTIONAL)
-- ============================================

-- Insert some sample categories
INSERT INTO product_categories (category_name, category_code, description) VALUES
('Tablets', 'TAB', 'All types of tablets'),
('Injections', 'INJ', 'Injections and vials'),
('Syrups', 'SYR', 'Liquid medications'),
('Surgical', 'SUR', 'Surgical equipment and supplies'),
('Medical Devices', 'DEV', 'Medical devices and instruments'),
('OTC', 'OTC', 'Over-the-counter products');

-- Insert system settings
INSERT INTO system_settings (setting_key, setting_value, setting_type, category, description) VALUES
('platform_name', 'Medical B2B Procurement Platform', 'string', 'general', 'Name of the platform'),
('default_commission_percentage', '2.5', 'decimal', 'commission', 'Default commission percentage'),
('order_cancellation_window_hours', '24', 'integer', 'orders', 'Hours within which order can be cancelled'),
('low_stock_threshold', '10', 'integer', 'products', 'Threshold for low stock alerts'),
('whatsapp_notifications_enabled', 'true', 'boolean', 'notifications', 'Enable WhatsApp notifications'),
('sms_rate_per_message', '0.18', 'decimal', 'billing', 'Cost per SMS message');

-- ============================================
-- 11. STORED PROCEDURES & TRIGGERS
-- ============================================

-- Trigger to update stock when order is placed
DELIMITER //
CREATE TRIGGER after_order_placed
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE vendor_products
    SET stock_quantity = stock_quantity - NEW.quantity,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = NEW.vendor_product_id;
END;
//
DELIMITER ;

-- Trigger to update buyer credit when order is placed
DELIMITER //
CREATE TRIGGER update_buyer_credit_on_order
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    IF NEW.order_status = 'placed' AND NEW.payment_method = 'credit' THEN
        UPDATE buyer_details
        SET credit_used = credit_used + NEW.final_amount
        WHERE user_id = NEW.buyer_id;

        -- Record credit transaction
        INSERT INTO credit_transactions (buyer_id, order_id, transaction_type, amount, balance_before, balance_after, transaction_date)
        SELECT
            NEW.buyer_id,
            NEW.id,
            'credit_purchase',
            NEW.final_amount,
            bd.credit_used - NEW.final_amount,
            bd.credit_used,
            CURDATE()
        FROM buyer_details bd
        WHERE bd.user_id = NEW.buyer_id;
    END IF;
END;
//
DELIMITER ;

-- Procedure to generate order number
DELIMITER //
CREATE PROCEDURE generate_order_number(IN buyer_id INT, OUT order_number VARCHAR(50))
BEGIN
    DECLARE prefix VARCHAR(5) DEFAULT 'ORD';
    DECLARE year_month VARCHAR(6);
    DECLARE sequence_num INT;

    SET year_month = DATE_FORMAT(CURDATE(), '%y%m');

    -- Get next sequence number for this month
    SELECT COALESCE(MAX(SUBSTRING(order_number, -5)), 0) + 1 INTO sequence_num
    FROM orders
    WHERE order_number LIKE CONCAT(prefix, year_month, '%');

    SET order_number = CONCAT(prefix, year_month, LPAD(sequence_num, 5, '0'));
END;
//
DELIMITER ;

-- ============================================
-- 12. VIEWS FOR REPORTING
-- ============================================

-- View for vendor dashboard
CREATE VIEW vendor_dashboard_stats AS
SELECT
    v.user_id,
    u.business_name,
    COUNT(DISTINCT o.id) as total_orders,
    SUM(CASE WHEN o.order_status = 'delivered' THEN 1 ELSE 0 END) as delivered_orders,
    SUM(o.final_amount) as total_sales,
    AVG(vp.vendor_rating) as average_rating,
    COUNT(DISTINCT o.buyer_id) as unique_customers
FROM vendor_details v
JOIN users u ON v.user_id = u.id
LEFT JOIN orders o ON o.vendor_id = u.id
LEFT JOIN vendor_products vp ON vp.vendor_id = u.id
WHERE u.is_active = TRUE
GROUP BY v.user_id, u.business_name;

-- View for buyer order history
CREATE VIEW buyer_order_history AS
SELECT
    o.buyer_id,
    u.business_name as buyer_name,
    o.id as order_id,
    o.order_number,
    o.order_status,
    o.final_amount,
    o.created_at as order_date,
    v.business_name as vendor_name,
    COUNT(oi.id) as total_items
FROM orders o
JOIN users u ON o.buyer_id = u.id
JOIN users v ON o.vendor_id = v.id
LEFT JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id, o.buyer_id, u.business_name, o.order_number, o.order_status, o.final_amount, o.created_at, v.business_name;

-- View for low stock alerts
CREATE VIEW low_stock_alerts AS
SELECT
    vp.id,
    vp.vendor_id,
    u.business_name as vendor_name,
    pm.product_name,
    pm.brand_name,
    vp.batch_number,
    vp.stock_quantity,
    vp.min_order_quantity,
    vp.expiry_date,
    DATEDIFF(vp.expiry_date, CURDATE()) as days_to_expiry
FROM vendor_products vp
JOIN users u ON vp.vendor_id = u.id
JOIN products_master pm ON vp.product_master_id = pm.id
WHERE vp.stock_quantity <= vp.min_order_quantity
   OR vp.stock_quantity <= 10 -- Threshold for low stock
   OR DATEDIFF(vp.expiry_date, CURDATE()) <= 90 -- Expiring soon
ORDER BY vp.stock_quantity ASC, vp.expiry_date ASC;

-- ============================================
-- END OF DATABASE STRUCTURE
-- ============================================