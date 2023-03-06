import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spot_noww/pages/genProfile.dart';

import '../main.dart';
import '../utilities/global.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text("Home"),
            Expanded(child: Container()),
            IconButton(
              onPressed: () async {
                await auth.signOut();
                preferences.remove('registered');
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
              icon: Icon(
                Icons.logout,
              ),
            )
          ],
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('partners').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final name = doc['name'];
                String img = snapshot.data!.docs[index]['profilePic'];
                return InkWell(
                  onTap: () {
                    Get.to(GenProfile(
                      dp: snapshot.data!.docs[index]['profilePic'],
                      name: name,
                      phone: snapshot.data!.docs[index]['phone'],
                      workEx: snapshot.data!.docs[index]['workEx'],
                      field: snapshot.data!.docs[index]['field'],
                      bio: snapshot.data!.docs[index]['bio'],
                    ));
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        Container(
                            height: MediaQuery.of(context).size.height * 0.2,
                            width: MediaQuery.of(context).size.width * 0.335,
                            child: img != ""
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      img,
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 85,
                                  )),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Column(
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                snapshot.data!.docs[index]['field'],
                                overflow: TextOverflow.fade,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
                // return ListTile(
                //   title: Text(name),
                // );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
