import 'package:flutter_weather/models/open_weather_model.dart';
import 'package:flutter_weather/repositories/open_weather_repository.dart';
import 'package:flutter_weather/services/location_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/subjects.dart';

class Coordinate {
  final double latitude;
  final double longitude;

  Coordinate(this.latitude, this.longitude);
}

class WeatherBloc {
  final _repo = OpenWeatherRepository();
  final _locationService = LocationService();

  final _weatherStream = BehaviorSubject<OpenWeatherModel>();
  final _cityStream = BehaviorSubject<String>();
  final _loadingStream = BehaviorSubject<bool>.seeded(false);

  Stream<OpenWeatherModel> get weather => _weatherStream.stream;
  Stream<String> get city => _cityStream.stream;
  Stream<bool> get loading => _loadingStream.stream;

  Coordinate? _coordinate;
  String? _address;

  void refresh() {
    if (_address == null && _coordinate == null) {
      return;
    }

    if (_address != null) {
      getWeatherFromAddress(_address!);
    }
    if (_coordinate != null) {
      getWeatherFromCoord();
    }
  }

  Future<void> getWeatherFromCoord() async {
    _loadingStream.sink.add(true);

    final pos = await _locationService.getLocation();
    if (pos == null) {
      _weatherStream.sink.addError(const LocationServiceDisabledException());
      _loadingStream.sink.add(false);
      return;
    }

    try {
      final res = await _repo.getWeather(pos.longitude, pos.latitude);
      _getCity(pos.latitude, pos.longitude);
      _weatherStream.sink.add(res);
      _address = null;
      _coordinate = Coordinate(pos.latitude, pos.longitude);
    } catch (e) {
      _weatherStream.sink.addError(e);
    } finally {
      _loadingStream.sink.add(false);
    }
  }

  Future<void> getWeatherFromAddress(String address) async {
    _loadingStream.sink.add(true);
    try {
      List<Location> locations = await locationFromAddress(address);
      final res =
          await _repo.getWeather(locations[0].longitude, locations[0].latitude);
      _getCity(locations[0].latitude, locations[0].longitude);
      _weatherStream.sink.add(res);
      _coordinate = null;
      _address = address;
    } catch (e) {
      _weatherStream.sink.addError(e);
    } finally {
      _loadingStream.sink.add(false);
    }
  }

  Future<void> _getCity(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      _cityStream.sink.add(placemarks[0].locality ?? 'NaN');
    } catch (e) {
      _weatherStream.sink.addError(e);
    }
  }

  void dispose() {
    _weatherStream.close();
    _cityStream.close();
    _loadingStream.close();
  }
}
