// ignore_for_file: deprecated_member_use

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

class GenProfile extends StatefulWidget {
  final String dp;
  final String name;
  final String phone;
  final String workEx;
  final String field;
  final String bio;
  final List<dynamic> serviceImg;
  final String address;
  final GeoPoint loc;
  final String range;
  final String fees;
  final double rating;
  final int clients;
  final bool verified;
  const GenProfile(
      {required this.dp,
      required this.name,
      required this.phone,
      required this.workEx,
      required this.field,
      required this.bio,
      required this.serviceImg,
      required this.address,
      required this.loc,
      required this.range,
      required this.fees,
      required this.rating,
      required this.clients,
      required this.verified,
      super.key});

  @override
  State<GenProfile> createState() => _GenProfileState();
}

class _GenProfileState extends State<GenProfile> {
  Widget dataCard(String val) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Text(
              val,
              style: TextStyle(
                fontSize: 18,
                // fontWeight: FontWeight.w400,
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
            crossAxisAlignment: CrossAxisAlignment.center,
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
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                // width: MediaQuery.of(context).size.width * 0.4,
                child: Text(
                  widget.name,
                  style: TextStyle(
                    fontSize: 25,
                    // fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              widget.clients != 0
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RatingBarIndicator(
                          rating: widget.rating,
                          itemBuilder: (context, index) => Icon(
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
                            "(${widget.clients})",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        )
                      ],
                    )
                  : Container(
                      // child: Text(
                      //   "Fresher!",
                      //   style: TextStyle(
                      //     fontSize: 20,
                      //   ),
                      // ),
                      ),
              SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(20)),
                child: dataCard(widget.bio),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.work,
                      size: 25,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.72,
                      child: Text(
                        widget.field,
                        style: TextStyle(
                          fontSize: 18,
                          // fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 20),
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Work Experience : ",
                      style: TextStyle(fontSize: 18),
                    ),
                    Container(
                      // width: MediaQuery.of(context).size.width,
                      child: Text(
                        "${widget.workEx} years",
                        style: TextStyle(
                          fontSize: 18,
                          // fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 400,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    aspectRatio: 16 / 9,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enableInfiniteScroll: true,
                  ),
                  items: widget.serviceImg.map((image) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return Scaffold(
                            body: Container(
                              child: PhotoView(
                                imageProvider: NetworkImage(image),
                              ),
                            ),
                          );
                        }));
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        decoration: null,
                        child: FadeInImage(
                          placeholder: AssetImage(
                            'assets/loading.gif',
                          ),
                          image: NetworkImage(image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  " : Work Images : ",
                  style: TextStyle(fontSize: 17),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 30,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        double latitude = widget.loc.latitude;
                        double longitude = widget.loc.longitude;
                        double radius = double.parse(widget.range);
                        radius = radius * 1000;
                        final url =
                            'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude&query_place_id=$latitude,$longitude&circle=$latitude,$longitude,$radius';
                        // ignore: deprecated_member_use
                        launch(url);
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Text(
                          widget.address,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.underline,
                            color: Colors.indigo,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.phone),
                    SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () => launch("tel:${widget.phone}"),
                      child: Text(
                        widget.phone,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/waLogo.png",
                      width: MediaQuery.of(context).size.width * 0.08,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () async {
                        final url = 'https://wa.me/${widget.phone}';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      child: Text(
                        widget.phone,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.currency_rupee),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      widget.fees,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.underline,
                        // color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
