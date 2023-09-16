import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:weather/models/constants.dart';

class ForecastCard extends StatelessWidget {
  var getForecastWeather;
  final int index;
  ForecastCard(
      {super.key, required this.getForecastWeather, required this.index});

  @override
  Widget build(BuildContext context) {
    final Constants myConstants = Constants();

    return Card(
      elevation: 3.0,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  getForecastWeather(index)["forecastDate"],
                  style: const TextStyle(
                    color: Color(0xff6696f5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Row(
                      children: [
                        Text(
                          getForecastWeather(index)["minTemperature"]
                              .toString(),
                          style: TextStyle(
                            color: myConstants.greyColor,
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '°',
                          style: TextStyle(
                              color: myConstants.greyColor,
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                              fontFeatures: const [
                                FontFeature.enable('sups'),
                              ]),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          getForecastWeather(index)["maxTemperature"]
                              .toString(),
                          style: TextStyle(
                            color: myConstants.blackColor,
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '°',
                          style: TextStyle(
                              color: myConstants.blackColor,
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                              fontFeatures: const [
                                FontFeature.enable('sups'),
                              ]),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/' + getForecastWeather(index)["weatherIcon"],
                      width: 30,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      getForecastWeather(index)["weatherName"],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${getForecastWeather(index)["chanceOfRain"]}%",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Image.asset(
                      'images/lightrain.png',
                      width: 30,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
