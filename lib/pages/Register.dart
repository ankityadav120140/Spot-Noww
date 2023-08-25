// ignore_for_file: prefer_const_constructors, prefer_final_fields, unused_field

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:spot_noww/pages/home.dart';
import 'package:spot_noww/utilities/global.dart';

final _formKey = GlobalKey<FormState>();
List<String> fields = [
  "NONE",
  "2 Wheeler Mechanic(Repair/ Service)",
  "AC Repair/ Service",
  "Adult Care Taker",
  "Advertisement",
  "Astrologer",
  "Autorickshaw Driver",
  "Baby Sitter",
  "Baker",
  "Barber",
  "Beauty Services",
  "Blacksmith (Steel & Iron)",
  "Cable TV Service",
  "Car Mechanic",
  "Carpenter",
  "Car Washing",
  "Catering Service",
  "Clothes Washing",
  "Cobbler (Mochi)",
  "Computer Hardware/ Software",
  "Construction Services",
  "Content Writer",
  "Contractor / Builder",
  "Cook",
  "Dietician",
  "Driver",
  "Dry Cleaner",
  "Electrician",
  "Electronic Appliances Repair",
  "Event Planner",
  "Fitness Coach",
  "Florist",
  "Fruit Seller",
  "Gardener",
  "Goldsmith",
  "Graphic Designer",
  "Health Services",
  "Home Cleaning",
  "House Help",
  "Interior Designer",
  "IT Services",
  "Job Consultant",
  "Kabbadi Wala",
  "Light & Sound",
  "Locksmith",
  "Matchmaker",
  "Mobile Repair",
  "Money Finance",
  "Packers & Movers",
  "Painter",
  "Pandit",
  "Party Decoration",
  "Pest Control",
  "Photographer/ Videographer",
  "Pick-up & Drop Service",
  "Plumber",
  "Printing Services",
  "Product Distributor",
  "Property Advisor",
  "Puncture Repair",
  "Social Media Manager",
  "Sports Coach",
  "Tailor",
  "Taxi",
  "Tiffin Service",
  "Tutor/ Educator",
  "Vegetable Seller",
  "Vehicle Sale/Purchase",
  "Water RO Service",
  "Wedding Planner",
  "Welding Service",
];

final storageRef = FirebaseStorage.instance.ref();

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late TextEditingController name;
  late TextEditingController workEx;
  late TextEditingController range;
  late TextEditingController fee;
  late TextEditingController bio;
  late TextEditingController phone;
  String selectedField = "NONE";

  Future<String> uploadFile(File uploadFile, String value, String path) async {
    var profileFile = storageRef.child('$path/$value');
    UploadTask task = profileFile.putFile(uploadFile);
    TaskSnapshot snapshot = await task;
    String fileUrl = await snapshot.ref.getDownloadURL();
    return fileUrl.toString();
  }

  void register() async {
    DocumentReference ref = FirebaseFirestore.instance
        .collection('partner s')
        .doc(preferences.getString('mail'));
    // .doc();
    GeoPoint location =
        GeoPoint(_locationData.latitude!, _locationData.longitude!);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(ref);
      if (!snapshot.exists) {
        ref.set({
          'profilePic': dpLink,
          'name': name.text,
          'field': selectedField,
          'workEx': workEx.text,
          'serviceImges': json.encode(serviceImgLink),
          'desc': bio.text,
          'phone': phone.text,
          'myLoc': location,
          'address': _currentAddress,
          'fee': fee.text,
          'range': range.text,
          'docs': json.encode(docsLink),
          'rating': 0.0,
          'clients': 0,
          'verified': false,
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
          'field': selectedField,
          'workEx': workEx.text,
          'serviceImges': json.encode(serviceImgLink),
          'desc': bio.text,
          'phone': phone.text,
          'myLoc': location,
          'address': _currentAddress,
          'fee': fee.text,
          'range': range.text,
          'docs': json.encode(docsLink),
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

  List<File>? serviceImg;
  List<String> serviceImgLink = [];

  void PickServiceImg() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );
    if (result != null) {
      setState(() {
        serviceImg = result.paths.map((path) => File(path!)).toList();
      });

      for (int i = 0; i < serviceImg!.length; i++) {
        serviceImgLink.add(await uploadFile(
          serviceImg![i],
          "${{preferences.getString('mail')}.first as String}+$i",
          "serviceImg",
        ));
      }
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
      allowedExtensions: [
        'jpg',
        'pdf',
        'doc',
        'jpeg',
        'png',
      ],
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

  bool isLoading = false;

  late LocationData _locationData;
  String _currentAddress = "";

  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoading = true;
    });

    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    _getAddressFromLatLng();
  }

  _getAddressFromLatLng() async {
    try {
      // Ensure that _locationData is initialized before using it
      if (_locationData == null) {
        await _getCurrentLocation();
      }

      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        _locationData.latitude!,
        _locationData.longitude!,
      );

      geo.Placemark place = placemarks[0];

      setState(() {
        _currentAddress =
            "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
      });

      // _saveLocationToFirestore();
    } catch (e) {
      print(e);
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _getCurrentLocation();
    name = TextEditingController(text: "");
    workEx = TextEditingController(text: "");
    bio = TextEditingController(text: "");
    phone = TextEditingController(text: "");
    range = TextEditingController(text: "");
    fee = TextEditingController(text: "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Regsiter as partner",
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
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
                    InputDecorator(
                      decoration: InputDecoration(
                        label: Text(
                          "Service you provide",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      child: DropdownSearch(
                        mode: Mode.BOTTOM_SHEET,
                        showSearchBox: true,
                        items: fields,
                        enabled: true,
                        onChanged: (value) {
                          setState(() {
                            selectedField = value!;
                          });
                        },
                        selectedItem: selectedField,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: workEx,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your work experience year';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Years of experience',
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(20)),
                      child: InkWell(
                        onTap: PickServiceImg,
                        child: serviceImg == null
                            ? Container(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.photo_library,
                                      color: Colors.indigo,
                                      size: 80,
                                    ),
                                    Text(
                                      "Add work related images",
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                width: double.infinity,
                                height: 200,
                                child: ListView.builder(
                                  itemCount: serviceImg!.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return ListTile(
                                      title: Text(serviceImg![index]
                                          .path
                                          .removeAllWhitespace
                                          .trim()),
                                    );
                                  },
                                ),
                              ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
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
                        labelText: 'Provide a decription',
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
                    SizedBox(
                      height: 20,
                    ),
                    _currentAddress == ""
                        ? Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(20)),
                            child: InkWell(
                              onTap: _getCurrentLocation,
                              child: Container(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.indigo,
                                      size: 80,
                                    ),
                                    Text(
                                      "Pick my location",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : isLoading ||
                                _currentAddress
                                    .isEmpty // check for both conditions here
                            ? Center(
                                child: Container(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'Address: $_currentAddress',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                    SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: PickDocs,
                      child: docs == null
                          ? Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.folder,
                                    color: Colors.amber,
                                    size: 80,
                                  ),
                                  Text(
                                    "Documents and Certificates",
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
                                    title: Text(docs![index]
                                        .path
                                        .removeAllWhitespace
                                        .trim()),
                                  );
                                },
                              ),
                            ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: fee,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your visiting charge';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Visiting Charges',
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: range,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your range of service';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'My range (KM)',
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
                            print("YOE : ${workEx.text}");
                            print("Field : $selectedField");
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
