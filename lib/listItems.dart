import 'main.dart';
import 'addItems.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

const alertColor = Color(0xFFFF5E00);
const nameColor = Color(0xFF605A76);

class ListItems extends StatelessWidget {
  const ListItems({Key key, this.title, this.categoryList}) : super(key: key);
  final String title;
  final List<String> categoryList;

  _deleteItem(DocumentSnapshot document) {
    Firestore.instance.runTransaction((transaction) async {
      DocumentSnapshot freshSnap = await transaction.get(document.reference);
      await transaction.delete(freshSnap.reference);
    });
  }

  _updateItem(DocumentSnapshot document) {
    int piece = document['piece_key'];
    if (piece != 0) {
      Firestore.instance
          .collection('gumush_db')
          .document(title)
          .collection(title)
          .document(document.documentID)
          .setData({
        'serial_number_key': document['serial_number_key'],
        'name_key': document['name_key'],
        'piece_key': piece - 1,
        'price_key': document['price_key'],
        'extras_key': document['extras_key'],
      });
    }
  }

  Text priceResult(DocumentSnapshot document) {
    if (document['price_key'] != '') {
      double result = document['price_key'] * document['piece_key'];
      return new Text("\$" + result.toString());
    } else {
      return new Text('-');
    }
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return new Container(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AddItems(
                      document: document,
                      documentID: title,
                      categoryList: categoryList,
                    )),
          );
        },
        child: new Card(
          child: Dismissible(
            direction: DismissDirection.endToStart,
            key: new ValueKey(document.documentID),
            onDismissed: (direction) {
              _deleteItem(document);
            },
            background: Card(
              margin: const EdgeInsets.all(0.0),
              color: Colors.redAccent,
              child: Center(
                child: ListTile(
                  trailing: Icon(
                    MdiIcons.delete,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // TODO: Re-design the entire ListTile, because trailing part is unstable for smaller screens.
            child: new ListTile(
              key: new ValueKey(document.documentID),
              leading: (document['piece_key'] < 5
                  ? new Text(
                document['piece_key'].toString(),
                style: TextStyle(
                    color: alertColor,
                    fontWeight: FontWeight.w300,
                    fontSize: 24.0),
              )
                  : new Text(
                document['piece_key'].toString(),
                style: TextStyle(
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.w300,
                    fontSize: 24.0),
              )),
              title: new Text(
                document['serial_number_key'],
                style:
                TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
              ),
              trailing: FlatButton(
                key: new ValueKey(document.documentID),
                padding: EdgeInsets.only(
                    left: 40.0, right: 0.0, bottom: 0.0, top: 0.0),
                child: new Icon(
                  MdiIcons.minusBoxOutline,
                  color: Colors.blueAccent,
                  size: 32.0,
                ),
                onPressed: () {
                  _updateItem(document);
                },
              ),
              subtitle: new Container(
                alignment: Alignment.centerLeft,
                child: new Row(
                  children: <Widget>[
                    new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Text(
                          'Name:',
                          style: TextStyle(
                            color: nameColor,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: new Text(
                            'T.Price:',
                            style: TextStyle(
                              color: nameColor,
                            ),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text(
                            document['name_key'],
                            style: TextStyle(fontWeight: FontWeight.w300),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: priceResult(document),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              isThreeLine: true,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(title),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(
              MdiIcons.squareEditOutline,
              size: 32.0,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AddItems(documentID: title,
                          categoryList: categoryList,
                          title: title,)),
              );
            },
          )
        ],
      ),
      body: new StreamBuilder(
          stream: Firestore.instance
              .collection('gumush_db')
              .document(title)
              .collection(title)
              .orderBy('piece_key', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(
                  child: new Icon(
                    Icons.cloud_download,
                    color: primaryColor,
                    size: 64.0,
                  ));
            return new ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return _buildListItem(
                      context, snapshot.data.documents[index]);
                });
          }),
    );
  }
}
