import 'package:flutter/material.dart';

import '../models/constants.dart';

class ModelBottomSheet extends StatefulWidget {
  var fetchWeatherData;
  ModelBottomSheet({super.key, required this.fetchWeatherData});

  @override
  State<ModelBottomSheet> createState() => _ModelBottomSheetState();
}

class _ModelBottomSheetState extends State<ModelBottomSheet> {
  Constants myConstants = Constants();

  final TextEditingController _cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: size.height * 0.2 + keyboardHeight,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListView(
        children: [
          SizedBox(
            width: 70,
            child: Divider(
              thickness: 3.5,
              indent: 100,
              endIndent: 100,
              color: myConstants.primaryColor,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            onSubmitted: (value) {
              widget.fetchWeatherData(value);
              Navigator.of(context).pop();
            },
            controller: _cityController,
            decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: myConstants.primaryColor,
                ),
                suffixIcon: GestureDetector(
                  onTap: () => _cityController.clear(),
                  child: Icon(
                    Icons.clear,
                    color: myConstants.primaryColor,
                  ),
                ),
                hintText: 'Search city e.g. Hyderabad',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: myConstants.primaryColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: myConstants.primaryColor),
                )),
          )
        ],
      ),
    );
  }
}
