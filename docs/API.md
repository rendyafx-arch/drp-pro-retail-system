# REST API Documentation - DRP-PRO Retail Management System

## Base URL
```
https://api.drp-pro.com/v1
```

## Authentication
All API requests require authentication using JWT bearer tokens obtained from Supabase authentication.

**Header:**
```
Authorization: Bearer {jwt_token}
```

## Response Format
All responses are in JSON format with the following structure:

**Success Response:**
```json
{
  "success": true,
  "data": {},
  "message": "Operation completed successfully"
}
```

**Error Response:**
```json
{
  "success": false,
  "error": "error_code",
  "message": "Human readable error message"
}
```

## Endpoints

### Products

#### GET /products
Retrieve all products for the user's store.

**Query Parameters:**
- `page` (optional): Page number for pagination (default: 1)
- `limit` (optional): Items per page (default: 20, max: 100)
- `category` (optional): Filter by category
- `search` (optional): Search by name or SKU

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Product Name",
      "sku": "SKU123",
      "barcode": "1234567890123",
      "category": "Electronics",
      "base_price": 100000,
      "current_price": 89000,
      "quantity_in_stock": 50,
      "reorder_level": 10,
      "status": "active"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150
  }
}
```

#### POST /products
Create a new product.

**Request Body:**
```json
{
  "name": "Product Name",
  "sku": "SKU123",
  "barcode": "1234567890123",
  "category": "Electronics",
  "base_price": 100000,
  "current_price": 89000,
  "cost_price": 50000,
  "quantity_in_stock": 50,
  "reorder_level": 10
}
```

#### PUT /products/{product_id}
Update product details.

**Request Body:**
```json
{
  "name": "Updated Name",
  "current_price": 85000,
  "quantity_in_stock": 45
}
```

#### DELETE /products/{product_id}
Mark product as discontinued.

**Response:**
```json
{
  "success": true,
  "message": "Product deleted successfully"
}
```

### Customers

#### GET /customers
Retrieve all customers for the user's store.

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 20)
- `tier` (optional): Filter by tier (bronze, silver, gold, platinum)
- `search` (optional): Search by name or phone

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Achmad Ghozali",
      "phone": "+62812345678",
      "email": "customer@email.com",
      "loyalty_points": 1500,
      "tier": "silver",
      "total_purchases": 2500000,
      "total_transactions": 15,
      "last_purchase_date": "2024-01-15T10:30:00Z"
    }
  ]
}
```

#### POST /customers
Register a new customer.

**Request Body:**
```json
{
  "name": "Customer Name",
  "phone": "+62812345678",
  "email": "customer@email.com",
  "address": "Jakarta, Indonesia"
}
```

#### GET /customers/{customer_id}
Retrieve specific customer details.

#### PUT /customers/{customer_id}
Update customer information.

**Request Body:**
```json
{
  "name": "Updated Name",
  "email": "newemail@email.com",
  "address": "New Address"
}
```

#### POST /customers/{customer_id}/loyalty-points
Add or redeem loyalty points.

**Request Body:**
```json
{
  "action": "add",
  "points": 100,
  "reason": "Purchase transaction",
  "transaction_id": "uuid"
}
```

### Transactions

#### GET /transactions
Retrieve all transactions.

**Query Parameters:**
- `date_from` (optional): Start date (ISO 8601)
- `date_to` (optional): End date (ISO 8601)
- `customer_id` (optional): Filter by customer
- `type` (optional): Filter by type (sale, return, exchange)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "receipt_number": "RCP-2024-001",
      "customer_id": "uuid",
      "transaction_date": "2024-01-15T10:30:00Z",
      "total_amount": 250000,
      "discount_amount": 10000,
      "points_earned": 240,
      "payment_method": "cash",
      "items": [
        {
          "product_id": "uuid",
          "quantity": 2,
          "unit_price": 125000,
          "line_total": 250000
        }
      ]
    }
  ]
}
```

#### POST /transactions
Create a new transaction (POS sale).

**Request Body:**
```json
{
  "customer_id": "uuid",
  "items": [
    {
      "product_id": "uuid",
      "quantity": 2,
      "unit_price": 125000
    }
  ],
  "discount_percent": 4,
  "payment_method": "cash",
  "points_redeemed": 0
}
```

#### GET /transactions/{transaction_id}
Retrieve transaction details.

#### POST /transactions/{transaction_id}/void
Void/cancel a transaction.

### Rewards

#### GET /rewards
Retrieve active rewards.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Summer Sale",
      "reward_type": "points_multiplier",
      "description": "2x points on all purchases",
      "start_date": "2024-01-01T00:00:00Z",
      "end_date": "2024-03-31T23:59:59Z",
      "is_active": true
    }
  ]
}
```

