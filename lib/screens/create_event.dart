import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drivers/style/barvy.dart';
import 'package:flutter/material.dart';

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
    'Jízda okreskami'
  ];
  int? maxParticipants;
  String eventDescription = '';
  double? entryFee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vytvořit akci'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Název akce
              _buildTextField(
                label: 'Název akce',
                onChanged: (value) => eventName = value,
                validator: (value) =>
                    value!.isEmpty ? 'Zadejte název akce' : null,
              ),
              const SizedBox(height: 20),
              // Místo konání
              _buildTextField(
                label: 'Místo konání',
                onChanged: (value) => eventLocation = value,
                validator: (value) =>
                    value!.isEmpty ? 'Zadejte místo konání' : null,
              ),
              const SizedBox(height: 20),
              // Datum
              const SizedBox(height: 20),
// Datum a čas
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
                            ? '${eventDate!.day}.${eventDate!.month}.${eventDate!.hour}:${eventDate!.minute.toString().padLeft(2, '0')}'
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
              // Typ akce
              DropdownButtonFormField(
                decoration: _inputDecoration('Typ akce'),
                icon: Icon(Icons.arrow_drop_down, color: Colors.white,),
                dropdownColor: colorScheme.secondary,
                style: TextStyle(color: colorScheme.onPrimary),
                items: eventTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) => eventType = value!,
                validator: (value) => value == null ? 'Zvolte typ akce' : null,
              ),
              const SizedBox(height: 20),
              // Popis akce
              _buildTextField(
                label: 'Popis akce',
                maxLines: 3,
                onChanged: (value) => eventDescription = value,
              ),
              const SizedBox(height: 20),
              // Maximální počet účastníků
              _buildTextField(
                label: 'Maximální počet účastníků',
                keyboardType: TextInputType.number,
                onChanged: (value) => maxParticipants = int.tryParse(value),
              ),
              const SizedBox(height: 20),
              // Cena vstupného
              _buildTextField(
                label: 'Cena vstupného (volitelné)',
                keyboardType: TextInputType.number,
                onChanged: (value) => entryFee = double.tryParse(value),
              ),
              const SizedBox(height: 30),
              // Submit button
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      await FirebaseFirestore.instance
                          .collection('events')
                          .add({
                        'name': eventName,
                        'location': eventLocation,
                        'date': eventDate?.toIso8601String(),
                        'type': eventType,
                        'description': eventDescription,
                        'maxParticipants': maxParticipants,
                        'entryFee': entryFee,
                        'createdAt': DateTime.now().toIso8601String(),
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Akce úspěšně vytvořena!')),
                      );
                      Navigator.pop(context); // Zpět na předchozí obrazovku
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
                  minimumSize: Size(200, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Vytvořit akci',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
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
      style: TextStyle(
        color: colorScheme.onPrimary,
      ),
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
      hintStyle: TextStyle(color: colorScheme.onSecondary),
      filled: true,
      fillColor: colorScheme.secondary,
    );
  }
}
