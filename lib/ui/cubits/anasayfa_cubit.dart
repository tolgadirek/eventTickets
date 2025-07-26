import 'package:event_tickets/data/entity/events.dart';
import 'package:event_tickets/data/repo/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class EventState {}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

class EventLoaded extends EventState {
  final List<Events > events;

  EventLoaded(this.events);
}

class EventError extends EventState {
  final String message;

  EventError(this.message);
}

class AnasayfaCubit extends Cubit<EventState> {
  AnasayfaCubit():super(EventInitial());

  var repo = Repository();
  List<Events> allEvents = [];
  String? currentCity;
  String? currentSegment;
  DateTime? currentDate;

  Future<void> loadEvents(String country) async {
    emit(EventLoading());
    try {
      final events = await repo.loadEvents(country: country);
      allEvents = events; // Search için allevent listesi dolar.
      emit(EventLoaded(events));
    } catch (e) {
      emit(EventError('Events could not be loaded'));
    }
  }

  void search(String query) {
    final sonuc = allEvents.where((event) =>
        event.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
    if(query.isEmpty){
      emit(EventLoaded(allEvents));
    } else {
      emit(EventLoaded(sonuc));
    }
  }

  void applyFilters({String? city, String? segment, DateTime? date}) {
    currentCity = city;
    currentSegment = segment;
    currentDate = date;

    final filtered = allEvents.where((event) {
      final matchCity = city == null || event.city == city; //nullsa hepsi gelir, şehir seçiliyse ona özel gelir
      final matchSegment = segment == null || event.segment == segment;
      final matchDate = date == null || event.date == date.toIso8601String().split('T')[0];
      return matchCity && matchSegment && matchDate;
    }).toList();

    emit(EventLoaded(filtered));
  }
}