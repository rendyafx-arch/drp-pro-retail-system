-- DRP-PRO Retail Management System - Complete Database Schema
-- PostgreSQL/Supabase Database Schema
-- Created for Power Apps Integration

-- ============================================================================
-- USERS TABLE - Authentication & User Management
-- ============================================================================
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT auth.uid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  full_name VARCHAR(255),
  phone VARCHAR(20),
  role VARCHAR(50) DEFAULT 'staff', -- 'owner', 'manager', 'staff'
  store_id UUID REFERENCES stores(id),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_store_id ON users(store_id);
CREATE INDEX idx_users_email ON users(email);

-- ============================================================================
-- STORES TABLE - Retail Store Locations
-- ============================================================================
CREATE TABLE stores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  address TEXT NOT NULL,
  phone VARCHAR(20),
  email VARCHAR(255),
  owner_id UUID REFERENCES users(id),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_stores_owner_id ON stores(owner_id);

-- ============================================================================
-- PRODUCTS TABLE - Product Catalog
-- ============================================================================
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) NOT NULL,
  name VARCHAR(255) NOT NULL,
  sku VARCHAR(100) UNIQUE NOT NULL,
  barcode VARCHAR(255),
  category VARCHAR(100),
  description TEXT,
  base_price DECIMAL(10,2) NOT NULL,
  current_price DECIMAL(10,2) NOT NULL,
  cost_price DECIMAL(10,2),
  quantity_in_stock INTEGER DEFAULT 0,
  reorder_level INTEGER DEFAULT 10,
  supplier_id UUID,
  status VARCHAR(50) DEFAULT 'active',
  image_url VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT check_quantity_positive CHECK (quantity_in_stock >= 0),
  CONSTRAINT check_price_positive CHECK (current_price > 0)
);

CREATE INDEX idx_products_store_id ON products(store_id);
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_category ON products(category);

-- ============================================================================
-- CUSTOMERS TABLE - Loyalty Program Members
-- ============================================================================
CREATE TABLE customers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) NOT NULL,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20) UNIQUE,
  email VARCHAR(255),
  address TEXT,
  loyalty_points INTEGER DEFAULT 0,
  total_purchases DECIMAL(15,2) DEFAULT 0,
  total_transactions INTEGER DEFAULT 0,
  last_purchase_date TIMESTAMP,
  registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  tier VARCHAR(50) DEFAULT 'bronze', -- 'bronze', 'silver', 'gold', 'platinum'
  status VARCHAR(50) DEFAULT 'active',
  tags JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT check_points_positive CHECK (loyalty_points >= 0)
);

CREATE INDEX idx_customers_store_id ON customers(store_id);
CREATE INDEX idx_customers_phone ON customers(phone);
CREATE INDEX idx_customers_tier ON customers(tier);

-- ============================================================================
-- TRANSACTIONS TABLE - Sales Records
-- ============================================================================
CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) NOT NULL,
  customer_id UUID REFERENCES customers(id),
  cashier_id UUID REFERENCES users(id),
  transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  transaction_type VARCHAR(50), -- 'sale', 'return', 'exchange'
  total_amount DECIMAL(15,2) NOT NULL,
  discount_amount DECIMAL(10,2) DEFAULT 0,
  points_earned INTEGER DEFAULT 0,
  points_redeemed INTEGER DEFAULT 0,
  payment_method VARCHAR(50), -- 'cash', 'card', 'digital_wallet'
  receipt_number VARCHAR(50) UNIQUE,
  notes TEXT,
  status VARCHAR(50) DEFAULT 'completed',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT check_amount_positive CHECK (total_amount > 0)
);

