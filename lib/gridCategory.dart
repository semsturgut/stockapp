import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'main.dart';
import 'listItems.dart';

final TextEditingController itemCategory = new TextEditingController();

class GridCategory extends StatelessWidget {
  const GridCategory({Key key, this.title}) : super(key: key);
  final String title;

  _addToFireStore(String documentID) {
    Firestore.instance
        .collection('serial_number')
        .document(documentID)
        .setData({});
    itemCategory.clearComposing();
    itemCategory.clear();
  }

  _deleteItem(BuildContext context, DocumentSnapshot document) {
    Firestore.instance.runTransaction((transaction) async {
      DocumentSnapshot freshSnap = await transaction.get(document.reference);
      await transaction.delete(freshSnap.reference);
    });
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return new Container(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ListItems(title: document.documentID)),
            );
          },
          onLongPress: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  String currentDocumentID = document.documentID;
                  return AlertDialog(
                    title: new Text(
                        "Are you sure you want to delete '$currentDocumentID'?"),
                    content: new Text(
                        "This category will be deleted immediately. You can't undo this action."),
                    actions: <Widget>[
                      new FlatButton(
                        child: new Text("Yes"),
                        onPressed: () {
                          _deleteItem(context, document);
                          Navigator.of(context).pop();
                        },
                      ),
                      new FlatButton(
                        child: new Text("No"),
                        onPressed: () {},
                      )
                    ],
                  );
                });
          },
          child: new Card(
            child: GridTile(
              key: new ValueKey(document.documentID),
              child: Text(document.documentID),
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(
              MdiIcons.plus,
              size: 32.0,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: new Text("Add new category"),
                    content: new TextField(
                      controller: itemCategory,
                      enabled: true,
                      decoration: InputDecoration(
                        labelText: 'Category Name',
                        border: UnderlineInputBorder(),
                        helperText: 'Required',
                      ),
                    ),
                    actions: <Widget>[
                      new FlatButton(
                        child: new Text("Add"),
                        onPressed: () {
                          _addToFireStore(itemCategory.text);
                          Navigator.of(context).pop();
                        },
                      ),
                      new FlatButton(
                        child: new Text("Close"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                },
              );
            },
          )
        ],
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
                  crossAxisCount: 3),
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                return _buildListItem(context, snapshot.data.documents[index]);
              },
            );
          }),
    );
  }
}
