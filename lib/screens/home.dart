import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:weather/models/constants.dart';
import 'package:weather/screens/search_screen.dart';
import 'package:weather/widgets/bottom_sheet.dart';

import 'detail_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _cityController = TextEditingController();
  static String apiKey = '82670b3bbc9c41cebab154047230809';

  Constants myConstants = Constants();

  bool _isLoading = false;
  bool fetchingSearchText = false;

  String weatherIcon = 'heavycloud.png';
  int temperature = 0;
  int windSpeed = 0;
  int humidity = 0;
  int cloud = 0;
  String currentDate = '';

  List hourlyWeatherForecast = [];
  List dailyWeatherForecast = [];

  String currentWeatherStatus = '';

  //API call
  String searchWeatherAPI =
      "http://api.weatherapi.com/v1/forecast.json?key=$apiKey&days=7&q=";

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    getUserLocation();
  }

  Future<void> requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      getUserLocation();
    } else if (status.isDenied) {
      Permission.location.request();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  double lat = 0;
  double lang = 0;

  String address = '';
  String location = '';

  Future<void> getUserLocation() async {
    _isLoading = true;
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks != null && placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];

        setState(() {
          _isLoading = false;
          address = "${position.latitude},${position.longitude}";
          location =
              "${placemark.subLocality}, ${placemark.administrativeArea}";
        });
        fetchWeatherData(address);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 5,
          content: Text(
            e.toString(),
            style: const TextStyle(color: Colors.white),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {
      lat = position.latitude;
      lang = position.longitude;
    });
  }

  Map<String, dynamic> weatherData = {};

  Future<void> fetchWeatherData(String searchText) async {
    try {
      fetchingSearchText = true;
      var searchResult =
          await http.get(Uri.parse('$searchWeatherAPI$searchText'));

      setState(() {
        weatherData = json.decode(searchResult.body);
        fetchingSearchText = false;
      });

      var locationData = weatherData['location'];
      var currentWeather = weatherData['current'];

      setState(() {
        location = getShortLocationName(locationData['name']);

        var parsedDate =
            DateTime.parse(locationData["localtime"].substring(0, 10));
        var newDate = DateFormat('MMMMEEEEd').format(parsedDate);
        currentDate = newDate;

        //update weather
        currentWeatherStatus = currentWeather['condition']['text'];
        weatherIcon =
            "${currentWeatherStatus.replaceAll(' ', '').toLowerCase()}.png";
        temperature = currentWeather["temp_c"].toInt();
        windSpeed = currentWeather["wind_kph"].toInt();
        humidity = currentWeather["humidity"].toInt();
        cloud = currentWeather["cloud"].toInt();

        //Forecast Data
        dailyWeatherForecast = weatherData['forecast']['forecastday'];
        hourlyWeatherForecast = dailyWeatherForecast[0]['hour'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 5,
          content: Text(
            weatherData['error']['message'],
            style: const TextStyle(color: Colors.white),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static String getShortLocationName(String s) {
    List<String> wordList = s.split(' ');

    if (wordList.isNotEmpty) {
      if (wordList.length > 1) {
        return "${wordList[0]} ${wordList[1]}";
      } else {
        return wordList[0];
      }
    } else {
      return " ";
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading || fetchingSearchText
          ? Container(
              color: const Color(0xFFe4f1fe),
              child: Center(
                child: Image.asset('images/loading.gif'),
              ),
            )
          : SingleChildScrollView(
              child: Container(
                width: size.width,
                height: size.height,
                padding: const EdgeInsets.only(top: 70, left: 10, right: 10),
                color: myConstants.primaryColor.withOpacity(0.1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      height: size.height * 0.7,
                      decoration: BoxDecoration(
                        gradient: myConstants.linearGradientBlue,
                        boxShadow: [
                          BoxShadow(
                            color: myConstants.primaryColor.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                'images/menu.png',
                                width: 40,
                                height: 40,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'images/pin.png',
                                    width: 20,
                                  ),
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    location,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => SearchScreen(
                                            fetchWeatherData: fetchWeatherData,
                                          ),
                                        ),
                                      );
                                      // _cityController.clear();
                                      // showModalBottomSheet(
                                      //   isScrollControlled: true,
                                      //   context: context,
                                      //   builder: (context) => ModelBottomSheet(
                                      //       fetchWeatherData: fetchWeatherData),
                                      // );
                                    },
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'images/profile.png',
                                  width: 40,
                                  height: 40,
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 160,
                            child: Image.asset('images/$weatherIcon'),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  temperature.toString(),
                                  style: TextStyle(
                                    fontSize: 80,
                                    fontWeight: FontWeight.bold,
                                    foreground: Paint()
                                      ..shader = myConstants.shader,
                                  ),
                                ),
                              ),
                              Text(
                                'o',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  foreground: Paint()
                                    ..shader = myConstants.shader,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            currentWeatherStatus,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 20),
                          ),
                          Text(
                            currentDate,
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Divider(color: Colors.white70),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                WeatherItem(
                                  value: windSpeed.toInt(),
                                  unit: 'km/h',
                                  imageUrl: 'images/windspeed.png',
                                ),
                                WeatherItem(
                                  value: humidity.toInt(),
                                  unit: '%',
                                  imageUrl: 'images/humidity.png',
                                ),
                                WeatherItem(
                                  value: cloud.toInt(),
                                  unit: '%',
                                  imageUrl: 'images/cloud.png',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      height: size.height * 0.2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Today',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: myConstants.primaryColor,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DetailPage(
                                              dailyForecastWeather:
                                                  dailyWeatherForecast,
                                            ))), //This will open forecast screen
                                child: Text(
                                  'Forecasts',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: myConstants.primaryColor,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          SizedBox(
                            height: size.height * 0.14,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: hourlyWeatherForecast.length,
                              itemBuilder: (BuildContext context, int index) {
                                String currentTime = DateFormat('HH:mm:ss')
                                    .format(DateTime.now());
                                String currentHour =
                                    currentTime.substring(0, 2);

                                String forecastTime =
                                    hourlyWeatherForecast[index]['time']
                                        .toString()
                                        .substring(11, 16);
                                String forecastHour =
                                    hourlyWeatherForecast[index]['time']
                                        .toString()
                                        .substring(11, 13);

                                String forecastWeatherName =
                                    hourlyWeatherForecast[index]['condition']
                                        ['text'];
                                String forecastweatherIcon =
                                    '${forecastWeatherName.replaceAll(' ', '').toLowerCase()}.png';

                                String forecastTemperature =
                                    hourlyWeatherForecast[index]['temp_c']
                                        .round()
                                        .toString();

                                return Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  margin: const EdgeInsets.only(right: 20),
                                  width: 65,
                                  decoration: BoxDecoration(
                                      color: currentHour == forecastHour
                                          ? Colors.white
                                          : myConstants.primaryColor,
                                      borderRadius: BorderRadius.circular(50),
                                      boxShadow: [
                                        BoxShadow(
                                          offset: const Offset(0, 1),
                                          blurRadius: 5,
                                          color: myConstants.primaryColor
                                              .withOpacity(0.2),
                                        ),
                                      ]),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        forecastTime,
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: currentHour == forecastHour
                                              ? myConstants.primaryColor
                                              : myConstants.greyColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Image.asset(
                                        'images/$forecastweatherIcon',
                                        width: 20,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            forecastTemperature,
                                            style: TextStyle(
                                              color: currentHour == forecastHour
                                                  ? myConstants.primaryColor
                                                  : myConstants.greyColor,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            '°',
                                            style: TextStyle(
                                              color: currentHour == forecastHour
                                                  ? myConstants.primaryColor
                                                  : myConstants.greyColor,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                              fontFeatures: const [
                                                FontFeature.enable('sups'),
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}

class WeatherItem extends StatelessWidget {
  final int value;

  final String unit;
  final String imageUrl;
  const WeatherItem({
    super.key,
    required this.value,
    required this.unit,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: 70,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Image.asset(imageUrl),
          const SizedBox(
            height: 8,
          ),
          Text(
            value.toString() + unit,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
