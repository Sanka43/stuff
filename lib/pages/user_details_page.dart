import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stuff/pages/admin_dashboard.dart';

class UserDetailsPage extends StatelessWidget {
  final String userId; // User ID passed to this page
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference itemsCollection =
      FirebaseFirestore.instance.collection('items');

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
        leading: null, // This line removes the back arrow button
        actions: [
          IconButton(
            icon: const Icon(
              Icons.home,
              color: Color.fromARGB(255, 255, 255, 255),
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
      body: FutureBuilder<DocumentSnapshot>(
        future: usersCollection.doc(userId).get(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return const Center(
              child: Text(
                'User not found.',
                style: TextStyle(
                    fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
              ),
            );
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          String username = userData['username'] ?? 'Unknown';
          double totalCost = userData['totalCost']?.toDouble() ?? 0.0;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 100.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$username',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurpleAccent),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Total Cost: Rs.${totalCost.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 20),
                    const Text(
                      'Things Usage:',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurpleAccent),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: itemsCollection
                      .where('users', arrayContains: username)
                      .snapshots(),
                  builder: (context, itemSnapshot) {
                    if (itemSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!itemSnapshot.hasData ||
                        itemSnapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No usage found for this user.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }

                    final items = itemSnapshot.data!.docs;

                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final itemData =
                            items[index].data() as Map<String, dynamic>;
                        String materialType =
                            itemData['materialType'] ?? 'Unknown';
                        double cost = itemData['cost']?.toDouble() ?? 0.0;

                        return Card(
                          margin: EdgeInsets.all(10),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Text('Material: $materialType'),
                            subtitle:
                                Text('Cost: \$${cost.toStringAsFixed(2)}'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
