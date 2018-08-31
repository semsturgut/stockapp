import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class AddItems extends StatefulWidget {
  final DocumentSnapshot document;

  const AddItems({Key key, this.document}) : super(key: key);

  @override
  AddItemsState createState() {
    return new AddItemsState(document);
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

  final DocumentSnapshot document;

  AddItemsState(this.document);

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
    try {
      itemSerialNumber.text = document['serial_number_key'];
      itemName.text = document['name_key'];
      itemPiece.text = document['piece_key'].toString();
      itemType.text = document['type_key'];
      itemExtras.text = document['extras_key'];
    } on NoSuchMethodError {} catch (e) {
      setState(() => this.serialNumberBarcode = 'Unknown error: $e');
    }
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

  Future<FutureBuilder> checkSerialNumber(String serialNumber) async {
    try {
      DocumentSnapshot result = await Firestore.instance
          .collection('serial_number')
          .document(serialNumber)
          .get();

      itemSerialNumber.text = result['serial_number_key'];
      itemName.text = result['name_key'];
      itemPiece.text = result['piece_key'].toString();
      itemType.text = result['type_key'];
      itemExtras.text = result['extras_key'];
    } on NoSuchMethodError {
      itemSerialNumber.text = serialNumber;
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
        // TODO: Add sound feedback for add/update or edited document.
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
                              checkSerialNumber(serialNumberBarcode);
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
