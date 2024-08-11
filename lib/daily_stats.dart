import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DailyStats extends StatelessWidget {
  const DailyStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Daily Sale',
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {},
          child: const Text("Add Sale"),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Today Stock Purchase',
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {},
          child: const Text("Add Purchase"),
        ),
      ],
    );
  }
}
