import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StuffManagement extends StatelessWidget {
  final CollectionReference itemsCollection =
      FirebaseFirestore.instance.collection('usedMaterial');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stuff Management'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: itemsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No items found.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final items = snapshot.data!.docs;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final itemData = items[index].data() as Map<String, dynamic>;

              // Extracting data with null safety
              String materialType = itemData['materialType'] ?? 'Unknown';
              double cost = (itemData['cost'] != null)
                  ? itemData['cost'].toDouble()
                  : 0.0;
              List<dynamic> users = itemData['users'] ?? [];
              Timestamp? timestamp = itemData['timestamp'];

              // Convert timestamp to a readable date
              String dateAdded =
                  timestamp != null ? timestamp.toDate().toString() : 'Unknown';

              return Card(
                margin: EdgeInsets.all(10),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Type: $materialType',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text('Cost: Rs.${cost.toStringAsFixed(2)}'),
                      SizedBox(height: 5),
                      Text('Number of Uses: ${users.length}'),
                      SizedBox(height: 5),
                      Text('Date Added: $dateAdded'),
                      SizedBox(height: 10),
                      Text(
                        'Users:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      ...users.map((user) => Text('- $user')).toList(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
