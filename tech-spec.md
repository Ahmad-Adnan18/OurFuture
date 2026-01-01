Dokumen ini adalah acuan mutlak (Blueprints) untuk development. Dokumen ini menggabungkan fleksibilitas pemakaian pribadi, ketahanan logika akuntansi, dan struktur arsitektur SaaS untuk masa depan.

---

# PRD: OurFuture (SaaS-Ready Couple Finance)

**Version:** 3.0 (Final)
**Date:** 1 Januari 2026
**Status:** Ready for Development
**Tech Stack:** Laravel 11, Inertia.js, React, Tailwind CSS, MySQL

---

## 1. Ringkasan Eksekutif

**OurFuture** adalah aplikasi pencatatan keuangan kolaboratif berbasis web (Ledger App) untuk pasangan. Aplikasi ini berfungsi sebagai "pusat komando" untuk memonitor aset yang tersebar di berbagai instrumen (Bank Digital, Reksadana, Cash) dan mengalokasikannya ke dalam tujuan bersama (e.g., Nikah, Rumah).

**Differentiator Utama:**

1. **Strictly SaaS Architecture:** Dibangun dengan pondasi multi-tenancy sejak baris kode pertama.
2. **Logic "Spending vs Saving":** Membedakan antara uang yang *diambil* (ditarik) dengan uang yang *dibelanjakan* untuk tujuan (progress tidak hilang).
3. **Manual Sync:** Tidak terkoneksi langsung ke Bank API (keamanan & privasi), namun didesain untuk kemudahan input manual.

---

## 2. Arsitektur Teknis (SaaS Foundation)

### A. Tech Stack

* **Backend:** Laravel 11.
* **Frontend:** React (via Inertia.js) - Memberikan pengalaman SPA.
* **Database:** MySQL 8.0+.
* **Boilerplate:** Laravel Jetstream (wajib aktifkan fitur **Teams** saat instalasi).

### B. Strategi Multi-Tenancy

* **Model:** Single Database, Shared Schema.
* **Isolation:** Setiap query database yang bersifat transaksional **WAJIB** di-scope berdasarkan `team_id`.
* **Konsep:**
* 1 User = Bisa memiliki/join banyak Team.
* 1 Team = Representasi 1 Pasangan (Workspace).
* Data Pasangan A tidak boleh terlihat oleh Pasangan B.



---

## 3. Struktur Database (Schema)

Tabel di bawah ini adalah penyempurnaan dari diskusi sebelumnya untuk mengakomodasi logika bisnis V3.0.

### A. Core Identity (Jetstream Default)

1. `users`: Data login.
2. `teams`: Workspace pasangan.
3. `team_user`: Relasi user ke team (role: owner/member).

### B. Financial Domain

**1. `storage_accounts**` (Dompet Fisik)

* `id` (BigInt, PK)
* `team_id` (FK) -> *Tenant Isolation Key*
* `name` (String) -> e.g., "Bank Jago - Kantong Nikah"
* `type` (String/Enum) -> bank, e-wallet, investment, cash
* `balance` (Decimal 15,2) -> Saldo real saat ini
* `created_at`, `updated_at`

**2. `goals**` (Pos Anggaran)

* `id` (BigInt, PK)
* `team_id` (FK)
* `title` (String) -> e.g., "Resepsi 2026"
* `target_amount` (Decimal 15,2) -> Target (e.g., 100jt)
* `current_balance` (Decimal 15,2) -> Uang yang *ready* dibelanjakan (e.g., 20jt)
* `total_collected` (Decimal 15,2) -> Akumulasi sejarah menabung (e.g., 50jt - walau 30jt sudah kepakai DP).
* `start_date` (Date)
* `estimated_date` (Date, Nullable)
* `status` (Enum: active, completed, archived)

**3. `transactions**` (Jurnal Umum)

* `id` (BigInt, PK)
* `team_id` (FK)
* `user_id` (FK) -> *Audit Trail (Siapa yang input)*
* `storage_account_id` (FK) -> Sumber/Tujuan dana
* `goal_id` (FK, Nullable) -> Jika Null, berarti "Unallocated Funds"
* `type` (Enum) -> **deposit, expense, withdrawal, adjustment**
* `amount` (Decimal 15,2)
* `date` (Date)
* `notes` (Text, Nullable)
* `created_at`, `updated_at`

---

## 4. Logika Bisnis (Business Logic Rules)

Logic ini harus diimplementasikan di **Service Layer** atau **Model Observer**, jangan di Controller agar rapi.

### Rule #1: Deposit (Menabung)

*Input:* User setor Rp 1.000.000 ke Goal "Nikah" di "Bank Jago".

