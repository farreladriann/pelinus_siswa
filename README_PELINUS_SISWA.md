# Pelinus Siswa - Mobile Learning App

Aplikasi mobile Flutter untuk siswa yang terintegrasi dengan backend Pelinus. Aplikasi ini memungkinkan siswa untuk mengakses materi pembelajaran (teks dan PDF) secara online maupun offline.

## Fitur Utama

- **Tampilan Data**: Menampilkan daftar kelas, pelajaran di dalam kelas, dan kuis di dalam pelajaran
- **Akses Offline**: Pengguna dapat mengakses semua data teks dan materi PDF yang terakhir disinkronkan saat tidak ada koneksi internet
- **Sinkronisasi Data Otomatis**: Aplikasi secara otomatis melakukan sinkronisasi data dengan backend setiap 30 menit
- **Sinkronisasi Manual**: Tombol yang dapat ditekan pengguna untuk memicu proses sinkronisasi data secara manual
- **Penampil PDF**: Membuka dan menampilkan file PDF materi pelajaran langsung di dalam aplikasi

## Teknologi yang Digunakan

- **Flutter 3.x** dengan Dart 3.x
- **Riverpod** untuk state management
- **Sqflite** untuk database lokal
- **Dio** untuk HTTP client
- **Flutter PDFView** untuk menampilkan PDF
- **Connectivity Plus** untuk cek koneksi internet
- **Clean Architecture** dengan pemisahan layer Data, Domain, dan Presentation

## Struktur Proyek

```
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart      # Konstanta API dan konfigurasi
│   │   └── app_constants.dart      # Konstanta aplikasi
│   ├── error/
│   │   ├── exceptions.dart         # Custom exceptions
│   │   └── failures.dart           # Error handling
│   └── network/
│       └── network_info.dart       # Utility untuk cek koneksi internet
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   │   └── database_helper.dart    # Helper untuk SQLite database
│   │   └── remote/
│   │       └── api_service.dart        # Service untuk API calls
│   ├── models/
│   │   ├── kelas_model.dart           # Model data Kelas
│   │   ├── pelajaran_model.dart       # Model data Pelajaran
│   │   ├── kuis_model.dart            # Model data Kuis
│   │   └── pdf_file_model.dart        # Model data PDF File
│   └── repositories/
│       └── data_repository_impl.dart  # Implementasi repository
├── domain/
│   ├── entities/
│   │   ├── kelas.dart              # Entity Kelas
│   │   ├── pelajaran.dart          # Entity Pelajaran
│   │   ├── kuis.dart               # Entity Kuis
│   │   └── pdf_file.dart           # Entity PDF File
│   ├── repositories/
│   │   └── data_repository.dart    # Abstract repository
│   └── usecases/
│       ├── get_cached_data.dart    # Use case untuk get data cached
│       ├── sync_data.dart          # Use case untuk sinkronisasi
│       └── get_pdf_file.dart       # Use case untuk get PDF file
└── presentation/
    ├── pages/
    │   ├── home_page.dart              # Halaman utama (daftar kelas)
    │   ├── pelajaran_list_page.dart    # Halaman daftar pelajaran
    │   ├── pelajaran_detail_page.dart  # Halaman detail pelajaran & kuis
    │   └── pdf_viewer_page.dart        # Halaman penampil PDF
    └── providers/
        ├── app_providers.dart          # Provider untuk dependency injection
        ├── kelas_provider.dart         # Provider untuk state kelas
        ├── pdf_provider.dart           # Provider untuk state PDF
        └── sync_timer_provider.dart    # Provider untuk auto-sync timer
```

## Backend Integration

Aplikasi ini terhubung dengan backend yang sudah di-deploy di: `https://pelinus.vercel.app`

### API Endpoints yang digunakan:

1. **GET /cache** - Mengambil semua data kelas, pelajaran, dan kuis
2. **GET /pelajaran/{idPelajaran}/pdf** - Mengunduh file PDF materi pelajaran

## Instalasi dan Setup

### Prerequisites

- Flutter SDK 3.x atau lebih baru
- Dart SDK 3.x atau lebih baru
- Android Studio / VS Code
- Device Android / iOS atau emulator

### Langkah-langkah:

1. **Clone atau extract project**
   ```bash
   cd pelinus_siswa
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

## Cara Penggunaan

### 1. Halaman Beranda (Daftar Kelas)
- Menampilkan semua kelas yang tersedia
- Tombol sync di AppBar untuk sinkronisasi manual
- Pull-to-refresh untuk refresh data
- Tap pada kelas untuk melihat daftar pelajaran

### 2. Halaman Daftar Pelajaran
- Menampilkan semua pelajaran dalam kelas yang dipilih
- Informasi jumlah kuis per pelajaran
- Tap pada pelajaran untuk melihat detail

### 3. Halaman Detail Pelajaran
- Tombol "Lihat Materi PDF" untuk membuka PDF
- Daftar semua kuis dengan soal dan pilihan jawaban
- Jawaban yang benar ditandai dengan warna hijau

### 4. Halaman Penampil PDF
- Menampilkan file PDF materi pelajaran
- Navigasi halaman
- Indikator halaman saat ini

## Logika Sinkronisasi

### Sinkronisasi Otomatis:
- Dilakukan saat aplikasi pertama kali dibuka
- Dijalankan secara periodik setiap 30 menit
- Berjalan di background

### Sinkronisasi Manual:
- Tombol sync di AppBar halaman utama
- Pull-to-refresh di halaman utama

### Proses Sinkronisasi:
1. **Ambil Data Cache**: GET ke `/cache`
2. **Update Database**: Ganti semua data kelas, pelajaran, kuis
3. **Download PDF Baru**: Download PDF untuk pelajaran yang belum ada
4. **Hapus Data Lama**: Hapus PDF yang tidak lagi tersedia

## Mode Offline

- Semua data teks (kelas, pelajaran, kuis) disimpan di database SQLite lokal
- File PDF disimpan di storage device
- Aplikasi tetap berfungsi penuh tanpa koneksi internet
- Indikator error jika tidak ada koneksi saat sync

## Permissions (Android)

Aplikasi memerlukan permissions berikut:
- `INTERNET` - Untuk koneksi ke backend
- `ACCESS_NETWORK_STATE` - Untuk cek status koneksi
- `READ_EXTERNAL_STORAGE` - Untuk akses file PDF
- `WRITE_EXTERNAL_STORAGE` - Untuk menyimpan file PDF

## Build untuk Production

### Android APK:
```bash
flutter build apk --release
```

### Android App Bundle:
```bash
flutter build appbundle --release
```

### iOS:
```bash
flutter build ios --release
```

## Troubleshooting

### 1. Error Koneksi Internet
- Pastikan device terhubung ke internet
- Cek apakah backend `https://pelinus.vercel.app` dapat diakses

### 2. PDF Tidak Bisa Dibuka
- Pastikan file PDF sudah terdownload (cek dengan sinkronisasi)
- Restart aplikasi jika diperlukan

### 3. Data Tidak Muncul
- Lakukan sinkronisasi manual dengan tombol sync
- Pastikan backend memiliki data yang valid

## Kontribusi

Untuk pengembangan lebih lanjut:
1. Fork repository
2. Buat branch baru untuk fitur
3. Implementasi fitur dengan mengikuti arsitektur yang ada
4. Test fitur secara menyeluruh
5. Submit pull request

## Support

Untuk bantuan teknis atau bug report, silakan hubungi tim development.
