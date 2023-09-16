import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather/screens/home.dart';

import '../models/constants.dart';

class SearchScreen extends StatefulWidget {
  var fetchWeatherData;

  SearchScreen({super.key, required this.fetchWeatherData});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Constants myConstants = Constants();

  static String apiKey = '82670b3bbc9c41cebab154047230809';

  String searchLocationAPI =
      "http://api.weatherapi.com/v1/search.json?key=$apiKey&days=7&q=";

  @override
  void initState() {
    super.initState();
    // Fetch product data from Firebase
  }

  String searchText = '';
  List<dynamic> locationData = [];

  Future<void> searchLocationText(String searchText) async {
    try {
      var searchResult =
          await http.get(Uri.parse('$searchLocationAPI$searchText'));

      setState(() {
        locationData = json.decode(searchResult.body);
      });
      print('Location data: $locationData');
    } catch (e) {
      print(e);
    }
  }

  static String getShortLocationName(String s) {
    List<String> wordList = s.split(' ');

    if (wordList.isNotEmpty) {
      if (wordList.length > 1) {
        return wordList[0] + " " + wordList[1];
      } else {
        return wordList[0];
      }
    } else {
      return " ";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe4f1fe),
      appBar: AppBar(
        backgroundColor: Color(0xFFe4f1fe),
        foregroundColor: Colors.black,
        title: TextField(
          textAlignVertical: TextAlignVertical.center,
          autofocus: true,
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              searchText = value;
            });
            searchLocationText(searchText);
          },
          decoration: InputDecoration(
              hintText: 'Search city e.g. Hyderabad',
              suffixIcon: GestureDetector(
                onTap: () => _searchController.clear(),
                child: Icon(
                  Icons.clear,
                  color: myConstants.primaryColor,
                ),
              ),
              border: InputBorder.none),
          onSubmitted: (value) {
            widget.fetchWeatherData(value);
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView.builder(
        itemCount: locationData.length,
        itemBuilder: (context, index) {
          final location = locationData[index];
          return InkWell(
            child: ListTile(
              onTap: () {
                widget.fetchWeatherData(
                    '${location['name']},${location['region']}');
                Navigator.of(context).pop();
              },
              title: Text('${location['name']}, ${location['region']}'),
            ),
          );
        },
      ),
    );
  }
}
