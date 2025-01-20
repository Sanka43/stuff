import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stuff/pages/admin_dashboard.dart';

class UserDetailsPage extends StatelessWidget {
  final String userId; // User ID passed to this page
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  UserDetailsPage({required this.userId});

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.home,
              color: Colors.white,
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
          Positioned.fill(
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
            ),
          ),
          FutureBuilder<DocumentSnapshot>(
            future: usersCollection.doc(userId).get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return const Center(
                  child: Text(
                    'User not found.',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                );
              }

              final userData =
                  userSnapshot.data!.data() as Map<String, dynamic>;
              String username = userData['username'] ?? 'Unknown';
              double totalCost = userData['cost']?.toDouble() ?? 0.0;

              return Column(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 200.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              '$username'.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 30,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          SizedBox(height: 30),
                          const Center(
                            child: Text(
                              'Total Cost',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 159, 159, 159)),
                            ),
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: Text(
                              'Rs.${totalCost.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 36,
                                  color: Color.fromARGB(255, 255, 0, 0)),
                            ),
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: () => _showReduceCostDialog(
                                  context, totalCost, username),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    Colors.transparent, // White text color
                                side: const BorderSide(
                                    color: Colors.white,
                                    width: 2), // White border
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      50), // Rounded corners
                                ),
                                elevation: 0, // No shadow
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Reduce Cost',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showReduceCostDialog(
      BuildContext context, double currentCost, String username) {
    final TextEditingController costController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reduce Cost'),
          content: TextField(
            controller: costController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter amount to reduce',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final String enteredCost = costController.text;
                if (enteredCost.isNotEmpty) {
                  double reduceAmount = double.tryParse(enteredCost) ?? 0.0;
                  if (reduceAmount > 0 && reduceAmount <= currentCost) {
                    await usersCollection.doc(userId).update({
                      'cost': currentCost - reduceAmount,
                    });
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          reduceAmount > currentCost
                              ? 'Reduce amount exceeds current cost.'
                              : 'Enter a valid amount.',
                        ),
                      ),
                    );
                  }
                }
              },
              child: const Text('Reduce'),
            ),
          ],
        );
      },
    );
  }
}
