import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'main.dart';
import 'addItems.dart';
import 'listItems.dart';

final TextEditingController itemCategory = new TextEditingController();
AsyncSnapshot documentGumushdb;
List<String> categoryList = [];

class GridCategory extends StatefulWidget {
  final String title;

  const GridCategory({Key key, this.title}) : super(key: key);

  @override
  GridCategoryState createState() {
    return new GridCategoryState(title);
  }
}

class GridCategoryState extends State<GridCategory> {
  String title;

  GridCategoryState(this.title);

  _addToFireStore(String documentID) {
    Firestore.instance.collection('gumush_db').document(documentID).setData({});
  }

  _deleteItem(BuildContext context, DocumentSnapshot document) {
    Firestore.instance.runTransaction((transaction) async {
      DocumentSnapshot freshSnap = await transaction.get(document.reference);
      await transaction.delete(freshSnap.reference);
    });
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return new Container(
        padding: const EdgeInsets.all(1.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ListItems(
                        title: document.documentID,
                        categoryList: categoryList,
                      )),
            );
          },
          onLongPress: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  String currentDocumentID = document.documentID;
                  return AlertDialog(
                    title: new RichText(
                        text: new TextSpan(children: <TextSpan>[
                          new TextSpan(
                              text: 'Are you sure you want to delete ',
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 22.0)),
                          new TextSpan(
                              text: currentDocumentID,
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                  fontSize: 22.0)),
                          new TextSpan(
                              text: ' ?',
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 22.0))
                        ])),
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
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                });
          },
          child: new Opacity(
            opacity: 0.9,
            child: new Card(
              margin: const EdgeInsets.all(0.0),
              child: GridTile(
                key: new ValueKey(document.documentID),
                child: Center(
                    child: new Text(
                      document.documentID,
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.bold),
                    )),
              ),
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
                        border: OutlineInputBorder(),
                        helperText: 'Required',
                      ),
                    ),
                    actions: <Widget>[
                      new FlatButton(
                        child: new Text("Add"),
                        onPressed: () {
                          if (!categoryList.contains(itemCategory.text)) {
                            _addToFireStore(itemCategory.text);
                          }
                          itemCategory.clearComposing();
                          itemCategory.clear();
                          Navigator.of(context).pop();
                        },
                      ),
                      new FlatButton(
                        child: new Text("Close"),
                        onPressed: () {
                          itemCategory.clearComposing();
                          itemCategory.clear();
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
      body: new Container(
        decoration: new BoxDecoration(
            image: new DecorationImage(
                image: new AssetImage('icon/background.jpeg'))),
        child: new StreamBuilder(
            stream: Firestore.instance.collection('gumush_db').snapshots(),
            builder: (context, snapshot) {
              documentGumushdb = snapshot;
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
                  if (!categoryList
                      .contains(snapshot.data.documents[index].documentID)) {
                    categoryList.add(snapshot.data.documents[index].documentID);
                  }
                  return _buildListItem(
                      context, snapshot.data.documents[index]);
                },
              );
            }),
      ),
      floatingActionButton: new FloatingActionButton(
          onPressed: () {
            if (documentGumushdb.hasData) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AddItems(
                          categoryList: categoryList,
                          fromWhere: 'category',
                        )),
              );
            }
          },
          child: new Icon(MdiIcons.barcodeScan, size: 32.0),
          backgroundColor: primaryColor),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
