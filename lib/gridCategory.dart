import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';

class GridCategory extends StatelessWidget {
  const GridCategory({Key key, this.title}) : super(key: key);
  final String title;

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return new Container(
        child: new Card(
          child: GridTile(
            key: new ValueKey(document.documentID),
            child: Text(document['type_key']),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: new StreamBuilder(
          stream: Firestore.instance.collection('serial_number').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(
                  child: new Icon(
                    Icons.cloud_download,
                    color: primaryColor,
                    size: 64.0,
                  ));

            return new GridView.builder(
              gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2),
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                return _buildListItem(context, snapshot.data.documents[index]);
              },
            );
          }),
    );
  }
}
