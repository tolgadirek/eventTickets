import 'package:event_tickets/data/entity/events.dart';
import 'package:event_tickets/data/repo/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoritesCubit extends Cubit<List<Events>> {
  FavoritesCubit():super([]);

   var repo = Repository();

  /// Favori etkinlikleri yükler
  Future<void> loadFavorites() async {
    final favoriteEvents = await repo.getFavoriteEvents();
    emit(favoriteEvents);
  }

  /// Favori durumunu değiştirir ve listeyi yeniler
  Future<void> toggleFavorite(String eventId) async {
    await repo.toggleFavorite(eventId);
    await loadFavorites();
  }

  /// Belirli bir etkinlik favori mi?
  bool isFavorite(String eventId) {
    return state.any((event) => event.id == eventId);
  }
}