import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorScreen extends StatelessWidget {
  final CollectionReference patientsCollection =
      FirebaseFirestore.instance.collection('userData');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patients'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: patientsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No patients found'));
          }

          // Filter out doctors
          final docs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['isDoctor'] != true;
          }).toList();

          if (docs.isEmpty) {
            return Center(child: Text('No patients found'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final name = data['name'] ?? 'No Name';
              final phone = data['phone'] ?? 'No Phone';
              final symptoms = List<String>.from(data['symptoms'] ?? []);

              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          Icon(Icons.phone),
                          SizedBox(width: 5,),
                          Text(phone.toString())
                        ],
                      ),
                      
                      SizedBox(height: 6),
                      Text(
                        'Symptoms:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        children: symptoms
                            .map((symptom) => Chip(
                                  label: Text(symptom),
                                  backgroundColor: Colors.teal[100],
                                ))
                            .toList(),
                      ),
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
