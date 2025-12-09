# DRP Pro - Software Requirements Specification (SRS)

**Document Version:** 1.0  
**Last Updated:** December 2025  
**Status:** Complete

---

## 1. Executive Summary

DRP Pro (Djarum Retail Partner Hub System) adalah platform manajemen retail end-to-end yang dirancang untuk mitra retail Djarum. Sistem ini menyediakan solusi terintegrasi untuk inventory management, point of sales, loyalty program, customer relationship management, dan analytics.

**Tujuan Utama:**
- Mendigitalkan proses retail modern
- Mengoptimalkan inventory dan penjualan
- Meningkatkan customer engagement melalui loyalty program
- Memberikan insights real-time untuk decision making

---

## 2. User Roles & Personas

### 2.1 Role Mapping

| Role | Deskripsi | Akses Utama |
|------|-----------|-------------|
| **Retail Partner / Store Manager** | User utama yang mengelola outlet | Semua fitur kecuali Admin Settings |
| **Sales Staff** | Kasir dan staf penjualan | Dashboard, POS, Customers, Loyalti |
| **Area Supervisor** | Monitoring multi-outlet | Dashboard Analytics, Reports |
| **Admin** | Sistem administrator | Konfigurasi, User Management, Settings |

### 2.2 User Personas

#### Budi - Retail Partner (40 tahun)
- **Objective:** Mengelola 2-3 outlet Djarum dengan efisien
- **Pain Points:** Inventory susah ditrack, customer data tersebar
- **Needs:** Dashboard intuitif, laporan otomatis, insight penjualan

#### Siti - Sales Staff (28 tahun)
- **Objective:** Proses penjualan cepat dan akurat
- **Pain Points:** Antrian pembayaran, manual stock counting
- **Needs:** QR scan cepat, loyalty point otomatis, UI yang user-friendly

---

## 3. Functional Requirements

### 3.1 Authentication & User Management

**FR-AUTH-01:** User Login
- Support email + password authentication
- Validasi kredensial terhadap Supabase Auth
- Session management dengan JWT token
- Timeout session setelah 30 menit inaktif

**FR-AUTH-02:** Password Management
- Enkripsi password dengan bcrypt
- Reset password via email
- Password strength validation (min 8 char, alfanumerik)

**FR-AUTH-03:** Role-Based Access Control (RBAC)
- Role assignment per user
- Permission matrix untuk setiap role
- Dinamis permission checking di UI dan API

### 3.2 Dashboard

**FR-DASH-01:** Analytics Overview
- Real-time sales summary (today, weekly, monthly)
- Top products & categories
- Customer count & loyalty stats
- Responsive untuk mobile & desktop

**FR-DASH-02:** Promotional Carousel
- Tampilkan promosi aktif
- Swipeable carousel interface
- Deep link ke detail promosi

**FR-DASH-03:** Quick Actions
- Shortcuts ke main features (Survey, Promosi, Pelanggan, Aktivitas)
- Customizable berdasarkan role

### 3.3 Inventory Management

**FR-INV-01:** Product CRUD
- Create product dengan barcode/SKU
- Search by name, barcode, category
- Update stock qty & pricing
- Delete dengan soft-delete (untuk audit)

**FR-INV-02:** Stock Tracking
- Real-time stock level display
- Low stock alerts (threshold configurable)
- Stock history log
- Bulk import dari CSV

**FR-INV-03:** Barcode/QR Management
- Generate QR code per product
- Print barcode label
- Barcode scanner integration

### 3.4 Point of Sales (POS)

**FR-POS-01:** Transaction Processing
- Add item by QR scan, barcode, atau manual search
- Multiple quantity & discount
- Calculate total dengan pajak (PPN 11%)
- Accept payment methods (cash, card, e-wallet)

**FR-POS-02:** Loyalty Integration
- Auto-calculate loyalty points pada penjualan
- Apply point redemption
- Print receipt dengan point summary

**FR-POS-03:** Transaction History
- Store transaction record dengan detail item
- Receipt digital & print
- Return/refund handling

### 3.5 Loyalty Program

**FR-LOY-01:** Point System
- Earning: 1 poin per Rp 1.000 (configurable)
- Point categories: Basic, Performance
- Transaction-based point calculation

**FR-LOY-02:** Rewards Catalog
- Display available rewards
- Redemption workflow
- Expiry management (12 bulan)

**FR-LOY-03:** Customer Loyalty Tracking
- View customer points & tier
- Redemption history
- Tier benefits visualization

### 3.6 Customer Management

**FR-CRM-01:** Customer Database
- Capture customer data (name, phone, email, address)
- Search existing customer
- Customer QR code generation & printing

**FR-CRM-02:** Customer Profiling
- Purchase history
- Loyalty balance
- Engagement metrics
- Lifetime value (LTV) calculation

**FR-CRM-03:** WhatsApp Integration
- Send promo via WhatsApp
- Customer engagement tracking
- Batch messaging capability

### 3.7 Promotions

