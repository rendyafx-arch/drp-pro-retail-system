# DRP-PRO - Djarum Retail Partner Hub System

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Power Apps](https://img.shields.io/badge/Platform-Microsoft%20Power%20Apps-0078D4.svg)](https://powerapps.microsoft.com)
[![Backend: Supabase](https://img.shields.io/badge/Backend-Supabase-3ECF8E.svg)](https://supabase.com)
[![Status: Documentation](https://img.shields.io/badge/Status-Documentation%20Ready-blue.svg)]()

> 💱 Sistem manajemen retail end-to-end untuk jaringan Djarum Retail Partner, dibangun dengan Microsoft Power Apps + Supabase

## ✨ Fitur Utama

- ✅ **Dashboard Analytics** - Real-time overview dengan promotional carousel
- ✅ **Stock Management** - Inventory tracking dengan QR/Barcode scanning
- ✅ **Point of Sales** - Sales transactions dengan multiple input methods
- ✅ **Loyalty Program** - Poin untung dengan rewards redemption
- ✅ **Customer Database** - CRM dengan profiling lengkap
- ✅ **Promotions** - Campaign management & tracking
- ✅ **Digital Surveys** - Market research & feedback collection
- ✅ **Activity Analytics** - Audit trail & user behavior tracking
- ✅ **User Authentication** - Secure login dengan session management

## 🌟 Quick Features Overview

### 1. Authentication & Security
- Email & password login dengan session management
- JWT token authentication
- Secure password hashing
- Activity logging

### 2. Dashboard
- User personalized greeting
- Real-time points display
- Quick action buttons (Survey, Promosi, Pelanggan, Aktivitas)
- Promotional carousel
- Bottom navigation with 5 main sections

### 3. Stock Management
- Product search by name/barcode
- Statistics (Total, Aman, Rendah, Total Units)
- Product list dengan status indicators
- CRUD operations (Create, Read, Update, Delete)

### 4. Point of Sales (Scan & Jual)
- QR Code scanner
- Barcode scanner
- Manual product input
- Transaction processing

### 5. Loyalty Program (Poin Untung)
- Reward categories (Poin Basic, Poin Performa)
- Point tracking & redemption
- Reward catalog

### 6. Customer Management
- Customer database dengan profiling
- WhatsApp integration
- Customer QR code generation
- Loyalty points tracking

### 7. Promotions
- Campaign management
- Performance tracking
- Active/Inactive status

### 8. Surveys
- Digital survey management
- Multiple survey types
- Response tracking

### 9. Analytics
- Activity logging
- User behavior tracking
- Audit trail

## 🎇 Tech Stack

| Component | Technology |
|-----------|---|
| Frontend | Microsoft Power Apps (Canvas App) |
| Backend | Supabase (PostgreSQL) |
| Authentication | Supabase Auth |
| Automation | Power Automate |
| Database | PostgreSQL |
| Version Control | Git & GitHub |

## 🚀 Quick Start

### Prerequisites
- Microsoft Power Apps account
- Supabase account (Free tier available)
- Power Automate account
- Git installed locally

### Setup Steps

1. **Clone Repository**
   ```bash
   git clone https://github.com/rendyafx-arch/drp-pro-retail-system.git
   cd drp-pro-retail-system
   ```

2. **Review Documentation**
   - Baca semua file di folder `docs/`
   - Follow setup guides di folder `setup-guides/`

3. **Setup Backend**
   - Create Supabase project
   - Import database schema dari `database/schema.sql`
   - Configure authentication

4. **Setup Power Apps**
   - Create new Canvas app
   - Import screens & formulas
   - Connect data sources

5. **Setup Power Automate**
   - Create required flows
   - Connect to Supabase API

6. **Deploy**
   - Follow production checklist
   - Configure security settings

## 📚 Documentation

| Document | Purpose |
|----------|------|
| [FEATURES.md](./docs/FEATURES.md) | Complete feature documentation |
| [ARCHITECTURE.md](./docs/ARCHITECTURE.md) | System architecture & flow |
| [DATABASE.md](./docs/DATABASE.md) | Database schema & relationships |
| [API.md](./docs/API.md) | REST API endpoints & usage |

## 🇨🇳 Database Models

- **Users** - User profiles & authentication
- **Stores** - Outlet information & management
- **Products** - Inventory dengan barcode & categorization
- **Customers** - Customer profiles dengan loyalty tracking
- **Transactions** - Sales records & analytics
- **Rewards** - Loyalty points & rewards catalog
- **Surveys** - Survey questions & responses
- **Activities** - Audit trail & user behavior logs

## 🔐 Security

- Row-level security (RLS) di Supabase
- JWT token authentication
- Encrypted sensitive data
- Activity audit logging
- Role-based access control (RBAC)

## 💸 Performance

- Offline-capable dengan sync
- Optimized queries dengan indexing
- Lazy loading untuk galleries
- Data caching strategies
- Responsive design

## 🤗 Contributing

Contributions sangat welcome! Silakan:

1. Fork repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📜 License

Project ini dilisensikan di bawah MIT License - lihat file [LICENSE](./LICENSE) untuk details.

## 📄 Version History

- **v1.0.0** (2025-11-26) - Initial release dengan semua core features

---

**Last Updated:** 26 November 2025
**Repository:** https://github.com/rendyafx-arch/drp-pro-retail-system
**Live Demo:** https://drpbaru.vercel.app
