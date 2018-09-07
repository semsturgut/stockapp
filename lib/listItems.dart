import 'main.dart';
import 'addItems.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

const alertColor = Color(0xFFFF5E00);
const nameColor = Color(0xFF605A76);

class ListItems extends StatelessWidget {
  const ListItems({Key key, this.title}) : super(key: key);
  final String title;

  _deleteItem(DocumentSnapshot document) {
    Firestore.instance.runTransaction((transaction) async {
      DocumentSnapshot freshSnap = await transaction.get(document.reference);
      await transaction.delete(freshSnap.reference);
    });
  }

  Widget _buildListItem(BuildContext context, MapEntry document) {
    return new Container(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AddItems(
                      document: document.key, // Hata olabilir
                      documentID: title,
                    )),
          );
        },
        child: new Card(
          child: Dismissible(
            direction: DismissDirection.endToStart,
            key: new ValueKey(document.key),
            // hata olabilir
            onDismissed: (direction) {
              _deleteItem(document.key); // Hata olabilir
            },
            background: Card(
              margin: const EdgeInsets.all(0.0),
              color: Colors.pinkAccent,
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
              key: new ValueKey(document.key),
              // hata olabilir
              leading: (document.value.key['piece_key'] < 5
                  ? new Icon(
                      MdiIcons.alertCircleOutline,
                      color: alertColor,
                    )
                  : new Icon(
                      MdiIcons.checkCircleOutline,
                      color: Colors.greenAccent,
                    )),
              title: new Text(
                document.value.key['serial_number_key'],
                style:
                    TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
              ),
              trailing: FlatButton(
                padding: EdgeInsets.only(
                    left: 40.0, right: 0.0, bottom: 0.0, top: 0.0),
                child: (document.value.key['piece_key'] < 5
                    ? new Text(
                  document.value.key['piece_key'].toString(),
                        style: TextStyle(
                            color: alertColor,
                            fontWeight: FontWeight.w100,
                            fontSize: 32.0),
                      )
                    : new Text(
                  document.value.key['piece_key'].toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.w100, fontSize: 32.0),
                      )),
                onPressed: null,
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
                            'Type:',
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
                            document.value.key['name_key'],
                            style: TextStyle(fontWeight: FontWeight.w300),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: new Text(
                              document.value.key['type_key'] == ''
                                  ? '-'
                                  : document.value.key['type_key'],
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                              ),
                            ),
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
                    builder: (context) => AddItems(documentID: title)),
              );
            },
          )
        ],
      ),
      body: new StreamBuilder(
          stream: Firestore.instance
              .collection('serial_number')
              .document(title)
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
                itemCount: snapshot.data.data.length,
                itemBuilder: (context, index) {
                  return _buildListItem(context, snapshot.data.data[index]);
                });
          }),
    );
  }
}
