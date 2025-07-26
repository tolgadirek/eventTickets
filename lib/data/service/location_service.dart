import 'package:geolocator/geolocator.dart';

class LocationService {
  // İzin kontrol ve talep
  Future<bool> checkAndRequestPermission() async {
    LocationPermission permission;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false; // Konum servisi kapalı
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) { // Kontrol
      permission = await Geolocator.requestPermission(); // izin isteme
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false; // Kullanıcı ayarlardan açmalı
    }

    return true;
  }

  // Kullanıcının konumunu al
  Future<Position?> getUserLocation() async {
    bool granted = await checkAndRequestPermission();
    if (!granted) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print("Konum alınamadı: $e");
      return null;
    }
  }
}