import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_weather/constants.dart';
import 'package:flutter_weather/models/open_weather_model.dart';
import 'package:http/http.dart' as http;

class OpenWeatherRepository {
  Future<OpenWeatherModel> getWeather(double longitude, double latitude) async {
    try {
      const apiKey = Constants.openweatherApiKey;
      Duration timeout = const Duration(seconds: 5);

      final url = Uri.https(Constants.openweatherBaseUrl, '/data/2.5/weather', {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'appid': apiKey,
        'units': 'metric'
      });
      final res = await http.get(url).timeout(timeout);
      switch (res.statusCode) {
        case 200:
          final data = OpenWeatherModel.fromJson(jsonDecode(res.body));
          return data;
        default:
          return throw Exception(res.reasonPhrase);
      }
    } on TimeoutException catch (_) {
      throw TimeoutException('TimeoutError');
    } on SocketException catch (_) {
      rethrow;
    }
  }
}
