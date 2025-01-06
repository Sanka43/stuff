import 'package:flutter/material.dart';
import 'user_management.dart';
import 'stuff_management.dart';
import 'add_items_page.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar:
          true, // Ensures the body extends behind the AppBar
      appBar: AppBar(
        title: Text(''),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Transparent AppBar
        elevation: 0, // Removes shadow under the AppBar
        leading: IconButton(
          icon: Icon(
            Icons.logout_rounded,
            color: const Color.fromARGB(255, 255, 0, 0), // Logout icon color
          ),
          tooltip: 'Log Out',
          onPressed: () {
            Navigator.pushNamed(context, '/');
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_box,
              color: Color.fromARGB(255, 17, 255, 0),
            ),
            tooltip: 'Add Items',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddItemsPage()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/background.png'), // Replace with your image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Main Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo and Title Section
              Padding(
                padding: const EdgeInsets.only(top: 150.0),
                child: Image.asset(
                  'assets/thc.png', // Add your logo image here
                  width: 100.0, // Adjust width
                  height: 100.0, // Adjust height
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'C a n n a b i s',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 48.0,
                  fontWeight: FontWeight.w500,
                  color: Color(0xffc2c2c2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
                child: Text(
                  'Cannabis is a plant used for medicinal, recreational, and industrial purposes, known for its psychoactive properties and health benefits.',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w300,
                    color: Color(0xffc3c3c3),
                  ),
                  textAlign: TextAlign.justify, // Justifies the text
                ),
              ),
              const SizedBox(height: 32.0), // Space between title and buttons
              // Buttons Section
              //stuff button
              Padding(
                padding: const EdgeInsets.only(top: 0.0, bottom: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage(
                          'assets/stuff_button.jpeg'), // Background image
                      fit: BoxFit
                          .cover, // Ensures the image covers the button area
                    ),
                    borderRadius: BorderRadius.circular(
                        50.0), // Rounded corners for the image
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5.0, horizontal: 100.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      backgroundColor: Colors
                          .transparent, // Make the button background transparent
                      foregroundColor: Colors.white, // Text color
                      elevation: 5, // Shadow effect
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => StuffManagement()),
                      );
                    },
                    child: const Text(
                      'S T U F F',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              //member button
              Padding(
                padding: const EdgeInsets.only(top: 0.0, bottom: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors
                        .transparent, // Set container color to transparent
                    border: Border.all(
                        color: Colors.white, width: 2), // White border
                    borderRadius: BorderRadius.circular(
                        50.0), // Rounded corners for the container
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5.0, horizontal: 75.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      backgroundColor: Colors
                          .transparent, // Make the button background transparent
                      foregroundColor: Colors.white, // Text color
                      elevation: 0, // No shadow effect
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserManagement()),
                      );
                    },
                    child: const Text(
                      'M E M B E R S',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
