import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GridCategory extends StatelessWidget {
  const GridCategory({Key key, this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
    );
  }
}
