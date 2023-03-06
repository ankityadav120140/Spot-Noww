// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spot_noww/main.dart';
import 'package:spot_noww/pages/home.dart';

final _formKey = GlobalKey<FormState>();

class otpVerify extends StatefulWidget {
  final String verificationId;
  const otpVerify({required this.verificationId, super.key});

  @override
  State<otpVerify> createState() => _otpVerifyState();
}

class _otpVerifyState extends State<otpVerify> {
  final bool _isLoading = false;
  late TextEditingController otp;

  void _signInWithPhoneNumber() async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: widget.verificationId, smsCode: otp.text);

      final User user = (await auth.signInWithCredential(credential)).user!;

      print('User signed in successfully: ${user.uid}');
      Get.offAll(Home());
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    otp = TextEditingController(text: "");
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Container(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Text(
                          "Enter OTP : ",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: otp,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter valid OTP';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'OTP',
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 50,
                        margin: EdgeInsets.symmetric(horizontal: 40),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _signInWithPhoneNumber,
                          child: Text(
                            'Verify',
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
      ),
    );
  }
}
