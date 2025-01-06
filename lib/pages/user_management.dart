
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stuff/pages/user_details_page.dart';

class UserManagement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Management')),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('users').get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var users = snapshot.data?.docs;
          return ListView.builder(
            itemCount: users?.length,
            itemBuilder: (context, index) {
              var user = users?[index];
              return ListTile(
                title: Text(user!['username']),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              UserDetailsPage(userId: user.id)));
                },
              );
            },
          );
        },
      ),
    );
  }
}
