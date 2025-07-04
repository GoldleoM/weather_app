import "package:flutter/material.dart";
import 'package:weather_app/weather_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext constext) {

    return MaterialApp(
      debugShowMaterialGrid: false,
      title: 'Weather App',
        home:  WeatherScreen(),
        theme: ThemeData.dark(useMaterial3: true),
        debugShowCheckedModeBanner: false, 
        );
  }
}
