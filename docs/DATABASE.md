# Database Schema - DRP-PRO Retail Management System

## Overview
The DRP-PRO database is built on PostgreSQL with Supabase as the backend service. The schema includes 8 core tables designed to support retail operations, inventory management, loyalty programs, and analytics.

## Database Tables

### 1. Users Table
Stores user account information and authentication details.

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  full_name VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  role VARCHAR(50) NOT NULL, -- 'owner', 'manager', 'staff'
  store_id UUID REFERENCES stores(id),
  password_hash VARCHAR(255) NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_login TIMESTAMP
);
```

**Key Columns:**
- `id`: Unique user identifier (UUID)
- `email`: Email address for authentication
- `full_name`: User's display name
- `role`: User type (owner, manager, or staff)
- `store_id`: Associated store reference
- `is_active`: Soft delete flag

### 2. Stores Table
Manages retail store locations and settings.

```sql
CREATE TABLE stores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  address TEXT NOT NULL,
  phone VARCHAR(20),
  email VARCHAR(255),
  owner_id UUID REFERENCES users(id),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  location_coordinates POINT,
  opening_hours JSONB
);
```

**Key Columns:**
- `id`: Unique store identifier
- `name`: Store name
- `owner_id`: Reference to store owner
- `location_coordinates`: Geographic location for store mapping
- `opening_hours`: JSON object with store hours configuration

### 3. Products Table
Catalog of products sold in the retail store.

```sql
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
  reorder_level INTEGER,
  supplier_id UUID,
  status VARCHAR(50) DEFAULT 'active', -- 'active', 'discontinued'
  image_url VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Key Columns:**
- `sku`: Stock keeping unit (product code)
- `barcode`: EAN/UPC barcode for scanning
- `quantity_in_stock`: Current inventory level
- `reorder_level`: Minimum stock alert threshold
- `base_price` vs `current_price`: Track original and promotional pricing

### 4. Customers Table
Loyalty program member profiles.

```sql
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
  tags JSONB, -- For customer segmentation
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Key Columns:**
- `loyalty_points`: Accumulated reward points
- `tier`: VIP tier based on spending
- `tags`: JSON array for customer segmentation
- `total_purchases` / `total_transactions`: Lifetime customer metrics

### 5. Transactions Table
Records of all sales transactions.

```sql
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
  status VARCHAR(50) DEFAULT 'completed', -- 'pending', 'completed', 'voided'
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Key Columns:**
- `receipt_number`: Unique transaction identifier for customers
- `points_earned` / `points_redeemed`: Track loyalty program interactions
- `payment_method`: Support for multiple payment types
- `transaction_type`: Distinguish between sales, returns, exchanges

### 6. Transaction Items Table
Line items within each transaction.

```sql
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
```

**Purpose:** Normalized structure to store individual items in transactions.

### 7. Rewards Table
Loyalty rewards and promotional campaigns.

```sql
CREATE TABLE rewards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  reward_type VARCHAR(50), -- 'points_multiplier', 'discount', 'free_item', 'tiered'
  points_required INTEGER,
  discount_percent DECIMAL(5,2),
  applicable_products JSONB, -- Array of product IDs
  start_date TIMESTAMP,
  end_date TIMESTAMP,
  is_active BOOLEAN DEFAULT true,
  max_usage_per_customer INTEGER,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Key Columns:**
- `reward_type`: Different reward mechanisms supported
- `applicable_products`: JSON array of eligible products
- `max_usage_per_customer`: Limit redemptions per person

### 8. Surveys Table
Customer feedback and satisfaction surveys.

```sql
CREATE TABLE surveys (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) NOT NULL,
  customer_id UUID REFERENCES customers(id),
  transaction_id UUID REFERENCES transactions(id),
  survey_type VARCHAR(50), -- 'satisfaction', 'product_feedback', 'nps'
  rating INTEGER, -- 1-5 or 1-10 scale
  comments TEXT,
  questions JSONB, -- Survey question responses
  status VARCHAR(50) DEFAULT 'completed',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Key Columns:**