* `storage_accounts.balance`: **(+)** Bertambah.
* `goals.current_balance`: **(+)** Bertambah.
* `goals.total_collected`: **(+)** Bertambah (Progress bar naik).

### Rule #2: Expense (Belanja Kebutuhan Goal)

*Input:* User bayar "DP Catering" Rp 500.000 dari Goal "Nikah" via "Bank Jago".

* `storage_accounts.balance`: **(-)** Berkurang.
* `goals.current_balance`: **(-)** Berkurang.
* `goals.total_collected`: **(=) TETAP**. (Progress bar tidak turun, karena uang itu memang terpakai sesuai tujuan).

### Rule #3: Withdrawal (Tarik Tunai/Batal Nabung)

*Input:* User ambil Rp 200.000 dari Goal "Nikah" buat beli kopi.

* `storage_accounts.balance`: **(-)** Berkurang.
* `goals.current_balance`: **(-)** Berkurang.
* `goals.total_collected`: **(-)** Berkurang. (Progress bar turun sebagai penanda performa buruk).

### Rule #4: Adjustment (Koreksi Saldo)

*Input:* Bunga bank bulan ini Rp 500 perak (tanpa alokasi goal).

* `storage_accounts.balance`: **(+)** Bertambah.
* `goal_id`: Null.
* `transaction.type`: 'adjustment'.

---

## 5. Fitur & User Interface (Scope MVP)

### A. Authentication & Onboarding

1. **Register:** Email & Password.
2. **Setup Team:** Otomatis buat team dengan nama user.
3. **Invite Partner:** Via email (menggunakan fitur bawaan Jetstream).

### B. Dashboard (Homepage)

* **Kartu Ringkasan:**
* Total Assets (Sum of Storage).
* Total Unallocated (Total Assets - Sum of Goals Current Balance).


* **Goal Cards:** Menampilkan Judul, Progress Bar (Logic: `total_collected` / `target_amount`), dan Sisa Saldo Tersedia.

### C. Manajemen Data (CRUD)

1. **Storage:** Tambah/Edit/Hapus akun bank (e.g., Bank Jago, Bibit).
2. **Goals:** Tambah/Edit/Arsipkan tujuan keuangan.

### D. Transaksi (The Core)

* **Single Form** dengan logika dinamis:
* Input Tanggal & Nominal.
* Pilih `Type` (Deposit/Expense/Withdrawal).
* Pilih `Storage`.
* Pilih `Goal` (Opsional jika tipe Adjustment/Deposit Unallocated).
* Textarea `Notes`.



---

## 6. Development Roadmap & Implementation Guide

### Phase 1: Setup & Foundation (Hari 1-2)

1. **Install Project:**
```bash
laravel new our-future --jet --stack=inertia --dark --teams

```


*(Pilih: React, No SSR, MySQL)*.
2. **Cleanup:** Hapus fitur Jetstream yang tidak perlu (seperti API tokens jika tidak dipakai) untuk menyederhanakan UI.
3. **Migration:** Buat file migration sesuai schema Database V3 di atas.

### Phase 2: Backend Logic (Hari 3-5)

