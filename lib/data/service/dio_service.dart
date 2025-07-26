import 'package:dio/dio.dart';

class DioService {
  static const String _apiKey = 'YOUR_API_KEY';

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://app.ticketmaster.com/discovery/v2',
      headers: {
        'Content-Type': 'application/json',
      },
      queryParameters: {
        'apikey': _apiKey,
      },
    ),
  );
}
