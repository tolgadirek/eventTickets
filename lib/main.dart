import 'package:event_tickets/data/service/location_service.dart';
import 'package:event_tickets/data/service/router.dart';
import 'package:event_tickets/l10n/app_localizations.dart';
import 'package:event_tickets/ui/cubits/anasayfa_cubit.dart';
import 'package:event_tickets/ui/cubits/event_detay_cubit.dart';
import 'package:event_tickets/ui/cubits/favorites_cubit.dart';
import 'package:event_tickets/ui/cubits/kullanici_giris_cubit.dart';
import 'package:event_tickets/ui/cubits/kullanici_kayit_cubit.dart';
import 'package:event_tickets/ui/cubits/locaiton_cubit.dart';
import 'package:event_tickets/ui/cubits/locale_cubit.dart';
import 'package:event_tickets/ui/cubits/my_account_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => KullaniciKayitCubit()),
        BlocProvider(create: (context) => KullaniciGirisCubit()),
        BlocProvider(create: (context) => AnasayfaCubit()),
        BlocProvider(create: (context) => EventDetayCubit()),
        BlocProvider(create: (context) => MyAccountCubit()),
        BlocProvider(create: (context) => FavoritesCubit()),
        BlocProvider(create: (context) => LocationCubit(LocationService())),
        BlocProvider(create: (context) => LocaleCubit()),
      ],
      child: ScreenUtilInit( // EKran dinamiği için
        designSize: Size(412, 732),
        minTextAdapt: true,
        splitScreenMode: true,
        child: BlocBuilder<LocaleCubit, Locale>( // Uygulama içi dil değişimi için cubit bağlaması
          builder: (context, locale) {
            return MaterialApp.router( // Go Router için
              routerConfig: appRouter,
              title: 'Flutter Demo',
              locale: locale,
              supportedLocales: const [
                Locale('en'),
                Locale('tr'),
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                useMaterial3: true,
              ),
            );
          },
        ),
      ),
    );
  }
}
