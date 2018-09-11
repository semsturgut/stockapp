import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class AddItems extends StatefulWidget {
  final DocumentSnapshot document;
  final String documentID;
  final List<String> categoryList;

  const AddItems({Key key, this.document, this.documentID, this.categoryList})
      : super(key: key);

  @override
  AddItemsState createState() {
    return new AddItemsState(document, documentID, categoryList);
  }
}

class AddItemsState extends State<AddItems> {
  String serialNumberBarcode = "";

  final GlobalKey<ScaffoldState> _scaffoldAddItemsKey =
      new GlobalKey<ScaffoldState>();

  final TextEditingController itemSerialNumber = new TextEditingController();
  final TextEditingController itemName = new TextEditingController();
  final TextEditingController itemPiece = new TextEditingController();
  final TextEditingController itemPrice = new TextEditingController();
  final TextEditingController itemExtras = new TextEditingController();

  final DocumentSnapshot document;
  String documentID = '';
  List<String> categoryList = [];
  List<DropdownMenuItem<String>> _dropdownCategoryItems = [];

  AddItemsState(this.document, this.documentID, this.categoryList);

  @override
  void dispose() {
    itemSerialNumber.clearComposing();
    itemSerialNumber.clear();
    itemName.clearComposing();
    itemName.clear();
    itemPiece.clearComposing();
    itemPiece.clear();
    itemPrice.clearComposing();
    itemPrice.clear();
    itemExtras.clearComposing();
    itemExtras.clear();
    try {
      super.dispose();
    } on Error {}
  }

  @override
  initState() {
    if (categoryList != null) {
      _dropdownCategoryItems = buildAndGetDropDownMenuItems(categoryList);
      documentID = _dropdownCategoryItems[0].value;
    } else {
      List<String> emptyList = [];
      emptyList.add(documentID);
      _dropdownCategoryItems = buildAndGetDropDownMenuItems(emptyList);
      documentID = _dropdownCategoryItems[0].value;
    }

    try {
      itemSerialNumber.text = document['serial_number_key'];
      itemName.text = document['name_key'];
      itemPiece.text = document['piece_key'].toString();
      itemPrice.text = document['price_key'].toString();
      itemExtras.text = document['extras_key'];
    } on NoSuchMethodError {} catch (e) {
      setState(() => this.serialNumberBarcode = 'Unknown error: $e');
    }
    super.initState();
  }

  List<DropdownMenuItem<String>> buildAndGetDropDownMenuItems(List categories) {
    List<DropdownMenuItem<String>> items = new List();
    for (String category in categories) {
      items.add(new DropdownMenuItem(
        child: new Text(category),
        value: category,
      ));
    }
    return items;
  }

  void changedDropDownItem(String selectedCategory) {
    setState(() {
      documentID = selectedCategory;
    });
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

  _addToFireStore() {
    final String serialConverted = itemSerialNumber.text;
    Firestore.instance
        .collection('gumush_db')
        .document(documentID)
        .collection(documentID)
        .document(serialConverted)
        .setData({
      'serial_number_key': itemSerialNumber.text,
      'name_key': itemName.text,
      'piece_key': int.parse(itemPiece.text),
      'price_key': itemPrice.text.isEmpty ? 0.0 : double.parse(itemPrice.text),
      'extras_key': itemExtras.text,
    });
    _showSnackBar();
    dispose();
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
    } on FormatException {} catch (e) {
      setState(() => this.serialNumberBarcode = 'Unknown error: $e');
    }
    return null;
  }

  Future<FutureBuilder> checkSerialNumber(String serialNumber) async {
    try {
      DocumentSnapshot result = await Firestore.instance
          .collection('gumush_db')
          .document(documentID)
          .collection(documentID)
          .document(serialNumber)
          .get();

      itemSerialNumber.text = result['serial_number_key'];
      itemName.text = result['name_key'];
      itemPiece.text = result['piece_key'].toString();
      itemPrice.text = result['price_key'].toString();
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
        _addToFireStore();
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
          padding: const EdgeInsets.all(10.0),
          children: <Widget>[
            new Visibility(
              visible: true,
              child: new Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: new InputDecorator(
                  decoration: const InputDecoration(
                    icon: const Icon(MdiIcons.satelliteVariant),
                  ),
                  child: new DropdownButtonHideUnderline(
                    child: new DropdownButton(
                        value: documentID,
                        items: _dropdownCategoryItems,
                        onChanged: changedDropDownItem),
                  ),
                ),
              ),
            ),
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
                controller: itemPrice,
                enabled: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: 'Price per unit',
                    border: OutlineInputBorder(),
                    helperText: 'Optional',
                    prefixIcon: new Icon(
                      Icons.attach_money,
                      color: Colors.green,
                    )),
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
