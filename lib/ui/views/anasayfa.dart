import 'package:event_tickets/data/entity/events.dart';
import 'package:event_tickets/l10n/app_localizations.dart';
import 'package:event_tickets/ui/cubits/anasayfa_cubit.dart';
import 'package:event_tickets/ui/cubits/favorites_cubit.dart';
import 'package:event_tickets/ui/cubits/locaiton_cubit.dart';
import 'package:event_tickets/ui/views/filter_bottom_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class Anasayfa extends StatefulWidget {
  final String country;

  const Anasayfa({super.key, required this.country});

  @override
  State<Anasayfa> createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> {
  var tfAra = TextEditingController();
  late FocusNode searchFocusNode;

  @override
  void initState() {
    super.initState();
    context.read<AnasayfaCubit>().loadEvents(widget.country);
    context.read<FavoritesCubit>().loadFavorites();
    context.read<LocationCubit>().getUserLocation();
    searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    tfAra.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context);
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        appBar: AppBar(
          title: Text(lang!.events, style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        // Ekranı kaplayan menü (Drawer)
        drawer: Drawer(
          child: Container(
            color: Colors.blueAccent, // Menü arka plan rengi
            padding: EdgeInsets.all(20.r),
            child: Column(
              children: [
                // Menü Başlık
                Text(
                  lang.menu,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.h),
                // Menü Öğeleri
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.white),
                  title: Text(lang.home_page, style: TextStyle(color: Colors.white)),
                  onTap: () {
                    // Ana sayfaya gitme işlemi
                    Navigator.pop(context); // Drawer'ı kapat
                    context.go('/home'); // GoRouter ile yönlendir
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.white),
                  title: Text(lang.my_account, style: TextStyle(color: Colors.white)),
                  onTap: () {
                    // Ayarlara gitme işlemi
                    Navigator.pop(context);
                    context.push('/myAccount');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.white),
                  title: Text(lang.my_favorites, style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/favorites');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: Colors.white),
                  title: Text(lang.log_out, style: TextStyle(color: Colors.white)),
                  onTap: () {
                    // Firebase'den çıkış yap
                    FirebaseAuth.instance.signOut().then((_) {
                      // Çıkış yaptıktan sonra KullaniciGiris sayfasına yönlendir
                      context.go('/login');
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(10.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: tfAra,
                focusNode: searchFocusNode,
                onChanged: (value) {
                  context.read<AnasayfaCubit>().search(value);
                },
                decoration: InputDecoration(
                  hintText: lang.search,
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),),
              ),
              SizedBox(height: 10.h,),
              ElevatedButton.icon(onPressed: () {
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))
                    ),
                    builder: (context) => FilterBottomSheet(),
                );
              },
                  icon: Icon(Icons.filter_alt),
                  label: Text(lang.filter)
              ),
              Expanded(
                child: BlocBuilder<AnasayfaCubit, EventState>(
                    builder: (context, state) {
                      if(state is EventLoading){
                        return Center(child: CircularProgressIndicator(),);
                      } else if (state is EventError) {
                        return Center(child: Text(state.message),);
                      } else if (state is EventLoaded) {
                        final List<Events> events = state.events;
                        return ListView.builder(
                          itemCount: events.length,
                          itemBuilder: (context, index){
                            var event = events[index];
                            return GestureDetector(
                              onTap: (){
                                context.push('/event-detail/${event.id}');
                              },
                              child: Card(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.r),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Image.network(
                                            event.imageUrl ?? "",
                                            width: 100.w,
                                            height: 100.h,
                                            fit: BoxFit.cover,
                                          ),
                                          SizedBox(width: 8.w,),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  event.name,
                                                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                                                  softWrap: true,
                                                  overflow: TextOverflow.visible,
                                                ),
                                                SizedBox(height: 10.h,),
                                                if (event.organizer != null)
                                                  Text('👤 ${lang.organizer}: ${event.organizer}'),
                                                Text('📅 ${event.date ?? lang.no_date_info} ${event.time ?? ''}'),
                                                Text('📍 ${event.city ?? ''} - ${event.venueName ?? ''}'),
                                                Text('🎭 ${event.segment ?? ''}${event.genre != null ? ' - ${event.genre}' : ''}'),
                                                SizedBox(height: 10.h,),
                                              ],
                                            ),
                                          ),
                                          // Favorileme Kısmı
                                          BlocBuilder<FavoritesCubit, List<Events>>(
                                            builder: (context, favorites) {
                                              final isFav = favorites.any((fav) => fav.id == event.id);
                                              return IconButton(
                                                onPressed: () {
                                                  context.read<FavoritesCubit>().toggleFavorite(event.id);
                                                },
                                                icon: Icon(
                                                  isFav ? Icons.favorite : Icons.favorite_border,
                                                  color: isFav ? Colors.red : Colors.grey,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return Center(child: Text(lang.failed_to_load_data),);
                      }
                    }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
