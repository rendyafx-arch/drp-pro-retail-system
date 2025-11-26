# Supabase Backend Setup Guide - DRP-PRO

## Overview
Supabase is an open-source Firebase alternative that provides PostgreSQL database, authentication, real-time subscriptions, and REST API.

## Prerequisites
- Supabase account (https://supabase.com)
- PostgreSQL knowledge
- Project credentials (API URL, Anon Key, Service Key)

## Step 1: Create Supabase Project

### 1.1 Create New Project
1. Go to [https://app.supabase.com](https://app.supabase.com)
2. Click **New Project**
3. Fill in:
   - **Project name**: `drp-pro-retail`
   - **Database password**: (strong password)
   - **Region**: Choose closest to your location
4. Click **Create new project** (takes 2-5 minutes)

### 1.2 Get Project Credentials
1. Go to **Settings** → **API**
2. Copy and save:
   - **Project URL** (for REST API)
   - **Anon Key** (for client-side)
   - **Service Role Key** (for server-side, keep secret)

## Step 2: Initialize Database Schema

### 2.1 Access SQL Editor
1. In Supabase dashboard, click **SQL Editor**
2. Click **New Query**

### 2.2 Create Tables

#### Users Table
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT auth.uid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  full_name VARCHAR(255),
  phone VARCHAR(20),
  role VARCHAR(50) DEFAULT 'staff',
  store_id UUID REFERENCES stores(id),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_store_id ON users(store_id);
CREATE INDEX idx_users_email ON users(email);
```

#### Stores Table
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
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_stores_owner_id ON stores(owner_id);
```

#### Products Table
```sql
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) NOT NULL,
  name VARCHAR(255) NOT NULL,
  sku VARCHAR(100) UNIQUE NOT NULL,
  barcode VARCHAR(255),
  category VARCHAR(100),
  base_price DECIMAL(10,2) NOT NULL,
  current_price DECIMAL(10,2) NOT NULL,
  quantity_in_stock INTEGER DEFAULT 0,
  reorder_level INTEGER DEFAULT 10,
  status VARCHAR(50) DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_products_store_id ON products(store_id);
CREATE INDEX idx_products_sku ON products(sku);
```

#### Customers Table
```sql
CREATE TABLE customers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) NOT NULL,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20) UNIQUE,
  email VARCHAR(255),
  loyalty_points INTEGER DEFAULT 0,
  tier VARCHAR(50) DEFAULT 'bronze',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_customers_store_id ON customers(store_id);
CREATE INDEX idx_customers_tier ON customers(tier);
```

#### Transactions Table
```sql
CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) NOT NULL,
  customer_id UUID REFERENCES customers(id),
  cashier_id UUID REFERENCES users(id),
  total_amount DECIMAL(15,2) NOT NULL,
  discount_amount DECIMAL(10,2) DEFAULT 0,
  points_earned INTEGER DEFAULT 0,
  payment_method VARCHAR(50),
  receipt_number VARCHAR(50) UNIQUE,
  status VARCHAR(50) DEFAULT 'completed',
  transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_transactions_store_id ON transactions(store_id);
CREATE INDEX idx_transactions_customer_id ON transactions(customer_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
```

#### Transaction Items Table
```sql
CREATE TABLE transaction_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_id UUID REFERENCES transactions(id) NOT NULL,
  product_id UUID REFERENCES products(id) NOT NULL,
  quantity INTEGER NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_transaction_items_transaction_id ON transaction_items(transaction_id);
```

#### Customers Table
```sql
CREATE TABLE rewards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  reward_type VARCHAR(50),
  points_required INTEGER,
  discount_percent DECIMAL(5,2),
  is_active BOOLEAN DEFAULT true,
  start_date TIMESTAMP,
  end_date TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_rewards_store_id ON rewards(store_id);
```

#### Surveys Table
```sql
CREATE TABLE surveys (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) NOT NULL,
  customer_id UUID REFERENCES customers(id),
  transaction_id UUID REFERENCES transactions(id),
  survey_type VARCHAR(50),
  rating INTEGER,
  comments TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_surveys_store_id ON surveys(store_id);
CREATE INDEX idx_surveys_date ON surveys(created_at);
```

#### Activities Table
```sql
CREATE TABLE activities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) NOT NULL,
  user_id UUID REFERENCES users(id),
  activity_type VARCHAR(100),
  description TEXT,
  metadata JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_activities_store_id ON activities(store_id);
CREATE INDEX idx_activities_type ON activities(activity_type);
```

## Step 3: Enable Authentication

### 3.1 Configure Email Provider
1. Go to **Authentication** → **Providers**
2. Click **Email**
3. Enable **Confirm email**
4. Set **Expiration time** to 24 hours

### 3.2 Configure Email Templates
1. Go to **Email Templates**
2. Customize:
   - Confirmation email
   - Password reset email
   - Magic link email

### 3.3 Add Redirect URLs
1. Go to **URL Configuration**
2. Add Site URLs:
   ```
   https://yourdomain.com
   https://yourdomain.com/auth/callback
   ```
3. Add Redirect URLs:
   ```
   https://yourdomain.com/dashboard
   https://yourdomain.com/auth/reset
   ```

## Step 4: Set Up Row-Level Security (RLS)

### 4.1 Enable RLS
```sql
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
```

### 4.2 Create RLS Policies

#### Products - Users see only their store products
```sql
CREATE POLICY "users_see_own_products"
  ON products
  FOR SELECT
  USING (
    store_id IN (
      SELECT store_id FROM users WHERE id = auth.uid()
    )
  );
```

#### Customers - Users see only their store customers
```sql
CREATE POLICY "users_see_own_customers"
  ON customers
  FOR SELECT
  USING (
    store_id IN (
      SELECT store_id FROM users WHERE id = auth.uid()
    )
  );
```

#### Transactions - Users see only their store transactions
```sql
CREATE POLICY "users_see_own_transactions"
  ON transactions
  FOR SELECT
  USING (
    store_id IN (
      SELECT store_id FROM users WHERE id = auth.uid()
    )
  );
```

## Step 5: Configure API Access

### 5.1 Enable PostgREST API
1. API is automatically enabled
2. Access via: `https://your-project.supabase.co/rest/v1`

### 5.2 Test API Connection
```bash
curl -X GET 'https://your-project.supabase.co/rest/v1/products' \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## Step 6: Set Up Real-time Subscriptions

### 6.1 Enable Realtime
1. Go to **Database** → **Replication**
2. Enable **Realtime** for tables:
   - products
   - transactions
   - customers

### 6.2 Configure Realtime
1. Go to **Project Settings** → **Realtime**
2. Set **Max bytes** to 1000000
3. Set **Timeout** to 60000

## Step 7: Configure Backups

### 7.1 Set Backup Policy
1. Go to **Project Settings** → **Backups**
2. Enable **Daily backups**
3. Set **Backup retention** to 30 days

### 7.2 Test Backup Restoration
1. Verify backup schedule is active
2. Test restoration process monthly

## Step 8: Set Up Monitoring

### 8.1 Enable Logs
1. Go to **Logs** → **Database** 
2. Monitor:
   - Connection logs
   - Query performance
   - Errors

### 8.2 Configure Alerts
1. Go to **Project Settings** → **Billing**
2. Set **Storage alert** at 80% usage
3. Set **API request alert** at 80% limit

## Step 9: Database Migrations

### 9.1 Create Migration File
```bash
supabase migration new add_products_table
```

### 9.2 Write Migration SQL
Edit the created migration file with your SQL:
```sql
-- Insert sample data
INSERT INTO stores (name, address, phone) VALUES
('DRP Store 1', 'Jakarta, Indonesia', '08123456789');

INSERT INTO products (store_id, name, sku, current_price, quantity_in_stock) VALUES
((SELECT id FROM stores LIMIT 1), 'Sample Product', 'SKU001', 50000, 100);
```

### 9.3 Apply Migration
```bash
supabase db push
```

## Step 10: Connection Testing

### 10.1 Test REST API
1. Use Postman or curl
2. Test endpoints:
   - GET `/products`
   - GET `/customers`
   - POST `/transactions`

### 10.2 Test Authentication
1. Sign up via email
2. Verify email confirmation
3. Test login with credentials

## Troubleshooting

### Connection Timeout
- Check network connectivity
- Verify API URL is correct
- Check API keys are valid

### RLS Errors
- Verify user is authenticated
- Check RLS policy conditions
- Ensure service role key for admin operations

### Performance Issues
- Add database indexes
- Implement query pagination
- Monitor slow queries in logs

## Related Documentation
- [ARCHITECTURE.md](../docs/ARCHITECTURE.md)
- [DATABASE.md](../docs/DATABASE.md)
- [POWERAPPS_SETUP.md](./POWERAPPS_SETUP.md)
