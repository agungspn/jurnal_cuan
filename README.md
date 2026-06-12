# JurnalCuan - Flutter App Setup Guide

## Struktur File

```
lib/
├── main.dart                         # Entry point
├── firebase_options.dart             # Konfigurasi Firebase (WAJIB DIISI)
├── models/
│   └── journal_model.dart            # Model data trade
├── services/
│   ├── auth_service.dart             # Firebase Auth wrapper
│   └── journal_service.dart          # Firestore CRUD + Storage
├── screens/
│   ├── splash_screen.dart            # Splash + cek sesi login
│   ├── onboarding_screen.dart        # Onboarding 2 halaman
│   ├── auth_screen.dart              # Login & Register
│   ├── home_screen.dart              # Beranda / Dashboard
│   └── input_journal_screen.dart     # Form input trade
└── utils/
    └── app_theme.dart                # Warna & tema app
```

---

## Langkah Setup Firebase

### 1. Buat Project Firebase
1. Buka https://console.firebase.google.com
2. Klik **Add Project** → isi nama project misal `jurnal-cuan`
3. Aktifkan Google Analytics kalau mau (opsional)

### 2. Aktifkan Layanan Firebase
Di Firebase Console, aktifkan:
- **Authentication** → Sign-in method → Email/Password → Enable
- **Firestore Database** → Create database → Start in test mode
- **Storage** → Get started → Start in test mode

### 3. Install FlutterFire CLI & Generate Config
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Di folder project, jalankan:
flutterfire configure
```
Pilih project Firebase kamu, pilih platform (Android/iOS/Web).
Ini akan **otomatis replace** `lib/firebase_options.dart` dengan konfigurasi yang benar.

### 4. Setup Android (jika target Android)
File `google-services.json` sudah otomatis ditambahkan oleh FlutterFire CLI.

Pastikan `android/app/build.gradle` punya:
```groovy
apply plugin: 'com.google.gms.google-services'
```

Dan `android/build.gradle` punya:
```groovy
classpath 'com.google.gms:google-services:4.4.0'
```

### 5. Setup iOS (jika target iOS)
File `GoogleService-Info.plist` sudah otomatis ditambahkan.

Pastikan minimum deployment target iOS 12.0+.

---

## Upload Firestore Rules

Di Firebase Console → Firestore → Rules, paste isi `firestore.rules`:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /journals/{journalId} {
      allow read, update, delete: if request.auth != null
        && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null
        && request.auth.uid == request.resource.data.userId;
    }
  }
}
```

Di Firebase Console → Storage → Rules, paste isi `storage.rules`.

---

## Jalankan App

```bash
flutter pub get
flutter run
```

---

## Alur Aplikasi

```
Splash Screen (2.5 detik)
    ├── User belum login → Onboarding 1 → Onboarding 2 → Login/Register
    └── User sudah login (sesi aktif) → Beranda (langsung!)

Beranda
    ├── Lihat semua jurnal MILIK SENDIRI (privat per user)
    ├── Statistik: PnL total, Win Rate, Total Trade
    └── FAB (+) → Form Input Trade

Form Input Trade
    ├── Kode saham, harga beli/jual, lot, tanggal
    ├── Setup trading & emosi (opsional)
    ├── Catatan analisa (opsional)
    ├── Upload screenshot chart (opsional)
    └── Auto-hitung PnL dengan preview real-time
```

---

## Cara Kerja Keamanan Data

1. **Firebase Auth**: Setiap user punya UID unik
2. **Saat simpan trade**: UID otomatis disisipkan ke data
3. **Saat baca data**: Query filter by UID → data orang lain tidak ikut tampil
4. **Firestore Rules**: Di level server, user tidak bisa akses data orang lain walau coba hack

Data kamu 100% privat dari user lain! ✅
