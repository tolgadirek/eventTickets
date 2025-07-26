import 'package:event_tickets/data/repo/repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class KullaniciKayitState {}

class KullaniciKayitInitial extends KullaniciKayitState {}

class KullaniciKayitLoading extends KullaniciKayitState {}

class KullaniciKayitSuccess extends KullaniciKayitState {
  User user;
  KullaniciKayitSuccess(this.user);
}

class KullaniciKayitFailure extends KullaniciKayitState {
  String error;
  KullaniciKayitFailure(this.error);
}

class KullaniciKayitCubit extends Cubit<KullaniciKayitState> {
  KullaniciKayitCubit():super(KullaniciKayitInitial());

  var repo = Repository();

  void kayitOl(String email, String password, String ad, String soyad, String dtarih, String country) async {
    emit(KullaniciKayitLoading()); // Yüklenme durumunu göster
    User? user = await repo.kayitOl(email, password, ad, soyad, dtarih, country); // Kaydetme fonksiyonu

    if (user != null) {
      emit(KullaniciKayitSuccess(user)); // Kayıt başarılı
    } else {
      emit(KullaniciKayitFailure("Registration failed! Please check your information.")); // Kayıt başarısız
    }
  }
}