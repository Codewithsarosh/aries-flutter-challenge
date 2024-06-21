import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_challenge/models/contract.dart';

class Calculator extends StatefulWidget {
  final List<Contract> optionsData;

  const Calculator({super.key, required this.optionsData});

  @override
  CalculatorState createState() => CalculatorState();
}

class CalculatorState extends State<Calculator> {
  List<double> prices = [];
  List<double> profits = [];
  double? profit, loss;
  List<Contract> selected = [];
  List<Contract> notSelected = [];
  List<double> breakEvenPoints = [];

  @override
  void initState() {
    super.initState();
    selected = widget.optionsData;
    calculatePayOff();
  }

  void calculatePayOff() {
    const minPrice = 0.0;
    final maxPrice = selected.map((opt) => opt.strikePrice).reduce(max) * 1.5;
    final tempPrices = [minPrice, maxPrice];
    final tempProfits = <double>[];

    for (final option in selected) {
      tempPrices.add(option.strikePrice);
      if (option.type == "Call") {
        tempPrices.add(option.strikePrice + (option.bid + option.ask) / 2);
      } else {
        tempPrices.add(option.strikePrice - (option.bid + option.ask) / 2);
      }
    }

    tempPrices.sort();

    for (final price in tempPrices) {
      tempProfits.add(payOff(price, selected));
    }

    breakEvenPoints.clear();
    for (int i = 0; i < tempPrices.length - 1; i++) {
      if ((tempProfits[i] < -0.001 && tempProfits[i + 1] > 0.001) ||
          (tempProfits[i] > 0.001 && tempProfits[i + 1] < -0.001)) {
        final x = axis(tempPrices[i], tempProfits[i], tempPrices[i + 1],
            tempProfits[i + 1]);
        tempPrices.insert(i + 1, x);
        tempProfits.insert(i + 1, 0.0);
        breakEvenPoints.add(x);
        i++;
      }
    }

    setState(() {
      prices = tempPrices;
      profits = tempProfits;
      profit = profits.reduce(max);
      loss = profits.reduce(min);
    });
  }

  double payOff(double price, List<Contract> selectedOptions) {
    return selectedOptions.fold<double>(0.0, (acc, option) {
      double cost = (option.bid + option.ask) / 2;

      if (option.type == "Call") {
        if (option.longShort == "long") {
          return acc + max(0, price - option.strikePrice) - cost;
        } else {
          return acc + cost - max(0, price - option.strikePrice);
        }
      } else if (option.type == "Put") {
        if (option.longShort == "long") {
          return acc + max(0, option.strikePrice - price) - cost;
        } else {
          return acc + cost - max(0, option.strikePrice - price);
        }
      }
      return acc;
    });
  }

  double axis(double x1, double y1, double x2, double y2) {
    final m = (y2 - y1) / (x2 - x1);
    final c = y1 - m * x1;
    return -c / m;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profit Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (selected.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Contracts:(Tap to remove)",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Wrap(
                children: selected.map((item) {
                  return InkWell(
                    onTap: () {
                      if (selected.length == 1) {
                        return;
                      }
                      if (selected.contains(item)) {
                        selected.remove(item);
                        notSelected.add(item);
                      } else {
                        selected.add(item);
                        notSelected.remove(item);
                      }
                      calculatePayOff();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      margin: const EdgeInsets.all(5),
                      child: Text(
                          '${item.longShort} ${item.type} - ${item.strikePrice}'),
                    ),
                  );
                }).toList(),
              ),
            ],
            Expanded(
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: prices
                          .asMap()
                          .map((i, price) =>
                              MapEntry(i, FlSpot(price, profits[i])))
                          .values
                          .toList(),
                      isCurved: true,
                      barWidth: 2,
                      color: Colors.green,
                    ),
                  ],
                ),
                curve: Curves.bounceIn,
              ),
            ),
            if (profit != null &&
                loss != null &&
                breakEvenPoints.isNotEmpty) ...[
              Text('Max Profit: ${profit!.toStringAsFixed(2)}'),
              Text('Max Loss: ${loss!.toStringAsFixed(2)}'),
              Text('Break Even Points: ${breakEvenPoints.join(', ')}'),
            ],
            if (notSelected.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Contracts:(Tap to Add)",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Wrap(
                children: notSelected.map((item) {
                  return InkWell(
                    onTap: () {
                      if (selected.contains(item)) {
                        selected.remove(item);
                        notSelected.add(item);
                      } else {
                        selected.add(item);
                        notSelected.remove(item);
                      }
                      calculatePayOff();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      margin: const EdgeInsets.all(5),
                      child: Text(
                          '${item.longShort} ${item.type} - ${item.strikePrice}'),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