#### POST /rewards
Create a new reward campaign.

**Request Body:**
```json
{
  "name": "Campaign Name",
  "description": "Campaign description",
  "reward_type": "points_multiplier",
  "points_required": 500,
  "discount_percent": 10,
  "start_date": "2024-02-01T00:00:00Z",
  "end_date": "2024-02-28T23:59:59Z"
}
```

### Surveys

#### GET /surveys
Retrieve survey responses.

**Query Parameters:**
- `survey_type` (optional): Filter by type
- `date_from` (optional): Start date
- `date_to` (optional): End date

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "customer_id": "uuid",
      "survey_type": "satisfaction",
      "rating": 5,
      "comments": "Great service!",
      "created_at": "2024-01-15T10:30:00Z"
    }
  ]
}
```

#### POST /surveys
Submit a survey response.

**Request Body:**
```json
{
  "customer_id": "uuid",
  "transaction_id": "uuid",
  "survey_type": "satisfaction",
  "rating": 5,
  "comments": "Survey comments",
  "questions": {
    "q1": "answer1",
    "q2": "answer2"
  }
}
```

### Activities

#### GET /activities
Retrieve activity logs for analytics.

**Query Parameters:**
- `activity_type` (optional): Filter by type
- `date_from` (optional): Start date
- `date_to` (optional): End date
- `limit` (optional): Number of records (default: 100)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "user_id": "uuid",
      "activity_type": "transaction",
      "description": "Completed sale transaction",
      "related_entity_id": "uuid",
      "created_at": "2024-01-15T10:30:00Z"
    }
  ]
}
```

### Dashboard Analytics

#### GET /analytics/summary
Retrieve daily/weekly/monthly summaries.

**Query Parameters:**
- `period` (required): daily, weekly, monthly
- `date` (optional): Specific date (for daily) or month (for monthly)

**Response:**
```json
{
  "success": true,
  "data": {
    "total_sales": 5000000,
    "total_transactions": 42,
    "new_customers": 5,
    "loyalty_points_issued": 4800,
    "loyalty_points_redeemed": 1200,
    "average_transaction_value": 119047.62
  }
}
```

#### GET /analytics/inventory
Retrieve inventory status.

**Response:**
```json
{
  "success": true,
  "data": {
    "total_units": 929,
    "low_stock_items": 5,
    "out_of_stock": 2,
    "items_below_reorder": [
      {
        "id": "uuid",
        "name": "Product Name",
        "current_stock": 5,
        "reorder_level": 10
      }
    ]
  }
}
```

## Error Codes

| Code | HTTP Status | Description |
|------|------------|-------------|
| UNAUTHORIZED | 401 | Missing or invalid authentication token |
| FORBIDDEN | 403 | Insufficient permissions |
| NOT_FOUND | 404 | Resource not found |
| VALIDATION_ERROR | 400 | Invalid request parameters |
| DUPLICATE_ENTRY | 409 | Duplicate entry (e.g., duplicate SKU) |
| RATE_LIMIT | 429 | API rate limit exceeded |
| SERVER_ERROR | 500 | Internal server error |

## Rate Limiting

API requests are rate-limited to:
- 100 requests per minute for regular users
- 500 requests per minute for premium users

Rate limit info is included in response headers:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1705320600
```

## Webhooks

Supported webhook events:
- `transaction.completed` - New transaction created
- `customer.registered` - New customer registered
- `reward.redeemed` - Loyalty points redeemed
- `survey.submitted` - Survey response submitted

**Webhook Payload:**
```json
{
  "event": "transaction.completed",
  "timestamp": "2024-01-15T10:30:00Z",
  "data": {
    "id": "uuid",
    "type": "transaction",
    "resource": {}
  }
}
```

## SDK Examples

### JavaScript/Node.js
```javascript
const axios = require('axios');

const api = axios.create({
  baseURL: 'https://api.drp-pro.com/v1',
  headers: {
    'Authorization': `Bearer ${jwtToken}`
  }
});

// Get products
const products = await api.get('/products');

// Create transaction
const transaction = await api.post('/transactions', {
  customer_id: 'uuid',
  items: [...],
  payment_method: 'cash'
});
```

## Related Documentation
- [ARCHITECTURE.md](./ARCHITECTURE.md) - System architecture
- [DATABASE.md](./DATABASE.md) - Database schema
- [FEATURES.md](./FEATURES.md) - Feature specifications
