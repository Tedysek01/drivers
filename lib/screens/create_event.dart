import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drivers/style/barvy.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  String eventName = '';
  String eventLocation = '';
  DateTime? eventDate;
  String eventType = '';
  final List<String> eventTypes = [
    'Sraz',
    'Závody',
    'Drifty',
    'Okresky'
  ];
  String eventDescription = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Vytvořit akci'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Event Name
              _buildTextField(
                label: 'Název akce',
                onChanged: (value) => eventName = value,
                validator: (value) =>
                    value!.isEmpty ? 'Zadejte název akce' : null,
              ),
              const SizedBox(height: 20),

              // Event Location
              _buildTextField(
                label: 'Místo konání',
                onChanged: (value) => eventLocation = value,
                validator: (value) =>
                    value!.isEmpty ? 'Zadejte místo konání' : null,
              ),
              const SizedBox(height: 20),

              // Date and Time Picker
GestureDetector(
  onTap: () async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          eventDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  },
  child: Container(
    decoration: BoxDecoration(
      color: colorScheme.secondary,
      borderRadius: BorderRadius.circular(10),
    ),
    padding: const EdgeInsets.all(15),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          eventDate != null
              ? DateFormat('dd.MM.yyyy HH:mm').format(eventDate!)
              : 'Zvolte datum a čas',
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontSize: 16,
          ),
        ),
        const Icon(
          Icons.calendar_today,
          color: Colors.white,
        ),
      ],
    ),
  ),
),

              const SizedBox(height: 20),

              // Event Type Dropdown
              DropdownButtonFormField(
                decoration: _inputDecoration('Typ akce'),
                dropdownColor: colorScheme.secondary,
                items: eventTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type,
                              style: TextStyle(color: colorScheme.onPrimary)),
                        ))
                    .toList(),
                onChanged: (value) => eventType = value!,
                validator: (value) => value == null ? 'Zvolte typ akce' : null,
              ),
              const SizedBox(height: 20),

              // Event Description
              _buildTextField(
                label: 'Popis akce',
                maxLines: 3,
                onChanged: (value) => eventDescription = value,
                validator: (value) => value!.isEmpty ? 'Popis je povinný' : null,
              ),
              const SizedBox(height: 30),

              // Submit Button
              ElevatedButton(
  onPressed: () async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('events').add({
          'name': eventName,
          'location': eventLocation,
          'date': eventDate != null ? DateFormat('dd.MM.yyyy HH:mm').format(eventDate!) : null, // Save formatted date
          'type': eventType,
          'description': eventDescription,
          'createdAt': DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now()), // Optional: Format createdAt as well
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akce úspěšně vytvořena!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chyba při vytváření akce: $e')),
        );
      }
    }
  },
  style: ElevatedButton.styleFrom(
    foregroundColor: colorScheme.onPrimary,
    backgroundColor: colorScheme.primary,
    minimumSize: const Size(200, 50),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  child: const Text('Vytvořit akci', style: TextStyle(fontSize: 18)),
),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    required ValueChanged<String> onChanged,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      decoration: _inputDecoration(label),
      style: TextStyle(color: colorScheme.onPrimary),
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: colorScheme.onSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      filled: true,
      fillColor: colorScheme.secondary,
    );
  }
}
