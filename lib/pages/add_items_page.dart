import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class AddItemsPage extends StatefulWidget {
  @override
  _AddItemsPageState createState() => _AddItemsPageState();
}

class _AddItemsPageState extends State<AddItemsPage> {
  final _costController = TextEditingController();
  String? _selectedMaterialType;
  List<String> _materialTypes = [];
  List<String> _userList = [];
  List<String> _selectedUsers = [];
  bool _isLoadingMaterials = true;
  bool _isLoadingUsers = true;

  @override
  void initState() {
    super.initState();
    _fetchMaterialTypes();
    _fetchUsers();
  }

  // Fetch material types from Firestore
  Future<void> _fetchMaterialTypes() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('materialTypes').get();
      setState(() {
        _materialTypes = snapshot.docs
            .map((doc) => doc['username']?.toString() ?? '')
            .toList();
        _isLoadingMaterials = false; // Stop loading spinner for materials
      });
    } catch (e) {
      print('Error fetching material types: $e');
      setState(() {
        _isLoadingMaterials = false; // Stop loading spinner
      });
    }
  }

  // Fetch users from Firestore
  Future<void> _fetchUsers() async {
    try {
      setState(() {
        _isLoadingUsers = true; // Show loading indicator for users
      });
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        _userList = snapshot.docs
            .map((doc) =>
                doc['username']?.toString() ??
                'Unknown') // Safely cast to String
            .toList();
        _isLoadingUsers = false; // Stop loading indicator for users
      });
    } catch (e) {
      setState(() {
        _isLoadingUsers = false; // Stop loading indicator for users
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching users: $e')),
      );
    }
  }

  // Add new material type to Firestore
  Future<void> _addMaterialType() async {
    final TextEditingController _newMaterialController =
        TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Material Type'),
          content: TextField(
            controller: _newMaterialController,
            decoration: InputDecoration(labelText: 'Material Type'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String newMaterial = _newMaterialController.text.trim();
                if (newMaterial.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('materialTypes')
                      .add({'name': newMaterial});
                  _fetchMaterialTypes(); // Refresh the list
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$newMaterial added to materials')),
                  );
                }
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Add item to Firestore
  Future<void> _addItem() async {
    if (_selectedMaterialType == null ||
        _costController.text.isEmpty ||
        _selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    double cost = double.parse(_costController.text);
    double dividedCost = cost / _selectedUsers.length;

    // Save to 'usedMaterial' collection
    await FirebaseFirestore.instance.collection('usedMaterial').add({
      'materialType': _selectedMaterialType,
      'cost': cost,
      'users': _selectedUsers,
      'dateTime': Timestamp.now(),
    });

    // Update each user's record with the divided cost
    for (String user in _selectedUsers) {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: user)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        var userDoc = userSnapshot.docs.first;
        double currentCost = userDoc['cost'] != null ? userDoc['cost'] : 0.0;

        // Update the user's cost field
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userDoc.id)
            .update({
          'cost': currentCost + dividedCost,
        });
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Item added successfully')),
    );

    // Clear inputs
    setState(() {
      _selectedMaterialType = null;
      _costController.clear();
      _selectedUsers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Items')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Material Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: _isLoadingMaterials
                        ? CircularProgressIndicator()
                        : DropdownButton<String>(
                            value: _selectedMaterialType,
                            hint: Text('Choose Material Type'),
                            items: _materialTypes.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedMaterialType = value;
                              });
                            },
                          ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _addMaterialType,
                    tooltip: 'Add New Material Type',
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Select Users',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              _isLoadingUsers
                  ? CircularProgressIndicator()
                  : MultiSelectDialogField(
                      items: _userList
                          .map((user) => MultiSelectItem(user, user))
                          .toList(),
                      initialValue: _selectedUsers,
                      title: Text('Users'),
                      buttonText: Text('Choose Users'),
                      onConfirm: (values) {
                        setState(() {
                          _selectedUsers = values.cast<String>();
                        });
                      },
                    ),
              SizedBox(height: 16),
              TextField(
                controller: _costController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Cost'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addItem,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
