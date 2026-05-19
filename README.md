# 💍 Wedding Planner - Aplikasi Web Perencanaan Pernikahan

Aplikasi web modern berbasis HTML, CSS, dan JavaScript untuk membantu merencanakan pernikahan Anda dengan mudah dan terorganisir.

## 🎯 Fitur Utama

### 1. **Dashboard**
- Ringkasan informasi pernikahan (nama pengantin, tanggal, lokasi)
- Statistik real-time (total budget, pengeluaran, jumlah tamu, task selesai)
- Progress bar persiapan pernikahan
- Preview warna tema yang dipilih

### 2. **Moodboard & Warna Tema**
- Pilih warna utama, sekunder, dan aksen untuk tema pernikahan
- Galeri moodboard untuk inspirasi visual
- Warna tema otomatis diterapkan ke seluruh aplikasi
- Tambah/hapus item moodboard dengan URL gambar

### 3. **Budgeting & Tracking Biaya**
- Kelola kategori biaya (catering, dekorasi, fotografi, dll)
- Tracking budget vs pengeluaran aktual
- Ringkasan budget dengan persentase penggunaan
- Tabel detail dengan sisa budget per kategori

### 4. **Vendor List**
- Daftar vendor dengan kategori (fotografi, catering, makeup, dll)
- Simpan informasi kontak (telepon, email)
- Tracking biaya vendor
- Edit dan hapus vendor

### 5. **To-Do List & Timeline**
- Buat task dengan kategori dan prioritas
- Set tanggal deadline untuk setiap task
- Tandai task sebagai selesai
- Sorting otomatis berdasarkan tanggal
- Prioritas: Rendah, Sedang, Tinggi

### 6. **Tamu & Undangan**
- Kelola daftar tamu dari kedua belah pihak
- Status tracking: Belum Diundang, Diundang, Konfirmasi, Hadir, Tidak Hadir
- Simpan kontak tamu (telepon, email)
- Statistik tamu (total, konfirmasi, pending)

### 7. **Rundown Acara**
- Buat timeline acara pernikahan
- Atur waktu, lokasi, dan PIC untuk setiap acara
- Tambah catatan untuk setiap acara
- Sorting otomatis berdasarkan waktu

### 8. **Pengaturan**
- Atur informasi pernikahan (nama pengantin, tanggal, lokasi, budget)
- Pilih warna tema
- Export data ke file JSON
- Import data dari file JSON
- Hapus semua data (dengan konfirmasi)

## 🚀 Cara Menggunakan

### Instalasi
1. Download semua file (index.html, styles.css, app.js)
2. Letakkan di folder yang sama
3. Buka `index.html` di browser modern (Chrome, Firefox, Safari, Edge)

### Memulai
1. Buka aplikasi di browser
2. Klik menu **Pengaturan** untuk mengisi informasi pernikahan
3. Pilih warna tema di **Moodboard & Warna**
4. Mulai tambahkan data di setiap menu

### Navigasi
- Gunakan sidebar di sebelah kiri untuk berpindah antar halaman
- Setiap halaman memiliki form untuk menambah data baru
- Klik tombol Edit/Hapus untuk mengubah atau menghapus data

## 💾 Penyimpanan Data

Aplikasi menggunakan **Local Storage** browser untuk menyimpan data:
- Data disimpan otomatis setiap kali ada perubahan
- Data tersimpan di browser Anda (tidak dikirim ke server)
- Data akan hilang jika cache browser dihapus

### Backup Data
- Gunakan tombol **Export Data** untuk backup ke file JSON
- Gunakan tombol **Import Data** untuk restore dari file JSON

## 🎨 Kustomisasi Warna

Aplikasi mendukung kustomisasi warna tema:
1. Buka menu **Moodboard & Warna**
2. Pilih warna utama, sekunder, dan aksen
3. Warna akan otomatis diterapkan ke seluruh aplikasi
4. Warna disimpan otomatis

## 📱 Responsif

Aplikasi dirancang responsif untuk berbagai ukuran layar:
- Desktop (1920px ke atas)
- Tablet (768px - 1024px)
- Mobile (480px - 767px)
- Smartphone (di bawah 480px)

## 🔧 Teknologi

- **HTML5** - Struktur halaman
- **CSS3** - Styling dan layout responsif
- **JavaScript (Vanilla)** - Logika aplikasi
- **Local Storage API** - Penyimpanan data

## 📋 Struktur File

```
wedding_planner_gas/
├── index.html          # File HTML utama
├── styles.css          # Stylesheet
├── app.js              # JavaScript utama
└── README.md           # Dokumentasi ini
```

## 🎯 Fitur Referensi dari Google Sheets

Aplikasi ini mengadaptasi fitur-fitur dari spreadsheet "The Ultimate Engagement & Wedding Planner":

1. **Warna Tema** - Sistem warna dinamis seperti di SETTING sheet
2. **Dashboard** - Overview seperti di DASHBOARD sheet
3. **Moodboard** - Galeri visual seperti di MOODBOARD & MENU sheet
4. **Budgeting** - Tracking biaya seperti di BUDGETING sheet
5. **Vendor List** - Manajemen vendor seperti di VENDOR LIST sheet
6. **To-Do List** - Task management seperti di TO-DO-LIST sheet
7. **Tamu & Undangan** - Guest list seperti di TAMU & UNDANGAN sheet
8. **Rundown Acara** - Timeline seperti di RUNDOWN ACARA sheet

## 💡 Tips Penggunaan

1. **Mulai dari Pengaturan** - Isi informasi pernikahan terlebih dahulu
2. **Tentukan Warna Tema** - Pilih warna yang sesuai dengan konsep pernikahan
3. **Buat Budget** - Tentukan budget untuk setiap kategori
4. **Daftar Vendor** - Catat semua vendor yang akan digunakan
5. **Buat To-Do List** - Buat timeline task persiapan
6. **Kelola Tamu** - Catat semua tamu dan tracking status
7. **Buat Rundown** - Atur timeline acara hari H
8. **Backup Data** - Export data secara berkala

## 🐛 Troubleshooting

### Data tidak tersimpan
- Pastikan browser mendukung Local Storage
- Cek apakah cache browser sudah penuh
- Coba gunakan browser lain

### Warna tidak berubah
- Refresh halaman (F5)
- Clear cache browser
- Coba di browser lain

### Aplikasi lambat
- Hapus data yang tidak perlu
- Clear cache browser
- Tutup tab lain yang tidak digunakan

## 📞 Dukungan

Untuk pertanyaan atau masalah, silakan:
1. Cek dokumentasi di README ini
2. Coba refresh halaman
3. Clear cache dan coba lagi
4. Hubungi developer

## 📄 Lisensi

Aplikasi ini dibuat untuk keperluan pribadi dan dapat digunakan secara bebas.

## 🎉 Selamat Merencanakan Pernikahan Anda!

Semoga aplikasi ini membantu Anda merencanakan pernikahan impian dengan lebih mudah dan terorganisir.

---

**Versi:** 1.0  
**Terakhir diupdate:** 2024  
**Kompatibilitas:** Chrome, Firefox, Safari, Edge (versi terbaru)
