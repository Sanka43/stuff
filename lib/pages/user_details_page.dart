
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: Text('User Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: usersCollection.doc(userId).get(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return Center(
              child: Text(
                'User not found.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          String username = userData['username'] ?? 'Unknown';
          double totalCost = userData['totalCost']?.toDouble() ?? 0.0;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Username: $username',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Total Cost: \$${totalCost.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Things Usage:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

                    if (!itemSnapshot.hasData || itemSnapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'No usage found for this user.',
                          style: TextStyle(fontSize: 16),
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
                          child: ListTile(
                            title: Text('Material: $materialType'),
                            subtitle: Text('Cost: \$${cost.toStringAsFixed(2)}'),
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