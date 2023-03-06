import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GenProfile extends StatefulWidget {
  final String dp;
  final String name;
  final String phone;
  final String workEx;
  final String field;
  final String bio;
  const GenProfile(
      {required this.dp,
      required this.name,
      required this.phone,
      required this.workEx,
      required this.field,
      required this.bio,
      super.key});

  @override
  State<GenProfile> createState() => _GenProfileState();
}

class _GenProfileState extends State<GenProfile> {
  Widget dataCard(String name, String val) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w300,
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.4,
            child: Text(
              val,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                child: widget.dp != ""
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          widget.dp,
                          height: MediaQuery.of(context).size.height * 0.4,
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 85,
                      ),
              ),
              dataCard("Name : ", widget.name),
              Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Phone : ",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => launch("tel:${widget.phone}"),
                      child: Text(
                        widget.phone,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              dataCard("Bio : ", widget.bio),
              dataCard("Field Of Work : ", widget.field),
              dataCard("Work Experience : ", widget.workEx),
            ],
          ),
        ),
      ),
    );
  }
}
