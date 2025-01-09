import 'dart:ui';

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
  bool _isSubmitted = false;

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

      // Use a Set to ensure unique usernames
      final uniqueUsers = snapshot.docs
          .map((doc) => doc['username']?.toString() ?? 'Unknown')
          .toSet();

      setState(() {
        _userList = uniqueUsers.toList();
        _isLoadingUsers = false;
      });
    } catch (e) {
      print('Error fetching users: $e');
      setState(() {
        _isLoadingUsers = false;
      });
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

    try {
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding item: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Add Items',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Padding(
              padding: const EdgeInsets.only(top: 100.0, right: 20, left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Material Type',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _buildDropdownSection();
                        },
                        child: Text('+'),
                      ),
                    ],
                  ),
                  _buildDropdownSection(),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Users',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Add new user logic
                        },
                        child: Text('+'),
                      ),
                    ],
                  ),
                  _buildUserSelectionSection(),
                  SizedBox(height: 20),
                  _buildCostInput(),
                  SizedBox(height: 20),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _isLoadingMaterials
            ? Center(child: CircularProgressIndicator())
            : DropdownButton<String>(
                value: _selectedMaterialType,
                hint: Text(
                  'Choose Material Type',
                  style: TextStyle(fontSize: 16, color: Color(0xFFc2c2c2)),
                ),
                items: _materialTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(
                      type,
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMaterialType = value;
                  });
                },
                isExpanded: true,
              ),
      ],
    );
  }

  Widget _buildUserSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        _isLoadingUsers
            ? Center(child: CircularProgressIndicator())
            : Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _userList.map((user) {
                  bool isSelected = _selectedUsers.contains(user);
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? const Color.fromARGB(255, 0, 0, 0)
                          : Colors.white,
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
                    child: Text(
                      user,
                      style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black),
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildCostInput() {
    return TextField(
      controller: _costController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Cost',
        labelStyle: TextStyle(color: Colors.white),
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
      style: TextStyle(color: Colors.white),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _isSubmitted = true;
          });
          _addItem();
        },
        style: ElevatedButton.styleFrom(
          minimumSize: Size(200, 40),
          backgroundColor: _isSubmitted ? Colors.white : Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: BorderSide(
              color: _isSubmitted ? Colors.green : Colors.white,
              width: _isSubmitted ? 0 : 2,
            ),
          ),
        ),
        child: Text(
          _isSubmitted ? 'Submitted' : 'Submit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _isSubmitted ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}
