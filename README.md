<div align="center">

# 🛒 Inventify

**Aplikasi Kasir Digital Berbasis Android**  
Dibangun dengan Flutter & Firebase Cloud Firestore

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Android](https://img.shields.io/badge/Android-API%2021+-3DDC84?style=for-the-badge&logo=android&logoColor=white)

</div>

---

## 📖 Tentang Proyek

**Inventify** adalah aplikasi kasir digital yang dirancang untuk membantu usaha kecil menengah mengelola transaksi penjualan, stok barang, dan laporan keuangan secara real-time. Aplikasi ini dikembangkan sebagai bagian dari skripsi dengan judul:

> *"Perancangan Sistem Kasir Digital Berbasis Android Menggunakan Metode Object Oriented Analysis and Design"*
> 
> **Studi Kasus:** UD. Jasa Mandiri  
> **Universitas Mulawarman - Program Studi Sistem Informasi**

---

## ✨ Fitur Utama

| Fitur | Deskripsi |
|---|---|
| 🏠 **Beranda** | Dashboard ringkasan penjualan hari ini, total laba, dan riwayat transaksi terbaru |
| 🛍️ **Transaksi** | Proses penjualan dengan scan barcode dan perhitungan otomatis |
| 📦 **Data Produk** | Kelola stok barang — tambah, edit, hapus, dan filter per kategori |
| 📋 **Riwayat** | Histori seluruh transaksi dengan detail item dan laba |
| 📊 **Laporan** | Rekap penjualan harian/bulanan dengan grafik |
| 🖨️ **Cetak Struk** | Print struk via Bluetooth thermal printer |
| 👤 **Profil Kasir** | Manajemen akun dan pengaturan toko |

---

## 🛠️ Tech Stack

- **Framework:** Flutter (Dart)
- **Database:** Firebase Cloud Firestore (realtime sync)
- **Auth:** Firebase Authentication
- **State Management:** Provider
- **Barcode Scanner:** Mobile Scanner
- **Print:** Print Bluetooth Thermal + Printing (PDF)
- **Chart:** FL Chart
- **Export:** PDF, CSV, Share Plus

---

## 📁 Struktur Project

```
lib/
├── kasir/
│   ├── beranda/
│   │   ├── beranda.dart
│   │   ├── beranda_header.dart
│   │   ├── beranda_total_card.dart
│   │   ├── beranda_akses_cepat.dart
│   │   └── beranda_riwayat.dart
│   ├── produk.dart        # Manajemen data barang
│   ├── transaksi.dart     # Proses kasir / POS
│   ├── riwayat.dart       # Histori transaksi
│   └── profil.dart        # Profil & pengaturan
├── theme.dart             # Konstanta warna & style
└── main.dart
assets/
├── splash_screen.mp4
├── logo.jpg
└── avatar/
```

---

## 🔥 Struktur Firestore

```
produk/
  {docId}/
    name        : String
    description : String
    stock       : Number
    price       : Number
    category    : String   // "Makanan" | "Minuman" | "Snack" | "Lainnya"
    createdAt   : Timestamp
    updatedAt   : Timestamp

transaksi/
  {docId}/
    items       : Array<{name, qty, price, subtotal}>
    total       : Number
    totalLaba   : Number
    kasir       : String
    createdAt   : Timestamp
```

---

## 🚀 Cara Menjalankan

### Prasyarat

- Flutter SDK `^3.10.4`
- Android Studio / VS Code
- Akun Firebase (project aktif)
- Android device / emulator (API 21+)

### Langkah Setup

1. **Clone repository**
   ```bash
   git clone https://github.com/lakuna2/Inventify.git
   cd Inventify
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Firebase**
   - Buat project di [Firebase Console](https://console.firebase.google.com)
   - Download `google-services.json` dan letakkan di `android/app/`
   - Aktifkan **Firestore Database** dan **Authentication**

4. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

---

## 📦 Dependencies Utama

```yaml
cloud_firestore: ^6.3.0
firebase_auth: ^6.4.0
firebase_core: ^4.7.0
flutter_launcher_icons: ^0.14.4
fl_chart: ^0.68.0
mobile_scanner: ^7.2.0
print_bluetooth_thermal: ^1.2.1
printing: ^5.14.3
provider: ^6.1.5+1
share_plus: ^13.1.0
intl: ^0.18.0
pdf: ^3.12.0
csv: ^8.0.0
```

---

## 📄 Lisensi

Proyek ini dibuat untuk keperluan akademik.  
© 2026 Aulia Ade Putri - Universitas Mulawarman

---

<div align="center">
  <sub>Dibuat dengan ❤️ menggunakan Flutter & Firebase</sub>
</div>