- `survey_type`: Different survey templates
- `questions`: JSON object storing responses to multiple questions
- `rating`: Overall satisfaction or NPS score

### 9. Activities Table
Activity logging for analytics and audit trail.

```sql
CREATE TABLE activities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) NOT NULL,
  user_id UUID REFERENCES users(id),
  activity_type VARCHAR(100), -- 'login', 'transaction', 'product_update', 'inventory_adjust'
  description TEXT,
  related_entity_id UUID,
  related_entity_type VARCHAR(50), -- 'transaction', 'product', 'customer'
  metadata JSONB,
  ip_address VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Purpose:** Complete audit trail and activity logging for analytics dashboard.

## Indexes

Optimization indexes for performance:

```sql
-- Users
CREATE INDEX idx_users_store_id ON users(store_id);
CREATE INDEX idx_users_email ON users(email);

-- Products
CREATE INDEX idx_products_store_id ON products(store_id);
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_category ON products(category);

-- Customers
CREATE INDEX idx_customers_store_id ON customers(store_id);
CREATE INDEX idx_customers_phone ON customers(phone);
CREATE INDEX idx_customers_tier ON customers(tier);

-- Transactions
CREATE INDEX idx_transactions_store_id ON transactions(store_id);
CREATE INDEX idx_transactions_customer_id ON transactions(customer_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_transactions_receipt ON transactions(receipt_number);

-- Transaction Items
CREATE INDEX idx_transaction_items_transaction_id ON transaction_items(transaction_id);
CREATE INDEX idx_transaction_items_product_id ON transaction_items(product_id);

-- Rewards
CREATE INDEX idx_rewards_store_id ON rewards(store_id);
CREATE INDEX idx_rewards_active ON rewards(is_active);

-- Surveys
CREATE INDEX idx_surveys_store_id ON surveys(store_id);
CREATE INDEX idx_surveys_customer_id ON surveys(customer_id);
CREATE INDEX idx_surveys_date ON surveys(created_at);

-- Activities
CREATE INDEX idx_activities_store_id ON activities(store_id);
CREATE INDEX idx_activities_user_id ON activities(user_id);
CREATE INDEX idx_activities_date ON activities(created_at);
CREATE INDEX idx_activities_type ON activities(activity_type);
```

## Row-Level Security (RLS)

RLS policies ensure users only access their store's data:

```sql
-- Products RLS
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their store's products"
  ON products
  FOR SELECT
  USING (
    store_id IN (
      SELECT store_id FROM users WHERE id = auth.uid()
    )
  );

-- Customers RLS
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their store's customers"
  ON customers
  FOR SELECT
  USING (
    store_id IN (
      SELECT store_id FROM users WHERE id = auth.uid()
    )
  );

-- Transactions RLS
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their store's transactions"
  ON transactions
  FOR SELECT
  USING (
    store_id IN (
      SELECT store_id FROM users WHERE id = auth.uid()
    )
  );
```

## Data Integrity Constraints

```sql
-- Ensure products have non-negative quantities
ALTER TABLE products
ADD CONSTRAINT check_quantity_positive CHECK (quantity_in_stock >= 0);

-- Ensure prices are positive
ALTER TABLE products
ADD CONSTRAINT check_price_positive CHECK (current_price > 0);

-- Ensure transaction totals are accurate
ALTER TABLE transactions
ADD CONSTRAINT check_amount_positive CHECK (total_amount > 0);

-- Ensure loyalty points are non-negative
ALTER TABLE customers
ADD CONSTRAINT check_points_positive CHECK (loyalty_points >= 0);
```

## Backup & Disaster Recovery

Database backup strategy:
- **Automated Daily Backups**: Supabase automated backup to 30-day retention
- **Point-in-Time Recovery**: Available for all data
- **Backup Testing**: Monthly restore tests to ensure recoverability

## Related Documentation
- [ARCHITECTURE.md](./ARCHITECTURE.md) - System architecture and data flows
- [FEATURES.md](./FEATURES.md) - Feature specifications
- [API.md](./API.md) - REST API endpoint documentation
