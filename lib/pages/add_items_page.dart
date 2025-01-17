import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stuff/pages/admin_dashboard.dart';

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
  bool _isSubmitted = false; // Track submission status

  @override
  void initState() {
    super.initState();
    _fetchMaterialTypes();
    _fetchUsers();
  }

  Future<void> _fetchMaterialTypes() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('materialTypes').get();
      setState(() {
        _materialTypes =
            snapshot.docs.map((doc) => doc['name']?.toString() ?? '').toList();
      });
    } catch (e) {
      print('Error fetching material types: $e');
    } finally {
      setState(() => _isLoadingMaterials = false);
    }
  }

  Future<void> _fetchUsers() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        _userList = snapshot.docs
            .map((doc) => doc['username']?.toString() ?? ' ')
            .toSet()
            .toList();
      });
    } catch (e) {
      print('Error fetching users: $e');
    } finally {
      setState(() => _isLoadingUsers = false);
    }
  }

  Future<void> _addItem() async {
    if (_selectedMaterialType == null ||
        _costController.text.isEmpty ||
        _selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    try {
      double cost = double.parse(_costController.text);
      double dividedCost = cost / _selectedUsers.length;

      await FirebaseFirestore.instance.collection('usedMaterial').add({
        'materialType': _selectedMaterialType,
        'cost': cost,
        'users': _selectedUsers,
        'dateTime': Timestamp.now(),
      });

      for (String user in _selectedUsers) {
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: user)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          var userDoc = userSnapshot.docs.first;
          double currentCost =
              double.tryParse(userDoc['cost']?.toString() ?? '0.0') ?? 0.0;

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userDoc.id)
              .update({
            'cost': currentCost + dividedCost,
          });
        }
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Item added successfully')));
      _resetForm();

      setState(() {
        _isSubmitted = true; // Set the submission status to true
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error adding item: $e')));
    }
  }

  void _resetForm() {
    setState(() {
      _selectedMaterialType = null;
      _costController.clear();
      _selectedUsers.clear();
    });
  }

  // Function to add a new user
  void _addNewUser(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter both username and password')));
      return;
    }

    try {
      // Add the new user to Firestore
      await FirebaseFirestore.instance.collection('users').add({
        'username': username,
        'password': password, // Ideally, hash the password before storing it
        'cost': 0.0, // Assuming a new user starts with a cost of 0.0
        'role': 'user', // Assuming a new user is a regular user
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('New user added successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error adding user: $e')));
    }
  }

  // Function to add a new material type
  void _addNewMaterialType(String materialType) async {
    if (materialType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a material type')));
      return;
    }

    try {
      // Add the new material type to Firestore
      await FirebaseFirestore.instance.collection('materialTypes').add({
        'name': materialType,
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('New material type added successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding material type: $e')));
    }
  }

  // Show Add User Dialog
  void _showAddUserDialog() {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add New User"),
          content: Column(
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: "Username"),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true, // Hide password text
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                String username = usernameController.text.trim();
                String password = passwordController.text.trim();
                _addNewUser(username, password);
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Add"),
            ),
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without any action
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  // Show Add Material Dialog
  void _showAddMaterialDialog() {
    final materialController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add New Material Type"),
          content: TextField(
            controller: materialController,
            decoration: InputDecoration(labelText: "Material Type"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                String materialType = materialController.text.trim();
                _addNewMaterialType(materialType);
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Add Material"),
            ),
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without any action
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          '',
          style: TextStyle(
              color: Colors.white, fontFamily: 'Roboto', fontSize: 24.0),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: null, // This line removes the back arrow button
        actions: [
          IconButton(
            icon: const Icon(
              Icons.home,
              color: Color.fromARGB(255, 245, 248, 247),
            ),
            tooltip: 'Home',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminDashboard()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Scrollable content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  _buildDropdownSection(),
                  SizedBox(height: 20),
                  _buildUserSelectionSection(),
                  SizedBox(height: 20),
                  _buildCostInput(),
                  SizedBox(height: 20),
                  _buildSubmitButton(),
                  SizedBox(height: 40),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Select Material Type',
          style: TextStyle(
            fontSize: 20,
            letterSpacing: 1,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        SizedBox(height: 10),
        _isLoadingMaterials
            ? const CircularProgressIndicator()
            : DropdownButton<String>(
                value: _selectedMaterialType,
                hint: const Text(
                  'Choose Material Type',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
                items: _materialTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 0, 0, 0)
                            .withOpacity(0.9), // Transparent black background
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          type,
                          style: const TextStyle(
                            color: Colors.white, // White text color
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedMaterialType = value),
                isExpanded: true,
                dropdownColor: Colors
                    .transparent, // To make the dropdown itself transparent
              ),
      ],
    );
  }

  Widget _buildUserSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Select Users',
            style: TextStyle(
                fontSize: 20,
                letterSpacing: 2,
                color: Color(0xffffffff),
                fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        _isLoadingUsers
            ? CircularProgressIndicator()
            : Wrap(
                spacing: 8.0,
                alignment: WrapAlignment.center,
                children: _userList.map((user) {
                  bool isSelected = _selectedUsers.contains(user);
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? const Color.fromARGB(255, 0, 0, 0)
                          : Colors.grey[200],
                      foregroundColor: isSelected ? Colors.white : Colors.black,
                    ),
                    onPressed: () => setState(() {
                      isSelected
                          ? _selectedUsers.remove(user)
                          : _selectedUsers.add(user);
                    }),
                    child: Text(user),
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildCostInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Enter Cost',
            style: TextStyle(
              fontSize: 20,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
              color: Color(0xffffffff),
            )),
        const SizedBox(height: 10),
        TextField(
          controller: _costController,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            color: Colors.white, // Set the text color to white
          ),
          decoration: const InputDecoration(
            labelText: 'Cost',
            labelStyle: TextStyle(
              color: Color(0xaaaaaaaa),
              letterSpacing: 1,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _isSubmitted ? null : _addItem,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            _isSubmitted
                ? const Color.fromARGB(255, 0, 0, 0)
                : const Color.fromARGB(255, 255, 255, 255),
          ),
          fixedSize: MaterialStateProperty.all(Size(200, 50)),
        ),
        child: Text(
          _isSubmitted ? 'Submitted' : 'Submit',
          style: TextStyle(
            color: _isSubmitted
                ? const Color.fromARGB(255, 255, 255, 255)
                : const Color.fromARGB(255, 0, 0, 0),
            fontSize: 16,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 50,
          child: ElevatedButton(
            onPressed: _showAddUserDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            ),
            child: const Text(
              'User',
              style: TextStyle(color: Color(0xFF000000)),
            ),
          ),
        ),
        SizedBox(width: 20),
        Container(
          width: 100,
          height: 50,
          child: ElevatedButton(
            onPressed: _showAddMaterialDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            ),
            child: const Text(
              'Material',
              style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
