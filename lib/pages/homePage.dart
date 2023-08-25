import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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
  final TextEditingController _searchQueryController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.5,
        child: ListView(
          children: [
            ListTile(
              leading: Icon(
                Icons.logout,
              ),
              title: Text("Logout"),
              onTap: () async {
                await auth.signOut();
                preferences.remove('registered');
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.contact_page,
              ),
              title: Text("Contact Us"),
              onTap: () async {},
            ),
            ListTile(
              leading: Icon(
                Icons.document_scanner,
              ),
              title: Text("Terms and services"),
              onTap: () async {},
            ),
            ListTile(
              leading: Icon(
                Icons.details,
              ),
              title: Text("About Us"),
              onTap: () async {},
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: TextField(
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: 'Search Services',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onSubmitted: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('partners')
                  .where('field', isGreaterThanOrEqualTo: _searchQuery)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.docs.isNotEmpty) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final doc = snapshot.data!.docs[index];
                        final name = doc['name'];
                        String img = snapshot.data!.docs[index]['profilePic'];
                        return InkWell(
                          onTap: () {
                            Get.to(GenProfile(
                              dp: img,
                              name: name,
                              phone: snapshot.data!.docs[index]['phone'],
                              workEx: snapshot.data!.docs[index]['workEx'],
                              field: snapshot.data!.docs[index]['field'],
                              bio: snapshot.data!.docs[index]['desc'],
                              address: snapshot.data!.docs[index]['address'],
                              fees: snapshot.data!.docs[index]['fee'],
                              loc: snapshot.data!.docs[index]['myLoc'],
                              range: snapshot.data!.docs[index]['range'],
                              serviceImg: json.decode(
                                  snapshot.data!.docs[index]['serviceImges']),
                              rating: snapshot.data!.docs[index]['rating'],
                              verified: false,
                              clients: snapshot.data!.docs[index]['clients'],
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
                                  height:
                                      MediaQuery.of(context).size.height * 0.2,
                                  width:
                                      MediaQuery.of(context).size.width * 0.335,
                                  child: img != ""
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Image.network(
                                            img,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Icon(
                                          Icons.person,
                                          size: 85,
                                        ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.55,
                                  padding: EdgeInsets.only(left: 10),
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
                                      // SizedBox(height: 40.0),

                                      snapshot.data!.docs[index]['clients'] != 0
                                          ? Row(
                                              children: [
                                                RatingBarIndicator(
                                                  rating: snapshot.data!
                                                      .docs[index]['rating'],
                                                  itemBuilder:
                                                      (context, index) => Icon(
                                                    Icons.star_outlined,
                                                    color: Colors.amber,
                                                  ),
                                                  itemCount: 5,
                                                  itemSize: 30.0,
                                                  unratedColor: Colors.grey,
                                                  direction: Axis.horizontal,
                                                ),
                                                Container(
                                                  child: Text(
                                                    "(${snapshot.data!.docs[index]['clients']})",
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            )
                                          : Container(
                                              child: Text(
                                                "Fresher!",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                            )
                                      // SizedBox(height: 20.0),

                                      // RatingBar.builder(
                                      //   initialRating: 3.1,
                                      //   minRating: 1,
                                      //   direction: Axis.horizontal,
                                      //   allowHalfRating: true,
                                      //   itemCount: 5,
                                      //   // itemPadding:
                                      //   //     EdgeInsets.symmetric(horizontal: 4.0),
                                      //   itemSize: 25,
                                      //   itemBuilder: (context, _) => Icon(
                                      //     Icons.star,
                                      //     color: Colors.amber,
                                      //   ),
                                      //   onRatingUpdate: (rating) {
                                      //     setState(() {});
                                      //     print(rating);
                                      //   },
                                      // ),
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
                  } else {
                    return Center(
                      child: Text(
                        'No service found',
                        style: TextStyle(fontSize: 20),
                      ),
                    );
                  }
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
