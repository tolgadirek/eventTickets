import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyAccountCubit extends Cubit<Map<String, dynamic>?> {
  MyAccountCubit():super(null);

  Future<void> loadUserInfo() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid.toString();
      var dbRef = await FirebaseDatabase.instance.ref("users/$uid").get();

      if (dbRef.exists && dbRef.value != null) {
        final data = dbRef.value;
        if (data is Map) {
          emit(Map<String, dynamic>.from(data));
        }
      }
    } catch (e) {
      print("Kullanıcı bilgisi çekme hatası: $e");
    }
  }

  Future<void> updateUserInfo(
      {required String email, required String ad, required String soyad,
        required String dtarih, required String country}) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseDatabase.instance.ref("users/$uid").update({ // veritabanında güncelleme
        "email": email,
        "ad": ad,
        "soyad": soyad,
        "dtarih": dtarih,
        "country": country
      });
      emit({ //ui içinde güncelleme
        "email": FirebaseAuth.instance.currentUser!.email!,
        "ad": ad,
        "soyad": soyad,
        "dtarih": dtarih,
        "country": country,
      });
    } catch (e) {
      print("Güncelleme hatası: $e");
    }
  }


}