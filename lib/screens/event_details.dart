import 'package:drivers/style/barvy.dart';
import 'package:flutter/material.dart';

class EventDetails extends StatefulWidget {
  final String title;
  final String location;
  final String date;
  final String type;

  EventDetails({
    Key? key,
    required this.title,
    required this.location,
    required this.date,
    required this.type,
  }) : super(key: key);

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Handle back navigation
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Home',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              widget.title,
              style: TextStyle( 
                color: colorScheme.primary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(2), // Titles
                  1: FlexColumnWidth(3), // Info
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  _buildTableRow('Místo konání:', widget.location),
                  _buildTableRow('Datum:', widget.date),
                  _buildTableRow('Typ akce:', widget.type),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String title, String info) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              info,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
