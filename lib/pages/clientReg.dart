import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utilities/global.dart';
import 'home.dart';

final storageRef = FirebaseStorage.instance.ref();
final _formKey = GlobalKey<FormState>();

class ClientReg extends StatefulWidget {
  const ClientReg({super.key});

  @override
  State<ClientReg> createState() => _ClientRegState();
}

class _ClientRegState extends State<ClientReg> {
  late TextEditingController name;
  late TextEditingController bio;
  late TextEditingController phone;

  Future<String> uploadFile(File uploadFile, String value, String path) async {
    var profileFile = storageRef.child('$path/$value');
    UploadTask task = profileFile.putFile(uploadFile);
    TaskSnapshot snapshot = await task;
    String fileUrl = await snapshot.ref.getDownloadURL();
    return fileUrl.toString();
  }

  void register() async {
    DocumentReference ref = FirebaseFirestore.instance
        .collection('users')
        .doc(preferences.getString('mail'));
    // .doc();
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(ref);
      if (!snapshot.exists) {
        ref.set({
          'profilePic': dpLink,
          'name': name.text,
          'phone': phone.text,
          'docs': json.encode(docsLink),
          'bio': bio.text,
        }).then((value) {
          const snackBar = SnackBar(
            backgroundColor: Colors.green,
            content: Text('Registered successfully'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          preferences.setBool("registered", true);
          Get.offAll(Home());
          // showAlertDialog(context);
        });
      } else {
        ref.update({
          'profilePic': dpLink,
          'name': name.text,
          'phone': phone.text,
          'docs': json.encode(docsLink),
          'bio': bio.text,
        }).then((value) {
          const snackBar = SnackBar(
            backgroundColor: Colors.green,
            content: Text('Updated successfully'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          Get.offAll(Home());
        });
      }
    });
  }

  File? profilePic;
  String dpLink = '';
  void PickProfile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      setState(() {
        profilePic = File(result.files.single.path.toString());
      });
      dpLink = await uploadFile(profilePic!,
          {preferences.getString('mail')}.first as String, "ProfilePic");
    } else {
      print("No file selected");
    }
  }

  List<File>? docs;
  List<String> docsLink = [];

  void PickDocs() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'doc', 'jpeg', 'png'],
    );
    if (result != null) {
      setState(() {
        docs = result.paths.map((path) => File(path!)).toList();
      });

      for (int i = 0; i < docs!.length; i++) {
        docsLink.add(await uploadFile(docs![i],
            "${{preferences.getString('mail')}.first as String}+$i", "docs"));
      }
    } else {
      print("No file selected");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    name = TextEditingController(text: "");
    bio = TextEditingController(text: "");
    phone = TextEditingController(text: "");
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register as client"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              InkWell(
                onTap: PickProfile,
                child: profilePic == null
                    ? Container(
                        child: Icon(
                          Icons.person,
                          color: Colors.indigo,
                          size: 80,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          profilePic!,
                          height: 200,
                        ),
                      ),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: name,
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Contact Number';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Contact Number',
                ),
              ),
              TextFormField(
                maxLines: 3,
                controller: bio,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter Your Details';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'BIO',
                ),
              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: PickDocs,
                child: docs == null
                    ? Container(
                        child: Column(
                          children: [
                            Icon(
                              Icons.folder,
                              color: Colors.amber,
                              size: 80,
                            ),
                            Text(
                              "Documents",
                            ),
                          ],
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        height: 200,
                        child: ListView.builder(
                          itemCount: docs!.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              title: Text(
                                  docs![index].path.removeAllWhitespace.trim()),
                            );
                          },
                        ),
                      ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                height: 50,
                // margin: EdgeInsets.all(20),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Handle form submission here
                      print("Name : ${name.text}");
                      preferences.setBool("registered", true);
                      register();
                    }
                  },
                  child: Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
