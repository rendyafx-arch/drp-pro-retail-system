docs/FEATURES.md# DRP-PRO Features Documentation

**Last Updated:** 27 November 2025  
**Version:** 1.0.0  
**Platform:** Microsoft Power Apps + Supabase

## Table of Contents
1. [Authentication](#auth)
2. [Dashboard](#dashboard)
3. [Stock Management](#stock)
4. [POS - Scan & Jual](#pos)
5. [Loyalty Program](#loyalty)
6. [Customer Management](#customers)
7. [Promotions](#promo)
8. [Surveys](#surveys)
9. [Analytics](#analytics)
10. [User Profile](#profile)

## Authentication

### Login Screen (URL: `/auth/login`)
**Features:**
- Email & password authentication
- Connection status indicator
- Demo mode for testing
- JWT token authentication
- Security: bcrypt password hashing, rate limiting (5 attempts max)
- Auto-logout after 30 minutes inactivity

## Dashboard

### Home Screen (URL: `/dashboard`)
**Components:**
- User greeting: "Selamat datang, [User Name]!"
- Points display: "0 pts"
- Notifications counter (badge with count)
- Promotional banner with CTA
- 4 Quick action cards (Survey, Promosi, Pelanggan, Aktivitas)
- Promotional carousel (auto-scroll 5sec)
- Bottom navigation (5 tabs)

## Stock Management

### Stock Screen (URL: `/dashboard/stock`)
**Features:**
- Search bar: "Cari produk..."
- Statistics: Total (6), Aman (6), Rendah (0), Total Units (929)
- Product list with status badges
- CRUD operations (Create, Read, Update, Delete)
- Product fields: ID, Name, Barcode, Category, Stock, Status, SKU, Price

## Point of Sales

### Scan & Jual (URL: `/dashboard/scan`)
**Tabs:** Stok Masuk | Stok Keluar (default)
**Features:**
- QR Code & Barcode scanner
- Manual input (ID Promotor, Product, Quantity)
- Transaction processing
- Item list gallery
- Submit transaction

## Loyalty Program

### Poin Untung (URL: `/dashboard/reward`)
**Reward Categories:**
- Poin Basic: Uang Tunai (7,000 pts = Rp 700.000)
- Poin Performa:
  - Merchandise Menarik (8,000 pts)
  - Voucher Blibli (10,000 pts)
  - Dispenser/Setrika/Kompor (12,000 pts)
  - TV 32"/Smartphone (15,000 pts)
**Features:** Point tracking, Redemption, History

## Customer Management

### Customers (URL: `/dashboard/customer`)
**Features:**
- Total Konsumen counter
- Add customer button
- Customer cards with:
  - Avatar, Name, Customer ID
  - KTP, Email, Age, Occupation, WhatsApp
  - Points display
  - QR Code
  - Chat WA button

## Promotions

### Promotions (URL: `/dashboard/promosi`)
**Features:**
- Total Promosi & Active count
- Add new promotion
- Campaign management (CRUD)
- Performance tracking

## Surveys

### Survey Digital (URL: `/dashboard/survey`)
**Statistics:** Total (3), Completed (0), Pending (3)
**Survey Types:**
1. Survey Tingkah Laku Produk (10 questions)
2. Survey Perilaku Konsumen (10 questions)
3. Survey Kepuasan Pelanggan (10 questions)

## Analytics

### Activity Log (URL: `/dashboard/analytic`)
**Activity Summary:** Login (1), Navigasi (4), Aksi (3), Total (8)
**Activity Types:**
- Login: Green icon, timestamp, IP
- Navigation: Blue icon, screen name
- Action: Orange icon, action details

## User Profile

### Profile (URL: `/dashboard/profile`)
**Tabs:** Profil Toko | Barcode Toko
**Profile Info:**
- Avatar with upload
- Name: Achmad Ghozali
- Store: DRP Jaya Makmur
- Role: Administrator
- Member ID: F9F9F40C
- Points: 0
- Member Since: 2024
- Address: Jl. Ciwaru No.18 Bandung
**Actions:**
- Edit profile
- Change password
- Logout button
**Statistics:** Total Customers (2), Surveys (0)

## Power Apps Controls

**Data Collections:**
- Users, Products, Customers, Transactions, Rewards, Surveys, Activities

**API Integration:**
- Base URL: https://your-project.supabase.co/rest/v1
- Authentication: Bearer token
- Endpoints: /products, /customers, /transactions, etc.

---
**Status:** ✅ Ready for Power Apps implementation
**Next:** See [ARCHITECTURE.md](./ARCHITECTURE.md) & [DATABASE.md](./DATABASE.md)
