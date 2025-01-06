import 'package:flutter/material.dart';

class AddItemsPage extends StatefulWidget {
  @override
  _AddItemsPageState createState() => _AddItemsPageState();
}

class _AddItemsPageState extends State<AddItemsPage> {
  final _materialController = TextEditingController();
  final _costController = TextEditingController();
  final _userController = TextEditingController();

  Future<void> addItem() async {
  //   String materialType = _materialController.text;
  //   double cost = double.parse(_costController.text);
  //   String username = _userController.text;

  //   await FirebaseFirestore.instance.collection('items').add({
  //     'materialType': materialType,
  //     'cost': cost,
  //     'username': username,
  //     'dateTime': Timestamp.now(),
  //   });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Items')),
      body: Column(
        children: [
          TextField(
              controller: _materialController,
              decoration: InputDecoration(labelText: 'Material Type')),
          TextField(
              controller: _costController,
              decoration: InputDecoration(labelText: 'Cost')),
          TextField(
              controller: _userController,
              decoration: InputDecoration(labelText: 'User')),
          ElevatedButton(
            onPressed: addItem,
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}
