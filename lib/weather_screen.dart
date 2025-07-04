import 'dart:convert';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'additional_info.dart';
import 'forecast_item.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final tc = TextEditingController();
  bool search = false;
  late Future<Map<String,dynamic>>  weather;
  
  Future<Map<String,dynamic>> _getWeather(String cityName) async{
try{
  final res = await http.get(
    Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey'),
    );
   final data = jsonDecode(res.body);

   if(data['cod']!='200'){
    throw 'An unexpected error occured';
   }
   return data;
}catch(e){
  throw e.toString(); 
}
  }
  @override
  void initState() {
    super.initState();
    weather = _getWeather('Jaipur');
  }
  @override
void dispose(){
  super.dispose();
  tc.dispose();
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.3,
        title: const Text(
          "Weather App",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                search = true;
              });
            },
            icon: const Icon(Icons.search),
            tooltip: "Search",
          ),
          IconButton(
            onPressed: () => setState(() {
              weather = _getWeather('Jaipur');
            }),
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
          ),

        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context,snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if(snapshot.hasError){
            return Center(child: Text(snapshot.error.toString()));
          }
          final data = snapshot.data!;
          final currTemp = (data['list'][0]['main']['temp'] - 273.15).toStringAsFixed(2);
          final cityName = data['city']['name'].toString();
          final currIcon = data['list'][0]['weather'][0]['main'];
          final humid = data['list'][0]['main']['humidity'].toString();
          final wind = data['list'][0]['wind']['speed'].toString();
          final pressure = data['list'][0]['main']['pressure'].toString();

          return SingleChildScrollView(
            child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                search ? Search(controller: tc, 
                onSubmitted: (cityName){
                  setState(() {
                    search = false;
                    weather = _getWeather(cityName);
                  });
                }
                )
                : Center(child: Text(cityName,
                style: TextStyle(fontSize: 22,
                fontWeight: FontWeight.bold,
                ),
                ),
                ),
                const SizedBox(height: 8,),
                //main card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 10,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            spacing: 18,
                            children: [ 
                              Text(
                                "$currTemp °C",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                              currIcon == 'Clouds' ? Icons.cloud : currIcon == 'Rain' ? (Icons.cloudy_snowing): Icons.sunny,
                              size: 64,
                              ),
                              Text(
                                currIcon,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                //forecast cards
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Weather Forecast",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 10,
                    itemBuilder: (context,index){
                      final hourlyForecast = data['list'][index+1];
                      final hourlyIcon = data['list'][index+1]['weather'][0]['main'];
                      final hourlyTemp = (hourlyForecast['main']['temp'] - 273.15).toStringAsFixed(2);
                      final time = DateTime.parse(hourlyForecast['dt_txt']);

                      return ForecastItem(
                      time: DateFormat.j().format(time),
                       temp: "$hourlyTemp °C",
                       icon: hourlyIcon == 'Clouds' ? Icons.cloud : hourlyIcon == 'Rain' ? (Icons.cloudy_snowing): Icons.sunny,
                       );

                    }
                    ),
                ),
                //additional info
                const SizedBox(height: 20),
                const Text(
                  "Additional Information",
                  style: TextStyle(fontWeight: FontWeight.bold, 
                  fontSize: 20),
                ),            
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                  AdditionalInfo(icon: Icons.water_drop,
                  property: "Humidity",
                  value: humid,
                  ),
                  AdditionalInfo(
                    icon: Icons.air,
                    property: "Wind Speed",
                    value: wind,
                  ),
                  AdditionalInfo(icon: Icons.beach_access,
                  property: "Pressure",
                  value: pressure,
                  ),
                ],
                ),
              ],
            ),
                    ),
          );
        },
      ),
    );
  }
}

class City extends StatelessWidget {
  const City({
    super.key,
    required this.cityName,
  });

  final String cityName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
    alignment: Alignment.center,
    child: Text(cityName,
    style: const TextStyle(fontWeight: FontWeight.bold,
    fontSize: 20),
      ),
    );
  }
}

class Search extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;

  const Search({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue.shade400,
          width: 3,
          )
        ),
        hintText: "Enter Location",
        hintStyle: const TextStyle(color: Colors.black),
        prefixIcon: const Icon(Icons.search),
        prefixIconColor: Colors.black,
        filled: true,
        fillColor: Colors.white,
      ),
      onSubmitted: onSubmitted,
    );
  }
}
