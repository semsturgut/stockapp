import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

//TODO: Re-design ListView Cards to show Serial Number, Name, Piece, Type, Extras.
//TODO: Add Search with Serial Number.

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Gumush Stock App',
      theme: ThemeData(
          primaryColor: Colors.blueGrey, accentColor: Colors.blueAccent),
      home: const ListItems(title: 'List of Items'),
    );
  }
}

class ListItems extends StatelessWidget {
  const ListItems({Key key, this.title}) : super(key: key);
  final String title;

//  TODO: Check new added documentID for collapsing new data.
  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return new Container(
      child: new Card(
        child: Dismissible(
          direction: DismissDirection.endToStart,
          key: new ValueKey(document.documentID),
          onDismissed: (direction) {
            Firestore.instance.runTransaction((transaction) async {
              DocumentSnapshot freshSnap =
                  await transaction.get(document.reference);
              await transaction.delete(freshSnap.reference);
            });
          },
          background: Card(
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
          child: new ListTile(
            key: new ValueKey(document.documentID),
            leading: Icon(
              Icons.favorite,
              color: Colors.redAccent,
            ),
            title: new Text(document['serial_number_key']),
            subtitle: new Text(
              document['piece_key'].toString(),
            ),
            isThreeLine: true,
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
                MaterialPageRoute(builder: (context) => AddItems()),
              );
            },
          )
        ],
      ),
      body: new StreamBuilder(
          stream: Firestore.instance
              .collection('serial_number')
              .orderBy('piece_key', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('Loading...');
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

class AddItems extends StatefulWidget {
  @override
  AddItemsState createState() {
    return new AddItemsState();
  }
}

class AddItemsState extends State<AddItems> {
  String serialNumberBarcode = "";
  final GlobalKey<ScaffoldState> _scaffoldAddItemsKey =
      new GlobalKey<ScaffoldState>();

  final TextEditingController itemSerialNumber = new TextEditingController();
  final TextEditingController itemName = new TextEditingController();
  final TextEditingController itemPiece = new TextEditingController();
  final TextEditingController itemType = new TextEditingController();
  final TextEditingController itemExtras = new TextEditingController();

  @override
  void dispose() {
    itemSerialNumber.clearComposing();
    itemSerialNumber.clear();
    itemName.clearComposing();
    itemName.clear();
    itemPiece.clearComposing();
    itemPiece.clear();
    itemType.clearComposing();
    itemType.clear();
    itemExtras.clearComposing();
    itemExtras.clear();
    super.dispose();
  }

  @override
  initState() {
    super.initState();
  }

  _showSnackBar() {
    final snackBar = SnackBar(
      content: Icon(
        MdiIcons.checkCircleOutline,
        color: Colors.greenAccent,
      ),
    );
    _scaffoldAddItemsKey.currentState.showSnackBar(snackBar);
  }

  Future<FutureBuilder> scanBarcode() async {
    try {
      String serialNumberBarcode = await BarcodeScanner.scan();
      setState(() => this.serialNumberBarcode = serialNumberBarcode);
    } on TargetPlatform catch (e) {
      if (e.toString() == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.serialNumberBarcode =
              'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.serialNumberBarcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.serialNumberBarcode =
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.serialNumberBarcode = 'Unknown error: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var _onPressed;
    if (itemSerialNumber.text != '' &&
        itemName.text != '' &&
        itemPiece.text != '') {
      _onPressed = () {
        // TODO: Add sound for correction.
        Firestore.instance
            .collection('serial_number')
            .document(itemSerialNumber.text)
            .setData({
          'serial_number_key': itemSerialNumber.text,
          'name_key': itemName.text,
          'piece_key': int.parse(itemPiece.text),
          'type_key': itemType.text,
          'extras_key': itemExtras.text,
        });
        _showSnackBar();
        dispose();
      };
    }

    return Scaffold(
      key: _scaffoldAddItemsKey,
      appBar: AppBar(
        title: Text('Add Items'),
        actions: <Widget>[
          new IconButton(
            color: Colors.white,
            icon: Icon(
              MdiIcons.upload,
              size: 32.0,
            ),
            onPressed: _onPressed,
          )
        ],
      ),
      body: new Container(
        child: new ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20.0),
          children: <Widget>[
            new Padding(
              child: new Row(
                children: <Widget>[
                  new Flexible(
                    child: new TextField(
                      controller: itemSerialNumber,
                      enabled: true,
                      decoration: InputDecoration(
                        labelText: 'Serial Number',
                        border: OutlineInputBorder(),
                        helperText: 'Required',
                        suffixIcon: new GestureDetector(
                          onTap: () {
                            scanBarcode().whenComplete(() {
                              itemSerialNumber.text = serialNumberBarcode;
                            });
                          },
                          child: new Icon(
                            MdiIcons.barcodeScan,
                            size: 32.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              padding: const EdgeInsets.only(bottom: 10.0),
            ),
            new Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: new TextField(
                controller: itemName,
                enabled: true,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  helperText: 'Required',
                ),
              ),
            ),
            new Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: new TextField(
                controller: itemPiece,
                enabled: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Piece',
                  border: OutlineInputBorder(),
                  helperText: 'Required',
                ),
              ),
            ),
            new Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: new TextField(
                controller: itemType,
                enabled: true,
                decoration: InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                    helperText: 'Optional'),
              ),
            ),
            new Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: new TextField(
                controller: itemExtras,
                enabled: true,
                decoration: InputDecoration(
                    labelText: 'Extras',
                    border: OutlineInputBorder(),
                    helperText: 'Optional'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
