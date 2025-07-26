import 'package:event_tickets/data/entity/events.dart';
import 'package:event_tickets/l10n/app_localizations.dart';
import 'package:event_tickets/ui/cubits/favorites_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class FavoritesSayfa extends StatefulWidget {
  const FavoritesSayfa({super.key});

  @override
  State<FavoritesSayfa> createState() => _FavoritesSayfaState();
}

class _FavoritesSayfaState extends State<FavoritesSayfa> {

  @override
  void initState() {
    super.initState();
    context.read<FavoritesCubit>().loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(lang!.favorites, style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<FavoritesCubit, List<Events>>(
        builder: (context, favorites) {
          if (favorites.isEmpty){
            return Center(child: Text(lang.you_have_no_event_in_your_favorites_),);
          } else {
            var now = DateTime.now();

            var upcomingFavorites = favorites.where((event) {
              if(event.date == null || event.time == null) return false;
              try {
                var eventDatetime = DateTime.parse("${event.date} ${event.time}");
                return eventDatetime.difference(now).inHours < 24 && eventDatetime.isAfter(now);
              } catch (e) {
                return false;
              }
            }).toList();
            
            var otherFavorites = favorites.where((e) => !upcomingFavorites.contains(e)).toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (upcomingFavorites.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.all(10.r),
                      child: Text(lang.upcoming_events, style: TextStyle(fontSize: 15.sp)),
                    ),
                    SizedBox(
                      height: 400.h, //Pageview için sabit yükseklik
                      child: PageView.builder( //Yan yana card slider için
                        itemCount: upcomingFavorites.length,
                        controller: PageController(viewportFraction: 0.85), // Ekranı genişlik olarak ne kadar kapladığı
                        itemBuilder: (context, index) {
                          final favorite = upcomingFavorites[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.w), // Diğer kartlarla olan mesafe
                            child: GestureDetector(
                              onTap: (){
                                context.push('/event-detail/${favorite.id}');
                              },
                              child: Card(
                                elevation: 4,
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(15.r),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Center(
                                            child: Image.network(
                                              favorite.imageUrl ?? "",
                                              width: double.infinity,
                                              height: 180.h,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          SizedBox(height: 10.h),
                                          Text(
                                            favorite.name,
                                            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 6.h),
                                          if (favorite.organizer != null)
                                            Text('👤 ${lang.organizer}: ${favorite.organizer}'),
                                          Text('📅 ${favorite.date ?? lang.no_date_info} ${favorite.time ?? ''}'),
                                          Text('📍 ${favorite.city ?? ''} - ${favorite.venueName ?? ''}'),
                                          Text('🎭 ${favorite.segment ?? ''}${favorite.genre != null ? ' - ${favorite.genre}' : ''}'),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      top: 8.h,
                                      right: 8.w,
                                      child: BlocBuilder<FavoritesCubit, List<Events>>(
                                        builder: (context, favorites) {
                                          final isFav = favorites.any((fav) => fav.id == favorite.id);
                                          return IconButton(
                                            onPressed: () {
                                              context.read<FavoritesCubit>().toggleFavorite(favorite.id);
                                            },
                                            icon: Icon(
                                              isFav ? Icons.favorite : Icons.favorite_border,
                                              color: isFav ? Colors.red : Colors.grey,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  if (otherFavorites.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.all(10.r),
                      child: Text(lang.other_events,
                          style: TextStyle(fontSize: 15.sp,)),
                    ),
                    ListView.builder(
                      itemCount: otherFavorites.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      // Yani bu iki satırı birden fazla liste yapıyorsak kullanırız.
                      itemBuilder: (context, index) {
                        final favorite = otherFavorites[index];
                        return GestureDetector(
                          onTap: (){
                            context.push('/event-detail/${favorite.id}');
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
                                        favorite.imageUrl ?? "",
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
                                              favorite.name,
                                              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                                              softWrap: true,
                                              overflow: TextOverflow.visible,
                                            ),
                                            SizedBox(height: 10.h,),
                                            if (favorite.organizer != null)
                                              Text('👤 ${lang.organizer}: ${favorite.organizer}'),
                                            Text('📅 ${favorite.date ?? lang.no_date_info} ${favorite.time ?? ''}'),
                                            Text('📍 ${favorite.city ?? ''} - ${favorite.venueName ?? ''}'),
                                            Text('🎭 ${favorite.segment ?? ''}${favorite.genre != null ? ' - ${favorite.genre}' : ''}'),
                                            SizedBox(height: 10.h,),
                                          ],
                                        ),
                                      ),
                                      // Favorileme Kısmı
                                      BlocBuilder<FavoritesCubit, List<Events>>(
                                        builder: (context, favorites) {
                                          final isFav = favorites.any((fav) => fav.id == favorite.id);
                                          return IconButton(
                                            onPressed: () {
                                              context.read<FavoritesCubit>().toggleFavorite(favorite.id);
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
                    ),
                  ],
                ],
              ),
            );
          }
        }
      ),
    );
  }
}
