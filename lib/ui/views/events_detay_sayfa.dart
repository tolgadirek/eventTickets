import 'dart:async';
import 'package:event_tickets/l10n/app_localizations.dart';
import 'package:event_tickets/ui/cubits/event_detay_cubit.dart';
import 'package:event_tickets/ui/cubits/locaiton_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class EventsDetaySayfa extends StatefulWidget {
  final String eventId;

  const EventsDetaySayfa({super.key, required this.eventId});

  @override
  State<EventsDetaySayfa> createState() => _EventsDetaySayfaState();
}

class _EventsDetaySayfaState extends State<EventsDetaySayfa> {

  Future<void> _biletSayfasiniAc(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication); //manifestin içine query içine intent ekleyince açtı.
    } else {
      throw 'URL açılamadı: $url';
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<EventDetayCubit>().getEventDetail(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context);
    final userLocation = context.watch<LocationCubit>().state;
    return Scaffold(
      appBar: AppBar(
        title: Text(lang!.events, style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<EventDetayCubit, EventDetayState>(
        builder: (context, state){
          if(state is EventDetayLoading){
            return Center(child: CircularProgressIndicator(),);
          } else if(state is EventDetayError) {
            return Center(child: Text(state.message),);
          } else if (state is EventDetayLoaded) {
            var event = state.event;
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(15.r),
                child: Column(
                  children: [
                    Image.network(
                      event.imageUrl ?? "",
                      height: 200.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 10.h,),
                    Text(event.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.sp),),
                    SizedBox(height: 10.h,),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.description ?? lang.there_is_no_description_about_the_event, style: TextStyle(fontSize: 16.sp),),
                          SizedBox(height: 10.h,),
                          bilgiSatiri(lang.organizer, event.organizer),
                          bilgiSatiri(lang.event_date, event.date),
                          bilgiSatiri(lang.start_time, event.time),
                          bilgiSatiri(lang.venue, event.venue),
                          bilgiSatiri(lang.city, event.city),
                          bilgiSatiri(lang.country, event.country),
                          bilgiSatiri(lang.ticket_sales_start_date, event.salesStart?.split("T")[0]),
                          bilgiSatiri(lang.ticket_sales_end_date, event.salesEnd?.split("T")[0]),
                          bilgiSatiri(lang.ticket_info, event.ticketLimitInfo ?? lang.no_information),
                          bilgiSatiri(lang.category, event.segment),
                          bilgiSatiri(lang.type, event.genre),

                          if (event.ticketUrl != null)
                            TextButton.icon(
                              onPressed: () async {
                                try {
                                  await _biletSayfasiniAc(event.ticketUrl!);
                                } catch (e) {
                                  print("Hata $e");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(lang.the_ticket_page_could_not_be_opened_)),
                                  );
                                }
                              },
                              icon: const Icon(Icons.open_in_new),
                              label: Text(lang.go_to_the_ticket_page),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h,),
                    if (event.latitude != null && event.longitude != null)
                      SizedBox(
                        height: 250.h,
                        width: double.infinity,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(event.latitude!, event.longitude!),
                            zoom: 14,
                          ),
                          mapType: MapType.normal,
                          markers: {
                            Marker(
                              markerId: MarkerId("eventLocation"),
                              position: LatLng(event.latitude!, event.longitude!),
                              infoWindow: InfoWindow(title: event.venue),
                            ),
                            if (userLocation != null)
                              Marker(
                                markerId: MarkerId("user"),
                                position: LatLng(userLocation.latitude, userLocation.longitude),
                                infoWindow: InfoWindow(title: lang.you_are_here),
                                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                              ),
                          },
                        ),
                      )
                    else
                      Text(lang.location_information_is_not_available_),
                  ],
                ),
              ),
            );
          } else {
            return Center(child: Text(lang.failed_to_load_data),);
          }
        },

      ),
    );
  }
}

Widget bilgiSatiri(String etiket, String? deger) {
  return Column(
    children: [
      RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.black, fontSize: 16.sp),
          children: [
            TextSpan(text: '$etiket: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: deger ?? ""),
          ],
        ),
      ),
      SizedBox(height: 10.h,),
    ],
  );
}