CREATE INDEX idx_transactions_store_id ON transactions(store_id);
CREATE INDEX idx_transactions_customer_id ON transactions(customer_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_transactions_receipt ON transactions(receipt_number);

-- ============================================================================
-- TRANSACTION_ITEMS TABLE - Line Items
-- ============================================================================
CREATE TABLE transaction_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_id UUID REFERENCES transactions(id) NOT NULL,
  product_id UUID REFERENCES products(id) NOT NULL,
  quantity INTEGER NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  discount_percent DECIMAL(5,2) DEFAULT 0,
  line_total DECIMAL(15,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_transaction_items_transaction_id ON transaction_items(transaction_id);
CREATE INDEX idx_transaction_items_product_id ON transaction_items(product_id);

-- ============================================================================
-- REWARDS TABLE - Loyalty & Promotional Campaigns
-- ============================================================================
CREATE TABLE rewards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  reward_type VARCHAR(50), -- 'points_multiplier', 'discount', 'free_item', 'tiered'
  points_required INTEGER,
  discount_percent DECIMAL(5,2),
  applicable_products JSONB,
  start_date TIMESTAMP,
  end_date TIMESTAMP,
  is_active BOOLEAN DEFAULT true,
  max_usage_per_customer INTEGER,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_rewards_store_id ON rewards(store_id);
CREATE INDEX idx_rewards_active ON rewards(is_active);

-- ============================================================================
-- SURVEYS TABLE - Customer Feedback
-- ============================================================================
CREATE TABLE surveys (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) NOT NULL,
  customer_id UUID REFERENCES customers(id),
  transaction_id UUID REFERENCES transactions(id),
  survey_type VARCHAR(50), -- 'satisfaction', 'product_feedback', 'nps'
  rating INTEGER,
  comments TEXT,
  questions JSONB,
  status VARCHAR(50) DEFAULT 'completed',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_surveys_store_id ON surveys(store_id);
CREATE INDEX idx_surveys_customer_id ON surveys(customer_id);
CREATE INDEX idx_surveys_date ON surveys(created_at);

-- ============================================================================
-- ACTIVITIES TABLE - Audit & Analytics Logging
-- ============================================================================
CREATE TABLE activities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) NOT NULL,
  user_id UUID REFERENCES users(id),
  activity_type VARCHAR(100), -- 'login', 'transaction', 'product_update', 'inventory_adjust'
  description TEXT,
  related_entity_id UUID,
  related_entity_type VARCHAR(50),
  metadata JSONB,
  ip_address VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_activities_store_id ON activities(store_id);
CREATE INDEX idx_activities_user_id ON activities(user_id);
CREATE INDEX idx_activities_date ON activities(created_at);
CREATE INDEX idx_activities_type ON activities(activity_type);

-- ============================================================================
-- ROW-LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE rewards ENABLE ROW LEVEL SECURITY;
ALTER TABLE surveys ENABLE ROW LEVEL SECURITY;
ALTER TABLE activities ENABLE ROW LEVEL SECURITY;

-- Users can see their own profile
CREATE POLICY "users_see_own_profile"
  ON users
  FOR SELECT
  USING (id = auth.uid());

-- Users can see only their store's products
CREATE POLICY "users_see_own_store_products"
  ON products
  FOR SELECT
  USING (
    store_id IN (
      SELECT store_id FROM users WHERE id = auth.uid()
    )
  );

-- Users can see only their store's customers
CREATE POLICY "users_see_own_store_customers"
  ON customers
  FOR SELECT
  USING (
    store_id IN (
      SELECT store_id FROM users WHERE id = auth.uid()
    )
  );

-- Users can see only their store's transactions
CREATE POLICY "users_see_own_store_transactions"
  ON transactions
  FOR SELECT
  USING (
    store_id IN (
      SELECT store_id FROM users WHERE id = auth.uid()
    )
  );

-- Users can see only their store's activities
CREATE POLICY "users_see_own_store_activities"
  ON activities
  FOR SELECT
  USING (
    store_id IN (
      SELECT store_id FROM users WHERE id = auth.uid()
    )
  );

-- ============================================================================
-- SAMPLE DATA (Development/Testing)
-- ============================================================================

-- Insert sample store
INSERT INTO stores (name, address, phone, email) VALUES
('DRP Store Jakarta', 'Jalan Sudirman, Jakarta', '08123456789', 'jakarta@drp.com')
ON CONFLICT DO NOTHING;

-- Insert sample customers
INSERT INTO customers (store_id, name, phone, email, tier, loyalty_points) VALUES
((SELECT id FROM stores LIMIT 1), 'Achmad Ghozali', '08121234567', 'achmad@email.com', 'silver', 1500),
((SELECT id FROM stores LIMIT 1), 'Budi Santoso', '08125555666', 'budi@email.com', 'bronze', 0)
ON CONFLICT DO NOTHING;

-- Insert sample products
INSERT INTO products (store_id, name, sku, category, base_price, current_price, quantity_in_stock) VALUES
((SELECT id FROM stores LIMIT 1), 'Product A', 'SKU001', 'Electronics', 50000, 45000, 100),
((SELECT id FROM stores LIMIT 1), 'Product B', 'SKU002', 'Fashion', 30000, 25000, 50)
ON CONFLICT (sku) DO NOTHING;

GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;
