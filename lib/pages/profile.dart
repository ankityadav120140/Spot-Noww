import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spot_noww/pages/clientReg.dart';

import '../main.dart';
import '../utilities/global.dart';
import 'Register.dart';
import 'login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  bool _isEditing = false;
  bool registered = false;
  bool serviceAdded = false;
  Future<bool> doesDocumentExist(
      String collectionName, String documentId) async {
    final DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(documentId)
        .get();
    return docSnapshot.exists;
  }

  void getData() async {
    registered =
        await doesDocumentExist("users", "${preferences.getString('mail')}");
    serviceAdded =
        await doesDocumentExist("partners", "${preferences.getString('mail')}");
    setState(() {
      registered;
      serviceAdded;
    });
  }

  final _formKey = GlobalKey<FormState>();
  String _name = "";

  @override
  void initState() {
    // getData();
    super.initState();
    _nameController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _loadUserData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc("${preferences.getString('mail')}")
        .get();
    if (snapshot.exists) {
      final userData = snapshot.data() as Map<String, dynamic>;
      _nameController.text = userData['name'] ?? '';
    }
  }

  void _saveUserData() async {
    final newValue = _nameController.text.trim();
    if (newValue.isNotEmpty) {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc("${preferences.getString('mail')}");
      await docRef.update({'name': newValue});
      setState(() {
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    getData();
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Profile' : 'Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = true;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.0),
            _isEditing
                ? TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      border: OutlineInputBorder(),
                    ),
                  )
                : StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc("${preferences.getString('mail')}")
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData) {
                        return Text('No data');
                      } else if (snapshot.data?.exists == false) {
                        return Text('No users found');
                      } else {
                        final userData =
                            snapshot.data!.data() as Map<String, dynamic>;
                        return Column(
                          children: [
                            Container(
                              child: userData["profilePic"] == ""
                                  ? Container(
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.indigo,
                                        size: 80,
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(""),
                                    ),
                            ),
                            Container(
                              child: Text(userData["name"] == ""
                                  ? "Your Name"
                                  : userData["name"]),
                            ),
                          ],
                        );
                      }
                    },
                  ),
            SizedBox(height: 16.0),
            _isEditing
                ? Row(
                    children: [
                      ElevatedButton(
                        onPressed: _saveUserData,
                        child: Text('Save'),
                      ),
                      SizedBox(width: 8.0),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _nameController.text = _nameController.text.trim();
                          });
                        },
                        child: Text('Cancel'),
                      ),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
