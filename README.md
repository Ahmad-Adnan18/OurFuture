<p align="center">
  <img src="https://img.shields.io/badge/Laravel-11-FF2D20?style=for-the-badge&logo=laravel&logoColor=white" alt="Laravel 11">
  <img src="https://img.shields.io/badge/React-18-61DAFB?style=for-the-badge&logo=react&logoColor=black" alt="React">
  <img src="https://img.shields.io/badge/Inertia.js-1.0-9553E9?style=for-the-badge&logo=inertia&logoColor=white" alt="Inertia.js">
  <img src="https://img.shields.io/badge/Tailwind_CSS-3.0-38B2AC?style=for-the-badge&logo=tailwind-css&logoColor=white" alt="Tailwind CSS">
  <img src="https://img.shields.io/badge/MySQL-8.0-4479A1?style=for-the-badge&logo=mysql&logoColor=white" alt="MySQL">
</p>

# 💑 OurFuture

**OurFuture** adalah aplikasi pencatatan keuangan kolaboratif berbasis web untuk pasangan. Berfungsi sebagai "pusat komando" untuk memonitor aset yang tersebar di berbagai instrumen (Bank Digital, Reksadana, Cash) dan mengalokasikannya ke dalam tujuan bersama.

## ✨ Fitur Utama

| Fitur | Deskripsi |
|-------|-----------|
| 🏦 **Multi Storage** | Kelola berbagai dompet (Bank, E-Wallet, Investasi, Cash) |
| 🎯 **Goal Tracking** | Tetapkan tujuan keuangan bersama (Nikah, Rumah, Liburan) |
| 📊 **Smart Progress** | Logic "Spending vs Saving" - expense untuk tujuan tidak mengurangi progress |
| 👫 **Collaborative** | Undang pasangan ke workspace yang sama |
| 🔒 **Multi-Tenant** | Data pasangan A tidak terlihat oleh pasangan B |

## 🛠️ Tech Stack

- **Backend:** Laravel 11 + Jetstream (Teams)
- **Frontend:** React via Inertia.js
- **Styling:** Tailwind CSS
- **Database:** MySQL 8.0+

## 📦 Requirements

- PHP 8.2+
- Composer
- Node.js 18+
- MySQL 8.0+

## 🚀 Instalasi

### 1. Clone Repository

```bash
git clone https://github.com/your-username/our-future-saas.git
cd our-future-saas
```

### 2. Install Dependencies

```bash
composer install
npm install
```

### 3. Environment Setup

```bash
cp .env.example .env
php artisan key:generate
```

### 4. Database Configuration

Edit `.env` file:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=our_future
DB_USERNAME=root
DB_PASSWORD=
```

### 5. Run Migrations

```bash
php artisan migrate
```

### 6. Start Development Server

```bash
# Terminal 1 - Laravel Server
php artisan serve

# Terminal 2 - Vite Dev Server
npm run dev
```

Akses aplikasi di `http://localhost:8000`

## 📁 Struktur Database

```
┌─────────────────────────────────────────────────────────────┐
│                     Core Identity                           │
├─────────────────────────────────────────────────────────────┤
│  users          │ Data login user                           │
│  teams          │ Workspace pasangan                        │
│  team_user      │ Relasi user ke team (owner/member)        │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                   Financial Domain                          │
├─────────────────────────────────────────────────────────────┤
│  storage_accounts │ Dompet fisik (Bank, E-Wallet, Cash)     │
│  goals            │ Pos anggaran (Nikah, Rumah, dll)        │
│  transactions     │ Jurnal umum semua transaksi             │
└─────────────────────────────────────────────────────────────┘
```

## ⚙️ Logika Transaksi

| Type | Storage Balance | Goal Current | Goal Collected |
|------|-----------------|--------------|----------------|
| **Deposit** | ➕ Bertambah | ➕ Bertambah | ➕ Bertambah |
| **Expense** | ➖ Berkurang | ➖ Berkurang | ➡️ Tetap |
| **Withdrawal** | ➖ Berkurang | ➖ Berkurang | ➖ Berkurang |
| **Adjustment** | ➕/➖ | - | - |

> **Note:** Expense (belanja untuk goal) tidak mengurangi progress karena uang dipakai sesuai tujuan.

## 🎨 Design System

- **Primary:** `emerald-600` (Nuansa pertumbuhan)
- **Danger:** `rose-500` (Withdrawal/Expense)
- **Warning:** `amber-500` (Adjustment)
- **Background:** `slate-50` (Light) / `slate-900` (Dark)

## 📱 Responsive Design

Aplikasi dioptimalkan untuk:
- **Desktop:** Sidebar navigation
- **Mobile:** Bottom navigation bar

## 🔐 Security

- **Authorization Policy:** Memastikan user hanya bisa akses data Team-nya
- **Input Validation:** Nominal tidak boleh negatif, expense tidak boleh melebihi saldo
- **Tenant Isolation:** Setiap query di-scope berdasarkan `team_id`

## 📄 License

This project is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).

---

<p align="center">
  Made with ❤️ for couples who dream together
</p>
