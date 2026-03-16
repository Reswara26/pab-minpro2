# ✈️ Daftar Pesawat — Mini Project 2

Aplikasi mobile Flutter untuk mengelola data pesawat secara real-time dengan integrasi Supabase sebagai backend database. Dilengkapi autentikasi pengguna, tampilan modern hitam & kuning, serta fitur-fitur yang meningkatkan kenyamanan pengguna.

---

## 📱 Deskripsi Aplikasi

**Daftar Pesawat** adalah aplikasi manajemen data pesawat berbasis Flutter yang memungkinkan pengguna untuk menambahkan, melihat, mengedit, dan menghapus data pesawat secara real-time. Setiap pengguna memiliki data tersendiri yang tersimpan aman di Supabase. Aplikasi ini merupakan kelanjutan dari Mini Project 1 dengan penambahan integrasi database, autentikasi, dan peningkatan UI/UX secara menyeluruh.

---

## ✨ Fitur Aplikasi

### Fitur Wajib
- ✅ **Create** — Menambahkan data pesawat baru ke Supabase
- ✅ **Read** — Menampilkan daftar pesawat dari Supabase secara real-time
- ✅ **Update** — Mengedit data pesawat yang sudah ada
- ✅ **Delete** — Menghapus data pesawat dengan dialog konfirmasi
- ✅ **Navigasi** — Halaman List Data dan Halaman Form Tambah/Edit

### Nilai Tambah
- 🔐 **Login & Register** menggunakan Supabase Auth
- 🌓 **Light Mode & Dark Mode** dengan toggle di AppBar (preferensi tersimpan)
- 🔒 **File `.env`** untuk menyimpan Supabase URL dan API Key (tidak di-push ke GitHub)

### Fitur Tambahan (Bonus UX)
- 🔍 **Search & Filter** — Cari pesawat berdasarkan nama, maskapai, atau tipe engine
- 📊 **Stats Banner** — Menampilkan total pesawat dan total maskapai unik secara dinamis
- 💀 **Skeleton Loading** — Placeholder animasi saat data sedang dimuat dari Supabase
- 🎬 **Animasi Transisi** — Slide transition saat membuka halaman form
- ✨ **Fade Animation** — Card pesawat muncul dengan animasi fade in
- 🔄 **Pull to Refresh** — Tarik ke bawah untuk memperbarui daftar pesawat
- 🃏 **Card Detail Lengkap** — Setiap card menampilkan semua informasi pesawat secara rapi
- 📱 **Collapsible AppBar** — AppBar mengecil otomatis saat scroll

---

## 🗄️ Field Data Pesawat

Setiap data pesawat memiliki **6 field input**:

| Field | Kolom DB | Keterangan |
|---|---|---|
| Nama Pesawat | `nama` | Nama/seri pesawat (cth: Airbus A350-1000) |
| Maskapai | `maskapai` | Nama maskapai penerbangan |
| Tahun Produksi | `tahun_produksi` | Tahun pesawat diproduksi |
| Tipe Engine | `tipe_engine` | Tipe mesin pesawat (cth:  Rolls-Royce Trent XWB-97) |
| Kapasitas Penumpang | `kapasitas_penumpang` | Jumlah kursi penumpang |
| Max Range | `max_range` | Jarak tempuh maksimum dalam satuan miles |

---

## 🧩 Widget yang Digunakan

