# ✈️ Daftar Pesawat - Mini Project 2

Aplikasi mobile Flutter untuk mengelola daftar pesawat dengan integrasi database Supabase.

---

## 📱 Deskripsi Aplikasi

**Daftar Pesawat** adalah aplikasi mobile yang memungkinkan pengguna untuk menyimpan, melihat, mengubah, dan menghapus data pesawat secara real-time menggunakan Supabase sebagai backend database. Aplikasi ini juga dilengkapi dengan sistem autentikasi pengguna dan tampilan Light/Dark Mode.

---

## ✨ Fitur Aplikasi

### Fitur Wajib
- ✅ **Create** – Menambahkan data pesawat baru ke Supabase
- ✅ **Read** – Menampilkan daftar pesawat dari Supabase secara real-time
- ✅ **Update** – Mengedit data pesawat yang sudah ada
- ✅ **Delete** – Menghapus data pesawat dengan konfirmasi dialog
- ✅ **Navigasi** – Halaman List Data dan Halaman Form Tambah/Edit Data

### Nilai Tambah
- 🔐 **Login & Register** menggunakan Supabase Auth
- 🌓 **Light Mode & Dark Mode** dengan toggle di AppBar (preferensi disimpan lokal)
- 🔒 **File `.env`** untuk menyimpan Supabase URL dan API Key (tidak di-push ke GitHub)

---

## 🗄️ Field Data Pesawat

Setiap data pesawat memiliki 5 field input:

| Field | Tipe | Keterangan |
|---|---|---|
| `nama` | String | Nama/seri pesawat (cth: Boeing 737-800) |
| `maskapai` | String | Nama maskapai penerbangan |
| `tahun_produksi` | Integer | Tahun pesawat diproduksi |
| `tipe_engine` | String | Tipe mesin pesawat (cth: CFM56-7B) |
| `kapasitas_penumpang` | Integer | Jumlah kapasitas penumpang |

---

## 🧩 Widget yang Digunakan

| Widget | Fungsi |
|---|---|
| `MaterialApp` | Root aplikasi dengan tema light/dark |
| `Scaffold` | Struktur dasar halaman |
| `AppBar` | Toolbar dengan tombol toggle tema dan logout |
| `ListView.builder` | Menampilkan daftar pesawat |
| `Card` | Tampilan item pesawat |
| `ListTile` | Layout konten setiap card |
| `FloatingActionButton.extended` | Tombol tambah pesawat |
| `Form` & `TextFormField` | Form input dengan validasi |
| `ElevatedButton` | Tombol aksi utama |
| `IconButton` | Tombol edit, delete, toggle tema, logout |
| `AlertDialog` | Dialog konfirmasi hapus dan logout |
| `CircularProgressIndicator` | Loading state |
| `SnackBar` | Notifikasi berhasil/gagal |
| `RefreshIndicator` | Pull-to-refresh daftar pesawat |
| `Provider` (ChangeNotifier) | State management untuk tema |
| `SingleChildScrollView` | Scrollable form |
| `Container` | Dekorasi dan layout |

---

## 🗃️ Struktur Database (Supabase)

Buat tabel `pesawat` di Supabase dengan SQL berikut:

```sql
CREATE TABLE pesawat (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nama TEXT NOT NULL,
  maskapai TEXT NOT NULL,
  tahun_produksi TEXT NOT NULL,
  tipe_engine TEXT NOT NULL,
  kapasitas_penumpang TEXT NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE pesawat ENABLE ROW LEVEL SECURITY;

-- Policy: user hanya bisa akses data miliknya sendiri
CREATE POLICY "Users can manage own pesawat"
ON pesawat
FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);
```

---

## ⚙️ Cara Setup & Menjalankan

1. **Clone repository**
   ```bash
   git clone https://github.com/username/pab-minpro2.git
   cd pab-minpro2
   ```

2. **Buat file `.env`** di root proyek:
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Buat tabel di Supabase** menggunakan SQL di atas

5. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

---

## 📦 Dependencies

```yaml
dependencies:
  supabase_flutter: ^2.5.6   # Integrasi Supabase
  flutter_dotenv: ^5.1.0     # Membaca file .env
  provider: ^6.1.2           # State management tema
  shared_preferences: ^2.3.2 # Menyimpan preferensi tema
```

---

## 🏗️ Struktur Proyek

```
lib/
├── main.dart                    # Entry point + AuthWrapper
├── models/
│   └── pesawat.dart             # Model data pesawat
├── pages/
│   ├── login_page.dart          # Halaman login
│   ├── register_page.dart       # Halaman registrasi
│   ├── home_page.dart           # Halaman daftar pesawat
│   └── form_pesawat_page.dart   # Halaman form tambah/edit
└── services/
    ├── supabase_service.dart    # Service CRUD & Auth Supabase
    └── theme_provider.dart      # Provider untuk light/dark mode
```