**FR-PROMO-01:** Campaign Management
- Create promotion dengan period, discount %, terms
- Active/inactive toggle
- Target segment (all, category, customer tier)

**FR-PROMO-02:** Performance Tracking
- Track promo usage per transaction
- ROI calculation
- Comparison reporting

### 3.8 Surveys

**FR-SURVEY-01:** Survey Management
- Create custom survey questions
- Multiple question types (multi-choice, rating, open text)
- Active survey list for customer

**FR-SURVEY-02:** Response Collection
- Capture survey responses post-transaction
- Data aggregation & analysis
- Feedback review workflow

### 3.9 Activity & Audit

**FR-AUDIT-01:** Activity Logging
- Log semua user actions (create, update, delete)
- Timestamp & user info
- Data change tracking

**FR-AUDIT-02:** Audit Trail
- Filterable activity log view
- Export untuk compliance
- Immutable logs

---

## 4. Non-Functional Requirements

### 4.1 Performance
- **Response Time:** < 2s untuk page load, < 500ms untuk API call
- **Concurrent Users:** Support minimal 100 concurrent per outlet
- **Throughput:** Min 50 transactions/sec

### 4.2 Security
- **Authentication:** JWT token-based, 30-min session timeout
- **Encryption:** TLS 1.3 untuk data in transit, AES-256 untuk sensitive data at rest
- **Authorization:** Row-Level Security (RLS) di database level
- **Compliance:** GDPR basic principles, data retention policy

### 4.3 Reliability & Availability
- **Uptime:** 99.5% SLA
- **Recovery Time Objective (RTO):** < 30 menit
- **Recovery Point Objective (RPO):** < 1 jam
- **Backup Frequency:** Daily automated backups

### 4.4 Scalability
- **Horizontal Scaling:** Support multi-tenant architecture preparation
- **Database:** Partitioning untuk large transaction tables
- **Caching:** Redis untuk session & frequently accessed data

### 4.5 Usability
- **UI/UX:** Mobile-first responsive design
- **Accessibility:** WCAG 2.1 Level AA minimum
- **Localization:** Support Bahasa Indonesia
- **Offline:** Sync capability untuk basic functions

### 4.6 Maintainability
- **Code Quality:** SonarQube standard minimum B rating
- **Documentation:** Inline comments, API docs, runbook
- **Testing:** Min 70% code coverage, CI/CD automation

---

## 5. System Use Cases

### UC-01: Daily Sales Transaction
1. Salesman login ke sistem
2. Customer approach with item
3. Scan product barcode / QR
4. System apply loyalty auto-point
5. Process payment
6. Print receipt
7. Update inventory

### UC-02: Loyalty Point Redemption
1. Customer check available rewards
2. Select reward item
3. Confirm redemption
4. System deduct points
5. Fulfill reward (physical gift/discount)

### UC-03: Inventory Stock Opname
1. Store manager scan all products
2. System compare with DB
3. Record discrepancy
4. Submit report
5. Admin approval
6. Update master inventory

### UC-04: Promotional Campaign
1. HQ create campaign with terms
2. Push to all outlets
3. Outlets execute promo
4. System track usage
5. Generate performance report
6. Archive campaign

---

## 6. Data Requirements

### 6.1 Data Volume Estimate
- **Users:** 5,000 retail partners, 15,000 sales staff
- **Products:** ~10,000 SKU
- **Customers:** ~500,000 active
- **Transactions/Month:** ~2,000,000
- **Transaction Data Retention:** 3 tahun (GDPR)

### 6.2 Master Data
- Product master dengan category, pricing, barcode
- Customer master dengan contact & loyalty info
- Store master dengan location & manager info
- User credentials dengan role & permissions
- Promotion & Survey templates

---

## 7. Integration Points

**External Systems:**
- WhatsApp Business API (customer messaging)
- Payment Gateway (credit card, e-wallet)
- Email Service (transactional emails, password reset)
- Analytics Service (optional: Google Analytics, Mixpanel)

**Internal APIs:**
- Supabase REST API
- Power Apps Connectors
- Power Automate Triggers

---

## 8. Constraints & Limitations

- Browser support: Chrome, Edge, Safari (latest 2 versions)
- Mobile: iOS 13+, Android 8+
- Max file upload: 25MB
- Bulk import: Max 10,000 records/file
- API rate limit: 1000 req/min per user
- Max concurrent sessions: 5 per user

---

## 9. Success Criteria

- ✅ 95% uptime dalam 3 bulan pertama
- ✅ < 2 second page load time untuk 90% users
- ✅ 80%+ user adoption rate dalam 6 bulan
- ✅ Reduce manual inventory time by 70%
- ✅ Increase customer engagement by 50% (survey responses)
- ✅ Zero critical security incidents

---

## Appendix

### Change Log
| Version | Date | Changes |
|---------|------|----------|
| 1.0 | Dec 2025 | Initial SRS document |

### Document Approval
- **Prepared by:** System Architect
- **Reviewed by:** Product Manager
- **Approved by:** CTO
- **Last Review Date:** December 2025
