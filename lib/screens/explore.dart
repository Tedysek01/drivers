import 'package:drivers/style/barvy.dart';
import 'package:flutter/material.dart';

class Explore extends StatelessWidget {
  const Explore
      ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Map')),
      body: Column(
        children: [
          Row(
            children: [
              Container(
                decoration:
                BoxDecoration(
                  color: colorScheme.primary
                ),
                child: Text('Ahoj'),
              ),
              Container(
                decoration:
                BoxDecoration(
                    color: colorScheme.secondary
                ),
              ),
            ],
          )
        ],
      ));
  }
}