1. **Models:** Setup relasi (`belongsTo`, `hasMany`).
2. **Observers:** Buat `TransactionObserver` untuk menangani update saldo otomatis (Logic Rule #1 - #4). *Ini sangat krusial agar data konsisten.*
3. **Tenant Scope:** Pastikan Trait `BelongsToTeam` terpasang di model `Goal`, `Transaction`, dan `StorageAccount`.

### Phase 3: Frontend Construction (Hari 6-10)

1. **Components:** Buat komponen UI reusable (Card, InputCurrency, ProgressBar).
2. **Pages:**
* `Dashboard.jsx`
* `Transaction/Create.jsx`
* `Goals/Index.jsx`


3. **Integration:** Sambungkan Inertia props dengan controller Laravel.

### Phase 4: Testing & Deployment (Hari 11-14)

1. **Testing Skenario:** Coba kasus "Spending vs Withdrawal" apakah angka di database benar.
2. **Deployment:** Setup VPS (Ubuntu/Nginx) atau PaaS (Railway/Fly.io).
3. **User Acceptance Test:** Ajak pasangan untuk coba input data real.

---

## 7. Catatan Keamanan (Security Checklist)

1. **Authorization:** Selalu gunakan Policy (`GoalPolicy`, `TransactionPolicy`) untuk memastikan user hanya bisa edit data milik Team-nya sendiri.
2. **Input Validation:** Validasi nominal transaksi tidak boleh negatif. Validasi `expense` tidak boleh melebihi `current_balance`.

Ini adalah **Frontend Technical Specification (PRD - Frontend Layer)**.

Dokumen ini dirancang spesifik untuk developer **React + Inertia + Tailwind** agar tidak bingung saat menyusun komponen, *state management*, dan integrasi data.

---

# Frontend Specification: OurFuture

**Tech Stack:** React.js, Inertia.js, Tailwind CSS, Headless UI / Shadcn UI (Recommended).
**Design Philosophy:** Mobile-First, Clean, Trustworthy.

## 1. Design System & UI Kit

Sebelum masuk ke halaman, kita tentukan komponen dasar (Atoms/Molecules) agar UI konsisten.

### A. Color Palette (Tailwind Config)

* **Primary:** `emerald-600` (Nuansa uang/pertumbuhan, menenangkan).
* **Danger:** `rose-500` (Untuk Withdrawal/Expense).
* **Warning:** `amber-500` (Untuk status Pending/Adjustment).
* **Background:** `slate-50` (Light mode), `slate-900` (Dark mode).
* **Card Surface:** White / `slate-800` (dengan shadow tipis `shadow-sm`).

### B. Core Components (Reusable)

1. **`Card`**: Container putih dengan rounded-lg dan shadow-sm.
2. **`MoneyInput`**: Input field yang otomatis format Rupiah (e.g., ketik `1000` jadi `Rp 1.000`). *Library saran: `react-number-format*`.
3. **`ProgressBar`**: Bar dengan 2 layer (background abu-abu, foreground primary color sesuai %).
4. **`Badge`**: Pill shape kecil untuk status (Active, Completed).
5. **`FloatingActionButton (FAB)`**: Tombol "+" bulat melayang di pojok kanan bawah (khusus Mobile) untuk "Quick Transaction".

---

## 2. Layout Structure

Menggunakan **Persistent Layout** di Inertia (`AppLayout.jsx`).

* **Desktop:** Sidebar navigasi di kiri (Dashboard, Transactions, Goals, Storage, Settings).
* **Mobile:** Bottom Navigation Bar (mirip aplikasi mobile native).
* **Header:** Menampilkan Nama Team/Workspace dan User Profile Dropdown.
* **Flash Message Handler:** Komponen global untuk menangkap `page.props.flash` (Success/Error) dan menampilkannya sebagai **Toast Notification**.

---

## 3. Page Specifications (Detail per Halaman)

### A. Page: Dashboard (`/dashboard`)

*Tujuan: Helikopter view kondisi keuangan saat ini.*

**1. Inertia Props (Data dari Laravel):**

```json
{
  "totalAssets": 15000000,
  "unallocatedFunds": 2000000,
  "activeGoals": [
    { "id": 1, "title": "Nikah", "progress_percent": 45, "current": 4500000, "target": 10000000 }
  ],
  "recentTransactions": [ ...limit 5 ]
}

```

**2. Komponen UI:**

* **Asset Summary Cards:**
* Card 1: "Total Aset" (Big Text, Emerald Color).
* Card 2: "Dana Bebas/Unallocated" (Text, Slate Color). *Tooltip: Dana yang belum dimasukkan ke Goal manapun.*


* **Goals Grid:** Grid 2 kolom (Mobile 1 kolom). Menampilkan `GoalCard` (Judul, Nominal, Progress Bar).
* **Recent Activity:** List simpel transaksi terakhir (Icon Panah Atas/Bawah, Judul, Tanggal, Nominal).

---

### B. Page: Goals Index (`/goals`)

*Tujuan: Memonitor progres detail dan menambah tujuan baru.*

**1. Inertia Props:**

```json
{
  "goals": [Array of Goal Objects],
  "filters": { "status": "active" } // Untuk tab Active/Archived
}

```

**2. Komponen UI:**

* **Header:** Judul "Financial Goals" + Tombol "New Goal".
* **Tab Switcher:** Active | Completed.
* **Goal List Item:** Card yang lebih detail daripada Dashboard.
* Menampilkan: `Total Collected` vs `Target`.
* Menampilkan: Estimasi waktu tercapai (jika backend mengirimkan data forecasting).
* Action: tombol "Edit" dan "Top Up" (Link ke form transaksi dengan pre-filled goal_id).



**3. Modal: Create/Edit Goal**

* **Fields:**
* `Title` (Text)
* `Target Amount` (MoneyInput)
* `Estimated Date` (Date Picker - Opsional)


* **State:** Gunakan `useForm` dari Inertia untuk handling submit & validation errors.

---

### C. Page: Transactions Index (`/transactions`)

*Tujuan: Buku besar pencatatan (Ledger).*

**1. Inertia Props:**

```json
{
  "transactions": { "data": [...], "links": [...] }, // Pagination
  "filters": { "month": "2026-01", "type": "all" }
}

```

**2. Komponen UI:**

* **Filter Bar:** Dropdown Bulan, Dropdown Kategori (Deposit/Expense).
* **Grouped List:** Transaksi dikelompokkan per Tanggal (Sticky Header Date).
* *Senin, 1 Jan 2026*
* [Icon Masuk] Setor Bank Jago (+ Rp 1.000.000)
* [Icon Keluar] Bayar DP Gedung (- Rp 5.000.000) - *Tampilkan Label Goal: "Nikah"*


---

### D. Page: Transaction Form (Create/Edit) (`/transactions/create`)

*Tujuan: Jantung input data. Harus sangat UX friendly.*

**1. Inertia Props:**

```json
{
  "storageAccounts": [{ "id": 1, "name": "Bank Jago", "balance": 5000000 }],
  "goals": [{ "id": 1, "title": "Nikah" }]
}

```

**2. Form Logic (Dynamic interactivity):**
Menggunakan `useForm` dengan state tambahan untuk logika UI.

* **Field 1: Type (Radio Group / Tabs)**
* Options: `Deposit` (Hijau), `Expense` (Merah), `Withdrawal` (Kuning), `Adjustment` (Abu).


* **Field 2: Amount (MoneyInput)**
* Focus otomatis saat halaman dibuka.


* **Field 3: Storage Account (Select)**
* Wajib diisi untuk semua tipe.


* **Field 4: Goal (Select)**
* *Condition:*
* Jika Type == `Deposit`: Opsional (Bisa unallocated).
* Jika Type == `Expense`: **Wajib**.
* Jika Type == `Withdrawal`: **Wajib** (Tarik dari goal mana?).
* Jika Type == `Adjustment`: Disabled/Hidden.




* **Field 5: Date (Date Picker)**
* Default: Today.


* **Field 6: Notes (Textarea)**

**3. Client-Side Validation (UX):**

* Jika Type == `Expense` atau `Withdrawal`, cek apakah `Amount` > `Storage Balance`. Jika ya, tampilkan warning merah *"Saldo di dompet ini tidak cukup!"*.

---

### E. Page: Storage Management (`/storage`)

*Tujuan: Mengatur dompet fisik.*

**1. UI List:**

* Tampilan seperti list kartu ATM.
* Menampilkan logo bank (bisa pakai icon generic berdasarkan nama bank) dan Saldo Terkini.
* **Fitur Sync:** Tombol "Update Balance" manual (Adjustment shortcut).

---

## 4. Frontend State Management Strategy

Karena aplikasi ini tidak terlalu kompleks, hindari Redux/Zustand. Gunakan *Lifting State Up* sederhana atau fitur Inertia.

1. **Form Handling:**
Wajib pakai helper `useForm` dari `@inertiajs/react`.
```javascript
const { data, setData, post, processing, errors } = useForm({
    type: 'deposit',
    amount: '',
    storage_account_id: '',
    // ...
});

```


2. **Shared State (User & Flash):**
Diakses via `usePage().props`.
```javascript
const { auth, flash } = usePage().props;
// Gunakan useEffect untuk mentrigger Toast jika flash.success ada isinya.

```


3. **Loading States:**
Setiap tombol submit harus punya state `disabled={processing}` dan menampilkan spinner loading agar user tidak double-submit.

---

## 5. Mobile Responsiveness Checklist

Karena "Couples" sering membahas keuangan sambil santai di kasur atau di kafe, **Mobile Experience adalah Kunci**.

1. **Touch Targets:** Semua tombol (terutama di form transaksi) minimal tinggi 44px.
2. **Keyboard Handling:**
* Input nominal harus memunculkan *Numeric Keypad* di HP (`inputMode="numeric"`).
* Hindari modal yang tertutup keyboard virtual.


3. **Bottom Nav:**
* Di Mobile, menu utama (Dashboard, Transaksi, Add) pindah ke bawah fixed.
* Tombol "Add" di tengah (ukurannya lebih besar).



---

## 6. Implementation Steps for Frontend

1. **Setup Layout:** Buat `AuthenticatedLayout` yang punya sidebar (desktop) dan bottom bar (mobile).
2. **Component Library:** Install Headless UI atau copy-paste komponen dasar dari Shadcn/ui (Button, Input, Card, Modal/Dialog).
3. **Create Transaction Form First:** Ini fitur paling sulit logikanya. Selesaikan dulu.
4. **Connect Dashboard:** Binding data dari Laravel ke component Card & Chart.
5. **Polish:** Tambahkan transisi animasi halus (misal pakai `framer-motion` atau standard CSS transition) saat progress bar naik.

