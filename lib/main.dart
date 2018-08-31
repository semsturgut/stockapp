import 'package:flutter/material.dart';
import 'gridCategory.dart';

void main() => runApp(StockApp());

final primaryColor = Colors.blueGrey;
final accentColor = Colors.blue;

class StockApp extends StatelessWidget {
  const StockApp();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Gumush Stock App',
      theme: ThemeData(primaryColor: primaryColor, accentColor: accentColor),
      home: const GridCategory(title: 'Choose Category'),
    );
  }
}

