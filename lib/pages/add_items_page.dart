import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
        _materialTypes =
            snapshot.docs.map((doc) => doc['name']?.toString() ?? '').toList();
        _isLoadingMaterials = false;
      });
    } catch (e) {
      print('Error fetching material types: $e');
      setState(() {
        _isLoadingMaterials = false;
      });
    }
  }

  // Fetch users from Firestore without duplicates
  Future<void> _fetchUsers() async {
    try {
      setState(() {
        _isLoadingUsers = true;
      });
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      // Use a Set to remove duplicates
      final uniqueUsers = <String>{};
      snapshot.docs.forEach((doc) {
        String username = doc['username']?.toString() ?? 'Unknown';
        uniqueUsers.add(username);
      });

      setState(() {
        _userList = uniqueUsers.toList();
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUsers = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching users: $e')),
      );
    }
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
      appBar: AppBar(
        title: Text(
          'Add Items',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        elevation: 8,
      ),
      body: Container(
        // color: Colors.green, // Set the background color to green

        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/background.png'), // Replace with your image path
            fit: BoxFit.cover,
          ),
        ),

        width: double.infinity, // Make sure container stretches full width
        height: double.infinity, // Make sure container stretches full height
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Material Type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              _isLoadingMaterials
                  ? Center(child: CircularProgressIndicator())
                  : Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0),
                        border: Border.all(
                            color: const Color.fromARGB(255, 255, 255, 255)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedMaterialType,
                        hint: Text('Choose Material Type',
                            style: TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 255, 255, 255))),
                        items: _materialTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type, style: TextStyle(fontSize: 16)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedMaterialType = value;
                          });
                        },
                        isExpanded: true,
                      ),
                    ),
              SizedBox(height: 16),
              Text(
                'Select Users',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              _isLoadingUsers
                  ? Center(child: CircularProgressIndicator())
                  : _userList.isEmpty
                      ? Center(
                          child: Text('No users available',
                              style: TextStyle(fontSize: 16)))
                      : Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: _userList.map((user) {
                            bool isSelected = _selectedUsers.contains(user);
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected
                                    ? Colors.blueAccent
                                    : Colors.grey,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedUsers.remove(user);
                                  } else {
                                    _selectedUsers.add(user);
                                  }
                                });
                              },
                              child: Text(user,
                                  style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black)),
                            );
                          }).toList(),
                        ),
              SizedBox(height: 16),
              TextField(
                controller: _costController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Cost',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Submit',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
