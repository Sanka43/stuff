import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> registerUser() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    // Check if username or password is empty
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username and Password are required!')),
      );
      return; // Exit if validation fails
    }

    try {
      await FirebaseFirestore.instance.collection('users').add({
        'username': username,
        'password': password,
        'role': 'user',
        'cost': '0',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User registered successfully!')),
      );
    } catch (e) {
      print("$e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error registering user: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Register')),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/background.png'), // Replace with your image path
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0), // Padding around the card
            child: Card(
              elevation: 8, // Adds shadow to the card
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16), // Rounds the corners of the card
              ),
              color: Colors.white.withOpacity(0.5), // Card background color
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 16.0, left: 16, right: 16, bottom: 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize:
                      MainAxisSize.min, // Ensures the card wraps its content
                  children: [
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: TextStyle(
                            color: Colors.white), // Change label text color
                        filled: true,
                        fillColor: Colors.white.withOpacity(0),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              width: 2.0), // Border color
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: const Color.fromARGB(255, 253, 253, 253),
                              width: 2.0), // Border color when enabled
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              width: 2.0), // Border color when focused
                        ),
                      ),
                      style: TextStyle(
                          color: Colors.white), // Text color inside input
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                            color: Colors.white), // Change label text color
                        filled: true,
                        fillColor: Colors.white.withOpacity(0),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              width: 2.0), // Border color
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              width: 2.0), // Border color when enabled
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              width: 2.0), // Border color when focused
                        ),
                      ),
                      obscureText: true,
                      style: TextStyle(
                          color: Colors.white), // Text color inside input
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: registerUser,
                      child: Text('Register'),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                            context, '/'); // Navigate to the login page
                      },
                      child: Text('Already have an account? Login here.'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
