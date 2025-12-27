# 📱 Pelinus Siswa - Mobile App

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/Riverpod-00C7B7?style=for-the-badge&logo=riverpod&logoColor=white" alt="Riverpod"/>
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android"/>
  <img src="https://img.shields.io/badge/iOS-000000? style=for-the-badge&logo=ios&logoColor=white" alt="iOS"/>
</p>

## 📖 Deskripsi

**Pelinus Siswa** adalah aplikasi mobile cross-platform yang dibangun menggunakan **Flutter** untuk para siswa dalam program **Pelinus Mengajar**. Aplikasi ini memungkinkan siswa untuk mengakses materi pembelajaran, melihat PDF, dan belajar secara offline.

## 🔗 Related Repository

| Repository | Deskripsi |
|------------|-----------|
| [pelinus](https://github.com/farreladriann/pelinus) | Backend API (Express.js + TypeScript) |

## ✨ Fitur Utama

- 📚 Akses materi pembelajaran
- 📄 PDF Viewer built-in
- 📶 **Offline Mode** - Belajar tanpa koneksi internet
- 🔄 Sinkronisasi data otomatis
- 📱 Cross-platform (Android & iOS)
- 🎨 UI/UX yang user-friendly

## 🛠️ Tech Stack

| Teknologi | Kegunaan |
|-----------|----------|
| **Flutter** | Cross-platform framework |
| **Dart** | Programming language |
| **Riverpod** | State management |
| **Dio** | HTTP client untuk API calls |
| **SQLite (sqflite)** | Local database untuk offline mode |
| **flutter_pdfview** | Menampilkan file PDF |
| **connectivity_plus** | Deteksi status koneksi internet |
| **permission_handler** | Manajemen permissions |

## 🏗️ Arsitektur

Aplikasi ini menggunakan **Clean Architecture** dengan struktur: 

```
lib/
├── core/           # Utilities, constants, themes
├── data/           # Data sources, repositories implementation
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/         # Business logic layer
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/   # UI layer
│   ├── pages/
│   ├── widgets/
│   └── providers/
└── main.dart       # Entry point
```

## 🚀 Cara Menjalankan

### Prerequisites
- Flutter SDK v3.0.0+
- Dart SDK v3.0.0+
- Android Studio / VS Code
- Android SDK / Xcode (untuk iOS)

### Instalasi

```bash
# Clone repository
git clone https://github.com/farreladriann/pelinus_siswa.git
cd pelinus_siswa

# Install dependencies
flutter pub get

# Generate JSON serialization code
flutter pub run build_runner build

# Jalankan aplikasi
flutter run
```

### Build APK/IPA

```bash
# Build APK (Android)
flutter build apk --release

# Build App Bundle (Android)
flutter build appbundle --release

# Build IPA (iOS)
flutter build ios --release
```

## 📱 Screenshots

*Coming soon*

## 📋 Dependencies Utama

```yaml
dependencies:
  flutter_riverpod: ^2.4.9    # State management
  dio: ^5.3.3                  # HTTP client
  sqflite: ^2.3.0              # Local database
  flutter_pdfview: ^1.3.2      # PDF viewer
  connectivity_plus: ^5.0.2    # Network connectivity
  permission_handler: ^11.1.0  # Permissions
```

## 🔧 Konfigurasi

Pastikan untuk mengatur base URL API di konfigurasi aplikasi sesuai dengan backend yang digunakan.

## 👨‍💻 Author

**Farrel Adrian**
- GitHub: [@farreladriann](https://github.com/farreladriann)

---

⭐ Jika project ini membantu, jangan lupa berikan star!
