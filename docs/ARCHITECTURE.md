# DRP-PRO System Architecture

**Version:** 1.0.0  
**Last Updated:** 27 November 2025

## Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│           User Interface Layer (Mobile)             │
│         Microsoft Power Apps Canvas App             │
└────────────────┬────────────────────────────────────┘
                 │ HTTP/REST API
┌────────────────▼────────────────────────────────────┐
│      API Gateway & Authentication Layer             │
│           (Supabase Auth + JWT)                     │
└────────────────┬────────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────────┐
│      Business Logic Layer (Power Automate)          │
│   • Workflows • Triggers • Conditions • Actions     │
└────────────────┬────────────────────────────────────┘
                 │ REST API
┌────────────────▼────────────────────────────────────┐
│       Database Layer (Supabase PostgreSQL)          │
│  • Tables • RLS Policies • Real-time Subscriptions  │
└─────────────────────────────────────────────────────┘
```

## Component Architecture

### 1. Frontend Layer (Power Apps)
- **Mobile-First Canvas App**
- Responsive design for all devices
- Offline support with local collections
- Real-time data sync with Supabase

**Key Components:**
- LoginScreen
- DashboardScreen
- StockScreen
- ScanScreen
- RewardsScreen
- CustomersScreen
- ProfileScreen
- AnalyticsScreen

### 2. Authentication Layer (Supabase Auth)
- Email/Password authentication
- JWT token generation
- Session management
- Auto-logout (30 min inactivity)
- Rate limiting (5 attempts per 15 min)

### 3. API Layer (Supabase REST API)
**Base URL:** `https://your-project.supabase.co/rest/v1`

**Endpoints:**
- `/products` - Product management
- `/customers` - Customer database
- `/transactions` - Sales transactions
- `/rewards` - Loyalty program
- `/surveys` - Survey management
- `/activities` - Activity logging
- `/stores` - Store information
- `/users` - User profiles

### 4. Automation Layer (Power Automate)
- User authentication flows
- Data validation & transformation
- Business rule enforcement
- Email notifications
- WhatsApp integration (via WAHA)
- Point calculations
- Survey responses

### 5. Database Layer (Supabase PostgreSQL)
**Tables:**
- users
- stores
- products
- customers
- transactions
- rewards
- surveys
- activities

## Data Flow Architecture

### Authentication Flow
```
1. User enters email/password
2. Power Apps calls Supabase Auth API
3. Auth service validates credentials
4. JWT token generated & returned
5. Token stored in app session
6. All subsequent API calls include token
```

### Transaction Flow (Scan & Sell)
```
1. User scans barcode/QR code
2. Product details fetched from database
3. Quantity input validated
4. Transaction prepared in app
5. Power Automate flow triggered
6. Stock quantity updated
7. Transaction recorded
8. Customer points updated
9. Activity logged
```

### Data Sync Flow
```
1. Power Apps requests data
2. Supabase API retrieves from database
3. Data returned to app
4. Local collection updated
5. UI rendered with fresh data
6. Real-time subscriptions update changes
```

## Security Architecture

### Row-Level Security (RLS)
- Users can only see own store data
- Managers see team data
- Admins see all data

### API Security
- All endpoints require bearer token
- Token validation on every request
- Sensitive operations require additional confirmation
- Rate limiting enforced

### Data Encryption
- Passwords hashed with bcrypt
- Sensitive fields encrypted at rest
- HTTPS for all communications
- API keys secured in environment variables

## Scalability Architecture

### Horizontal Scaling
- Supabase handles multiple concurrent connections
- Power Automate scales automatically
- Power Apps handles up to 1000s of concurrent users

### Caching Strategy
- Local collections cache frequently accessed data
- Reduced API calls through batching
- Real-time sync for critical data

### Database Optimization
- Indexed queries for fast retrieval
- Denormalization where needed
- Archive old transactions

## Deployment Architecture

### Development
- Local Power Apps testing
- Supabase development environment
- Power Automate sandbox flows

### Staging
- Full Power Apps setup
- Supabase staging database
- Production-like flows (limited data)

### Production
- Published Power Apps
- Supabase production database
- Active Power Automate flows
- Monitoring & alerts enabled

## Disaster Recovery

- Automated database backups (daily)
- Point-in-time recovery available
- Backup retention: 30 days
- Redundancy: Multi-region option

## Integration Points

### WhatsApp Integration
- Customer notifications via WAHA
- Real-time message delivery
- Two-way communication

### QR Code Generation
- Customer ID encoding
- Dynamic QR generation
- Scannable customer identification

---

**Next:** See [DATABASE.md](./DATABASE.md) for detailed schema
