import 'package:event_tickets/l10n/app_localizations.dart';
import 'package:event_tickets/ui/cubits/kullanici_giris_cubit.dart';
import 'package:event_tickets/ui/cubits/locale_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class KullaniciGirisSayfa extends StatefulWidget {
  const KullaniciGirisSayfa({super.key});

  @override
  State<KullaniciGirisSayfa> createState() => _KullaniciGirisSayfaState();
}

class _KullaniciGirisSayfaState extends State<KullaniciGirisSayfa> {
  var tfEmail = TextEditingController();
  var tfParola = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        actions: [
          DropdownButton<Locale>(
            value: Localizations.localeOf(context),
            onChanged: (Locale? newLocale) {
              if (newLocale != null) {
                context.read<LocaleCubit>().changeLocale(newLocale);
              }
            },
            items: const [
              DropdownMenuItem(
                value: Locale('en'),
                child: Text("English"),
              ),
              DropdownMenuItem(
                value: Locale('tr'),
                child: Text("Türkçe"),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(), // Bu metot ile kontrol sağlıyor
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // Kullanıcı giriş yapmışsa direkt yönlendirme
              Future.delayed(Duration.zero, () {
                context.go('/home');
              });
              return const SizedBox();
            } else { //kullanıcı giriş yapmamışsa;
              return BlocConsumer<KullaniciGirisCubit, KullaniciGirisState>(
                  listener: (context, state) {
                    if (state is KullaniciGirisSuccess) {
                      context.go('/home');
                    } else if (state is KullaniciGirisFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.error)),);
                    }
                  },
                  builder: (context, state) {
                    return SingleChildScrollView(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(30.0.r),
                          child: Column(
                            children: [
                              SizedBox(height: 60.h,),
                              Text(lang!.log_in, style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 40.sp,
                                  fontWeight: FontWeight.bold),),
                              SizedBox(height: 30.h,),
                              textFieldOlustur(
                                  tfEmail, lang.enter_your_email_address),
                              SizedBox(height: 10.h,),
                              textFieldOlustur(tfParola, lang.enter_your_password, isPassword: true),
                              SizedBox(height: 30.h,),
                              Padding(
                                padding: EdgeInsets.only(
                                    right: 40.w, left: 40.w),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        String email = tfEmail.text.trim();
                                        String password = tfParola.text.trim();
                                        context.read<KullaniciGirisCubit>().girisYap(email, password);
                                      },
                                      child: state is KullaniciGirisLoading
                                          ? const CircularProgressIndicator()
                                      : Text(lang.log_in, style: TextStyle(fontSize: 20.sp),)),
                                ),
                              ),
                              SizedBox(height: 100.h,),
                              Text(lang.don_t_have_an_account_, style: TextStyle(
                                  color: Colors.black54),),
                              TextButton(onPressed: () {
                                context.push('/register');
                              }, child: Text(lang.sign_up,
                                style: TextStyle(color: Colors.black45),)
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
              );
            }
          }
      ),
    );
  }
}

Widget textFieldOlustur(TextEditingController controller, String hintText, {bool isPassword = false}) {
  return TextField(
    controller: controller,
    obscureText: isPassword,
    cursorColor: Colors.black,
    style: const TextStyle(color: Colors.black),
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.r),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
