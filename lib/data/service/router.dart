import 'package:event_tickets/ui/views/anasayfa.dart';
import 'package:event_tickets/ui/views/kullanici_kayit_sayfa.dart';
import 'package:event_tickets/ui/views/events_detay_sayfa.dart';
import 'package:event_tickets/ui/views/favorites_sayfa.dart';
import 'package:event_tickets/ui/views/kullanici_giris_sayfa.dart';
import 'package:event_tickets/ui/views/my_account_sayfa.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const KullaniciGirisSayfa(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const KullaniciKayitSayfa(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        final dbRef = FirebaseDatabase.instance.ref("users/$uid/country");

        return FutureBuilder<DataSnapshot>(
          future: dbRef.get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            final countryCode = snapshot.data!.value?.toString() ?? 'TR';
            return Anasayfa(
              key: ValueKey(countryCode), // countryCode değişirse anasayfayı en baştan build eder. init çalışır yani.
              country: countryCode,
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/event-detail/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return EventsDetaySayfa(eventId: id);
      },
    ),
    GoRoute(
      path: '/myAccount',
      builder: (context, state) => const MyAccount(),
    ),
    GoRoute(
      path: '/favorites',
      builder: (context, state) => const FavoritesSayfa(),

    ),
  ],
);