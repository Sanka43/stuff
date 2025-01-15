import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stuff/pages/user_details_page.dart';

class UserManagement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder(
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    );
  }
}