| Widget | Fungsi |
|---|---|
| `MaterialApp` | Root aplikasi dengan dukungan tema light/dark |
| `Scaffold` | Struktur dasar setiap halaman |
| `NestedScrollView` | Scroll area dengan SliverAppBar yang collapsible |
| `SliverAppBar` | AppBar yang mengecil otomatis saat scroll |
| `SliverList` | List pesawat berbasis sliver untuk performa optimal |
| `ListView.builder` | Skeleton loading list |
| `AnimatedContainer` | Container dengan animasi transisi saat perubahan state |
| `FadeTransition` | Animasi fade in pada card pesawat |
| `ScaleTransition` | Animasi scale saat form pertama dibuka |
| `SlideTransition` | Animasi slide saat navigasi ke halaman form |
| `PageRouteBuilder` | Custom route transition antar halaman |
| `Card` | Tampilan item pesawat |
| `Stack` | Layout berlapis pada halaman login/register |
| `FlexibleSpaceBar` | Area fleksibel dalam SliverAppBar |
| `Form` & `TextFormField` | Form input dengan validasi |
| `ElevatedButton` | Tombol aksi utama |
| `OutlinedButton` | Tombol batal di halaman form |
| `FloatingActionButton.extended` | Tombol tambah pesawat |
| `IconButton` | Tombol edit, delete, toggle tema, logout |
| `AlertDialog` | Dialog konfirmasi hapus dan logout |
| `CircularProgressIndicator` | Loading state di tombol |
| `RefreshIndicator` | Pull-to-refresh daftar pesawat |
| `SnackBar` | Notifikasi floating berhasil/gagal |
| `TextField` | Search bar di halaman utama |
| `GestureDetector` | Tap handler pada teks navigasi |
| `LinearGradient` | Gradient warna pada banner & background |
| `BoxShadow` | Efek bayangan pada card dan banner |
| `Provider` (ChangeNotifier) | State management untuk tema |
| `SingleChildScrollView` | Scrollable form di halaman tambah/edit |

---

## 🗃️ Setup Database (Supabase)

Jalankan SQL berikut di **Supabase SQL Editor**:

```sql
CREATE TABLE pesawat (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nama TEXT NOT NULL,
  maskapai TEXT NOT NULL,
  tahun_produksi TEXT NOT NULL,
  tipe_engine TEXT NOT NULL,
  kapasitas_penumpang TEXT NOT NULL,
  max_range TEXT NOT NULL DEFAULT '0',
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE pesawat ENABLE ROW LEVEL SECURITY;

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

2. **Buat file `.env`** di root proyek (jangan di-push ke GitHub!):
   ```
   SUPABASE_URL=https://xxxxxxxxxxxxxx.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.xxxxx
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Buat tabel** di Supabase menggunakan SQL di atas

5. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

---

## 📦 Dependencies

```yaml
dependencies:
  supabase_flutter: ^2.5.6   # Integrasi Supabase (Auth + Database)
  flutter_dotenv: ^5.1.0     # Membaca file .env
  provider: ^6.1.2           # State management tema light/dark
  shared_preferences: ^2.3.2 # Menyimpan preferensi tema secara lokal
```

---

## 🏗️ Struktur Proyek

```
lib/
├── main.dart                    # Entry point + AuthWrapper (cek session otomatis)
├── models/
│   └── pesawat.dart             # Model data pesawat + fromJson/toJson
├── pages/
│   ├── login_page.dart          # Halaman login
│   ├── register_page.dart       # Halaman registrasi
│   ├── home_page.dart           # Halaman daftar pesawat (search, stats, list)
│   └── form_pesawat_page.dart   # Halaman form tambah/edit pesawat
└── services/
    ├── supabase_service.dart    # Service CRUD & Auth Supabase
    └── theme_provider.dart      # Provider light/dark mode + definisi warna
```

---

## 🎨 Tema & Warna

Aplikasi menggunakan skema warna **Hitam & Kuning** yang modern:

| Nama | Hex | Kegunaan |
|---|---|---|
| Primary | `#FFD600` | Aksen utama, ikon, tombol |
| Primary Dark | `#FFC200` | Gradient, hover state |
| Black | `#0A0A0A` | AppBar, background login |
| Dark BG | `#111111` | Background dark mode |
| Dark Card | `#1C1C1C` | Card & surface dark mode |
| Text Muted | `#888888` | Teks sekunder & placeholder |
