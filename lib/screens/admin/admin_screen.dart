import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: const Text("Admin Dashboard"),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.logout))],


      ),
      body:StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('deviceData').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Data Found"));
          }

          // Displaying data
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = snapshot.data!.docs[index];
              Timestamp timestamp = doc['created_at'];
              DateTime dateTime = timestamp.toDate();

              return ExpansionTile(
                maintainState: true,
                title: Text(doc['model']),children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Secure: ${doc["jailbroken"] == true ? "Yes" : "No"}"),
                  Text("Device name: " + doc['name'] ?? 'No Title'),
                  Text("Platform: " + doc['platform'] ?? 'No Title'),
                  Text("System version: "+doc['systemVersion'] ?? 'No Subtitle'),
                  Text("Email : "+doc['email'] ?? 'No Subtitle'),
                  Text("IP Address : "+doc['ipAddress'] ?? 'No Subtitle'),
                  Text("Developer Mode: ${doc["developerMode"]}"),
                  Text("Last Scanned: ${DateFormat("MMMM d, y 'at' h:mm:ss a").format(dateTime)}" ),

                ],
              )
              ],);
            },
          );
        },
      ),
    );
  }
}
