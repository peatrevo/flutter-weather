import 'package:json_annotation/json_annotation.dart';

part 'open_weather_model.g.dart';

@JsonSerializable()
class OpenWeatherModel {
  final String? base;
  final int? visibility;
  final int? timezone;
  final List<Weather>? weather;
  final WeatherMain? main;
  final Wind? wind;
  final Rain? rain;

  OpenWeatherModel(
      {this.base,
      this.visibility,
      this.timezone,
      this.weather,
      this.main,
      this.wind,
      this.rain});

  factory OpenWeatherModel.fromJson(Map<String, dynamic> json) =>
      _$OpenWeatherModelFromJson(json);
  Map<String, dynamic> toJson() => _$OpenWeatherModelToJson(this);
}

@JsonSerializable()
class Weather {
  final int? id;
  final String? main;
  final String? description;
  final String? icon;

  Weather({this.id, this.main, this.description, this.icon});

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);
  Map<String, dynamic> toJson() => _$WeatherToJson(this);
}

@JsonSerializable()
class WeatherMain {
  final double? temp;
  @JsonKey(name: "feels_like")
  final double? feelsLike;
  @JsonKey(name: "temp_min")
  final double? tempMin;
  @JsonKey(name: "temp_max")
  final double? tempMax;
  final int? pressure;
  final int? humidity;
  @JsonKey(name: "sea_level")
  final int? seaLevel;
  @JsonKey(name: "grnd_level")
  final int? groundLevel;

  WeatherMain(
      {this.temp,
      this.feelsLike,
      this.tempMin,
      this.tempMax,
      this.pressure,
      this.humidity,
      this.seaLevel,
      this.groundLevel});

  factory WeatherMain.fromJson(Map<String, dynamic> json) =>
      _$WeatherMainFromJson(json);
  Map<String, dynamic> toJson() => _$WeatherMainToJson(this);
}

@JsonSerializable()
class Wind {
  final double? speed;
  final int? deg;
  final double? gust;

  Wind({this.speed, this.deg, this.gust});

  factory Wind.fromJson(Map<String, dynamic> json) => _$WindFromJson(json);
  Map<String, dynamic> toJson() => _$WindToJson(this);
}

@JsonSerializable()
class Rain {
  @JsonKey(name: "1h")
  final double? oneHour;

  Rain({this.oneHour});

  factory Rain.fromJson(Map<String, dynamic> json) => _$RainFromJson(json);
  Map<String, dynamic> toJson() => _$RainToJson(this);
}
