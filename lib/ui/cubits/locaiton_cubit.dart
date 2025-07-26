import 'package:event_tickets/data/service/location_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

class LocationCubit extends Cubit<Position?> {
  final LocationService _locationService;

  LocationCubit(this._locationService) : super(null);

  Future<void> getUserLocation() async {
    final position = await _locationService.getUserLocation();
    emit(position);
  }
}