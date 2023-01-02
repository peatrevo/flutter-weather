abstract class Constants {
  static const String openweatherBaseUrl = String.fromEnvironment(
    'OPENWEATHER_BASE_URL',
    defaultValue: 'api.openweathermap.org',
  );

  static const String openweatherApiKey = String.fromEnvironment(
    'OPENWEATHER_API_KEY',
    defaultValue: '',
  );
}
