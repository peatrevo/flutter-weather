import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_weather/blocs/weather_bloc.dart';
import 'package:flutter_weather/models/open_weather_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _weatherBloc = WeatherBloc();

  final _locationSearchController = TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();

    _weatherBloc.getWeatherFromCoord();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _weatherBloc.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _weatherBloc.getWeatherFromCoord();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        _weatherBloc.refresh();
        return Future<void>.delayed(Duration.zero);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(top: 15, child: _searchBox()),
                  Center(
                      child: StreamBuilder(
                    stream: _weatherBloc.loading,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!) {
                          return const CircularProgressIndicator();
                        }
                        return _loadingFinishedUi();
                      }
                      return Container();
                    },
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loadingFinishedUi() {
    return StreamBuilder(
      stream: _weatherBloc.weather,
      builder: (context, snapshot) {
        if (snapshot.hasData) return _loadedBody(snapshot.data!);
        if (snapshot.hasError) return _getError(snapshot.error);
        return const CircularProgressIndicator();
      },
    );
  }

  Widget _searchBox() {
    return Row(
      children: [
        const SizedBox(width: 15),
        Container(
          height: 50,
          width: MediaQuery.of(context).size.width - 50,
          padding: const EdgeInsets.symmetric(horizontal: 25),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: Offset(0, 0))
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _locationSearchController,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
              IconButton(
                icon: const Icon(FontAwesomeIcons.magnifyingGlass),
                onPressed: () {
                  _weatherBloc
                      .getWeatherFromAddress(_locationSearchController.text);
                  _locationSearchController.text = "";
                },
              )
            ],
          ),
        ),
        IconButton(
            onPressed: _weatherBloc.getWeatherFromCoord,
            icon: const Icon(Icons.location_on_outlined))
      ],
    );
  }

  Widget _getError(Object? error) {
    if (error == null) {
      return _errorBody("Something went wrong");
    }
    if (error is TimeoutException) {
      return _errorBody("Connection time out error");
    }
    if (error is SocketException) {
      return _errorBody("Check your interner connection");
    }
    if (error is LocationServiceDisabledException) {
      return _errorBody("Location is disabled, please enable it.");
    }
    if (error is Exception) {
      return _errorBody("Error connecting to the API");
    }
    return _errorBody("Something went wrong");
  }

  Widget _errorBody(String text) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text),
        TextButton(
            onPressed: _weatherBloc.refresh, child: const Text("Refresh"))
      ],
    );
  }

  Widget _loadedBody(OpenWeatherModel data) {
    return Column(
      children: [
        const SizedBox(height: 80),
        StreamBuilder(
            stream: _weatherBloc.city,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();

              return Text(
                snapshot.data!,
                style: const TextStyle(fontSize: 36, color: Colors.white),
              );
            }),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.main?.temp?.toStringAsFixed(0) ?? 'NaN',
              style: const TextStyle(fontSize: 140, color: Colors.white),
            ),
            const Text(
              "°",
              style: TextStyle(fontSize: 60, color: Colors.white),
            )
          ],
        ),
        const Spacer(),
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height / 4,
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          child: _bottomContainer(data.main?.humidity ?? 0,
              data.rain?.oneHour ?? 0, data.wind?.speed ?? 0),
        )
      ],
    );
  }

  Widget _bottomContainer(int humidity, double rain, double wind) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _infoItem(FontAwesomeIcons.droplet, "$humidity %", "humidity"),
        _infoItem(FontAwesomeIcons.cloudRain, "$rain mm", "last 1 hour"),
        _infoItem(FontAwesomeIcons.wind, "$wind km/h", "wind"),
      ],
    );
  }

  Widget _infoItem(IconData icon, String value, String title) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon),
        const SizedBox(height: 10),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(title)
      ],
    );
  }
}
