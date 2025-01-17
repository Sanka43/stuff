import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stuff/pages/user_details_page.dart';
import 'admin_dashboard.dart';

class UserManagement extends StatelessWidget {
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
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/background.png', // Make sure you have the image in your assets
              fit: BoxFit.cover,
            ),
          ),
          // Scrollable content
          FutureBuilder(
            future: FirebaseFirestore.instance.collection('users').get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              var users = snapshot.data?.docs;
              var uniqueUsers = users
                  ?.map((user) => user['username']?.toString() ?? 'Unknown')
                  .toSet();

              return ListView.builder(
                padding: const EdgeInsets.only(top: 70),
                itemCount: uniqueUsers?.length,
                itemBuilder: (context, index) {
                  var username = uniqueUsers?.elementAt(index);
                  var user =
                      users?.firstWhere((user) => user['username'] == username);

                  return Card(
                    elevation: 5,
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(
                        username ?? '',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Tap to view details'),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    UserDetailsPage(userId: user?.id ?? '')));
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
