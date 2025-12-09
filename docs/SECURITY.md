# DRP Pro - Security & Access Control

**Version:** 1.0 | **Status:** Active | **Last Updated:** December 2025

## 1. Authentication Model

- **Method:** Email + Password via Supabase Auth
- **Token:** JWT (expires 30min)
- **Refresh:** 7-day refresh token rotation
- **Password:** Bcrypt hashing (cost=12)
- **Lockout:** 5 failed attempts = 30min lockout
- **Session:** HttpOnly, Secure, SameSite=Strict cookies

## 2. Role-Based Access Control (RBAC)

| Role | L | Dashboard | POS | Inventory | Customer | Analytics | Admin |
|------|---|-----------|-----|-----------|----------|-----------|-------|
| Admin | 1 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Area Supervisor | 2 | ✅ | ❌ | ✅ | ✅ | ✅ | ❌ |
| Store Manager | 3 | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| Sales Staff | 4 | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| Viewer | 5 | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ |

## 3. Row-Level Security (RLS)

```sql
-- Products: Users see only own store products
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
CREATE POLICY rls_products ON products
  FOR SELECT USING (store_id = (SELECT store_id FROM users WHERE id = auth.uid()));

-- Customers: Store managers see own customers
CREATE POLICY rls_customers ON customers
  FOR SELECT USING (store_id = (SELECT store_id FROM users WHERE id = auth.uid()));

-- Transactions: Can only read own transactions
CREATE POLICY rls_transactions ON transactions
  FOR SELECT USING (store_id = (SELECT store_id FROM users WHERE id = auth.uid()));
```

## 4. Data Protection

**Encryption at Rest:**
- Sensitive fields (phone, email, payment) use AES-256-GCM
- Password hashing: Bcrypt (never reversible)
- Key rotation: Annual

**Encryption in Transit:**
- TLS 1.3 minimum
- HSTS enabled (1 year)
- HTTPS only (no HTTP)

**Sensitive Data Masking:**
- Phone: 0812-****-7890
- Email: user@exa***le.com
- Card: 4532-****-****-9999

## 5. API Security

```http
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
X-Request-ID: <UUID>
User-Agent: <valid_user_agent>
```

**Rate Limiting:**
- 1000 req/min per user
- 100 req/10s burst
- 429 response when exceeded

**CORS Policy:**
- Origin: https://drp-pro.com
- Methods: GET, POST, PUT, DELETE
- Credentials: true
- Headers: Content-Type, Authorization

## 6. Audit & Logging

```sql
CREATE TABLE activity_logs (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users,
  action VARCHAR(50), -- CREATE, READ, UPDATE, DELETE
  entity_type VARCHAR(50), -- products, customers, transactions
  old_values JSONB,
  new_values JSONB,
  ip_address INET,
  timestamp TIMESTAMP WITH TZ DEFAULT NOW()
);

CREATE INDEX idx_user_ts ON activity_logs(user_id, timestamp DESC);
```

**Audit Trail Query:**
```sql
SELECT * FROM activity_logs
WHERE entity_type = 'customers' AND entity_id = 'cust_123'
ORDER BY timestamp DESC;
```

## 7. Compliance Standards

**GDPR (EU):**
- ✅ Right to be forgotten (soft-delete with anonymization)
- ✅ Data portability (JSON export)
- ✅ Consent tracking

**PDPA (Indonesia):**
- ✅ Data collection consent
- ✅ Purpose limitation
- ✅ Encryption of sensitive data

**PCI DSS (Payment):**
- ✅ Never store card data (use tokenization)
- ✅ TLS encrypted transmission
- ✅ Role-based access controls

## 8. Incident Response

| Severity | Response Time | Action |
|----------|---------------|--------|
| CRITICAL | Immediate | Isolate + Notify stakeholders |
| HIGH | 15 minutes | Mitigate + Investigate |
| MEDIUM | 1 hour | Patch + Security review |
| LOW | 24 hours | Fix + Document |

## 9. Security Checklist

**Pre-Production:**
- [ ] Secrets in environment variables (no hardcoded)
- [ ] Database backups encrypted
- [ ] SSL certificate valid
- [ ] Rate limiting enabled
- [ ] CORS configured
- [ ] SQL injection tests passed
- [ ] XSS/CSRF protection enabled
- [ ] Dependency scan (no critical vulns)
- [ ] Security headers configured
- [ ] Backup & recovery tested

**Post-Production:**
- [ ] Monthly penetration testing
- [ ] Quarterly dependency updates
- [ ] Annual security audit
- [ ] Incident response drills (2x/year)
- [ ] Security training updates

## 10. Contact

**Security Issues:** security@drp-pro.com
**Response SLA:** 24h acknowledgment, 72h remediation plan
**Disclosure:** 90-day responsible disclosure policy
