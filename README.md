# 🎟️ eventTickets

Flutter ile geliştirilen, Firebase ve Ticketmaster API entegresiyle çalışan bir etkinlik biletleme uygulaması.

## 🚀 Özellikler

- Ticketmaster API ile etkinlikleri listeleme  
- Filtreleme (tarih, şehir, kategori)  
- Firebase Authentication ile kullanıcı girişi ve kaydı  
- Realtime Database ile favori etkinlikleri kaydetme  
- GoRouter ile sayfalar arası geçiş  
- Çoklu dil desteği (İngilizce / Türkçe)  
- Responsive UI (ScreenUtil)  
- Harita ve konum erişimi  

## 📦 Kurulum

1. Depoyu klonlayın:

```bash
git clone https://github.com/tolgadirek/eventTickets.git
cd eventTickets
```

2. Bağımlılıkları yükleyin:

```bash
flutter pub get
```

3. Firebase kurulumu:

- Firebase Console'da bir proje oluşturun.  
- `android/app/google-services.json` dosyasını ekleyin.  
- Authentication (Email/Password) ve Realtime Database'i etkinleştirin.  

4. Ticketmaster API ve GoogleMaps anahtarlarını girin:  
`lib/data/service/ticketmaster_service.dart` ve `andorid/app/src/main/AndroidManifest.xml` içinde aşağıdaki satırları güncelleyin:


```dart
final String apiKey = 'YOUR_API_KEY';
```
```
android:value="YOUR_API_KEY"
```

5. Uygulamayı başlatın:

```bash
flutter run
```

## 🛠 Kullanılan Paketler

  - flutter
  - flutter_localizations
  - flutter_bloc
  - firebase_core
  - firebase_auth
  - firebase_database
  - dio
  - go_router
  - flutter_screenutil
  - url_launcher
  - google_maps_flutter
  - permission_handler
  - geolocator
  - shared_preferences


