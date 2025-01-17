import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stuff/pages/admin_dashboard.dart';
import 'package:intl/intl.dart';

class StuffManagement extends StatelessWidget {
  final CollectionReference itemsCollection =
      FirebaseFirestore.instance.collection('usedMaterial');

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
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image:
                    AssetImage('assets/background.png'), // Path to your image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Foreground content
          StreamBuilder<QuerySnapshot>(
            // Query Firestore and sort by 'dateTime' field in descending order
            stream: itemsCollection
                .orderBy('dateTime', descending: true)
                .snapshots(),
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
                padding: const EdgeInsets.only(
                    top: 100), // To avoid content behind AppBar
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final itemData = items[index].data() as Map<String, dynamic>;

                  // Extracting data with null safety
                  String materialType = itemData['materialType'] ?? 'Unknown';
                  double cost = (itemData['cost'] != null)
                      ? itemData['cost'].toDouble()
                      : 0.0;
                  List<dynamic> users = itemData['users'] ?? [];
                  Timestamp? timestamp = itemData['dateTime'];

                  // Convert timestamp to a readable date
                  String dateAdded = timestamp != null
                      ? DateFormat('yyyy-MM-dd HH:mm:ss')
                          .format(timestamp.toDate())
                      : 'Unknown';

                  return Card(
                    margin: const EdgeInsets.all(10),
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
                            '$materialType',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text('Cost: Rs.${cost.toStringAsFixed(2)}'),
                          const SizedBox(height: 5),
                          Text('Number of Uses: ${users.length}'),
                          const SizedBox(height: 5),
                          Text('Date Added: $dateAdded'),
                          const SizedBox(height: 10),
                          const Text(
                            'Users:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color.fromARGB(255, 104, 104, 104),
                            ),
                          ),
                          ...users.map((user) => Text('~ $user')).toList(),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          )
        ],
      ),
    );
  }
}
