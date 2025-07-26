import 'package:dio/dio.dart';
import 'package:event_tickets/data/entity/event_detail.dart';
import 'package:event_tickets/data/entity/events.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../service/dio_service.dart';

class Repository {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseDatabase realtimeDB = FirebaseDatabase.instance;
  final Dio _dio = DioService.dio;

  Future<User?> girisYap(String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Giriş Hatası: $e");
      return null;
    }
  }

  Future<User?> kayitOl(String email, String password, String ad, String soyad, String dtarih, String country) async {
    try {
      // Kullanıcıyı Firebase Authentication'a kaydet
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) { // Giriş başarılıysa
        // Realtime Database'e kullanıcı bilgilerini kaydet
        await realtimeDB.ref("users/${user.uid}").set({
          "email": email,
          "ad": ad,
          "soyad": soyad,
          "dtarih": dtarih,
          "country": country,
        });

        return user;
      }
    } catch (e) {
      print("Kayıt Hatası: $e");
    }
    return null;
  }

  Future<List<Events>> loadEvents({int sayfaSayisi = 4, required String country}) async {
    List<Events> tumEtkinlikler = [];

    try {
      for (int i = 1; i <= sayfaSayisi; i++) {
        final response = await _dio.get('/events', queryParameters: {
          'countryCode': country,
          'page': i,
        });

        final List jsonList = response.data['_embedded']?['events'] ?? [];
        final List<Events> sayfaEtkinlikleri =
        jsonList.map((json) => Events.fromJson(json)).toList();

        tumEtkinlikler.addAll(sayfaEtkinlikleri);
        //Serach işlemini localde aratmak için verileri localde tutuyoruz yeniden build olana kadar
      }

      return tumEtkinlikler;
    } catch (e) {
      print('Etkinlik çekme hatası: $e');
      return [];
    }
  }

  Future<EventDetail?> getEventDetail(String eventId) async {
    try {
      final response = await _dio.get('/events/$eventId');
      final json = response.data;

      return EventDetail.fromJson(json);
    } catch (e) {
      print('Detay çekme hatası: $e');
      return null;
    }
  }

  Future<void> toggleFavorite(String eventId) async {
    final uid = auth.currentUser!.uid;
    final ref = realtimeDB.ref("favorites/$uid/$eventId");

    final snapshot = await ref.get();
    if (snapshot.exists) { // Daha önceden favorilenmişse tekrar basınca sil.
      await ref.remove();
    } else { // Öyle bir id yoksa ekle
      await ref.set(true);
    }
  }

  Future<Set<String>> getAllFavorites() async {
    final uid = auth.currentUser!.uid;
    final ref = realtimeDB.ref("favorites/$uid");

    final snapshot = await ref.get();
    if (snapshot.exists && snapshot.value is Map) {
      return Set<String>.from((snapshot.value as Map).keys); //Mapin sadece anahtarlarını alıyoruz yani idler
    } else {
      return {};
    }
  }

  Future<List<Events>> getFavoriteEvents() async {
    final ids = await getAllFavorites();
    List<Events> favorites = [];
    final uid = auth.currentUser!.uid;

    for (String id in ids) {
      final detail = await getEventDetail(id);
      if (detail != null) {
        final dateStr = detail.date;
        final timeStr = detail.time;

        if (dateStr != null && timeStr != null) {
          try {
            final eventDateTime = DateTime.parse('$dateStr $timeStr');
            if (eventDateTime.isAfter(DateTime.now())) {
              favorites.add(
                Events(
                  id: detail.id,
                  name: detail.name,
                  date: detail.date,
                  time: detail.time,
                  imageUrl: detail.imageUrl,
                  city: detail.city,
                  venueName: detail.venue,
                  segment: detail.segment,
                  genre: detail.genre,
                  organizer: detail.organizer,
                ),
              );
            } else {
              // Etkinlik geçmiş, sil
              final ref = realtimeDB.ref("favorites/$uid/$id");
              await ref.remove();
            }
          } catch (e) {
            // Tarih parse edilemedi
            print(e);
          }
        }
      } else {
        // Zaten API null döndü, sil
        final ref = realtimeDB.ref("favorites/$uid/$id");
        await ref.remove();
      }
    }

    return favorites;
  }

}