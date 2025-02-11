import 'package:flutter/material.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';

import 'barvy.dart';

const String kGoogleApiKey = "AIzaSyCk9B0oOilVXflt7ZyI2iOAW-dgWsdG0rY";

class AutoCompleteCityField extends StatefulWidget {
  final TextEditingController controller;

  const AutoCompleteCityField({Key? key, required this.controller}) : super(key: key);

  @override
  _AutoCompleteCityFieldState createState() => _AutoCompleteCityFieldState();
}

class _AutoCompleteCityFieldState extends State<AutoCompleteCityField> {
  @override
  Widget build(BuildContext context) {
    return GooglePlacesAutoCompleteTextFormField(
      textEditingController: widget.controller,
      googleAPIKey: kGoogleApiKey,
      debounceTime: 400, // Zpoždění před odesláním dotazu (lepší UX)
      countries: ["cz"], // Pouze Česko 🇨🇿
      decoration: InputDecoration(
        labelText: "Město",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: colorScheme.secondary,

      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },


      maxLines: 1,
      overlayContainerBuilder: (child) => Material(
        elevation: 1.0,
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),


      onSuggestionClicked: (suggestion) {
        setState(() {
          widget.controller.text = suggestion.description ?? "";
        });
        print("Vybrané město: ${widget.controller.text}"); // Debug výpis
      },
    );
  }
}

