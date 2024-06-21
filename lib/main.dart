import 'package:flutter/material.dart';
import 'package:flutter_challenge/models/contract.dart';
import 'package:flutter_challenge/calculator/calculator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Options Profit Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Calculator(
        optionsData: [
          {
            "strike_price": 100,
            "type": "Call",
            "bid": 10.05,
            "ask": 12.04,
            "long_short": "long",
            "expiration_date": "2025-12-17T00:00:00Z"
          },
          {
            "strike_price": 102.50,
            "type": "Call",
            "bid": 12.10,
            "ask": 14,
            "long_short": "long",
            "expiration_date": "2025-12-17T00:00:00Z"
          },
          {
            "strike_price": 103,
            "type": "Put",
            "bid": 14,
            "ask": 15.50,
            "long_short": "short",
            "expiration_date": "2025-12-17T00:00:00Z"
          },
          {
            "strike_price": 105,
            "type": "Put",
            "bid": 16,
            "ask": 18,
            "long_short": "long",
            "expiration_date": "2025-12-17T00:00:00Z"
          }
        ].map(Contract.fromJson).toList(),
      ),
    );
  }
}
