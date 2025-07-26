import 'package:event_tickets/data/entity/event_detail.dart';
import 'package:event_tickets/data/repo/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class EventDetayState {}

class EventDetayInitial extends EventDetayState {}

class EventDetayLoading extends EventDetayState {}

class EventDetayLoaded extends EventDetayState {
  final EventDetail event;
  EventDetayLoaded(this.event);
}

class EventDetayError extends EventDetayState {
  final String message;
  EventDetayError(this.message);
}

class EventDetayCubit extends Cubit<EventDetayState> {
  EventDetayCubit() : super(EventDetayInitial());

  var repo = Repository();

  Future<void> getEventDetail(String eventId) async {
    emit(EventDetayLoading());
    final event = await repo.getEventDetail(eventId);
    if (event != null) {
      emit(EventDetayLoaded(event));
    } else {
      emit(EventDetayError("Details could not be loaded."));
    }
  }
}