// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:country_calling_code_picker/picker.dart';
import 'package:get/get.dart';
import 'package:spot_noww/pages/otp.dart';

import '../utilities/global.dart';

final _formKey = GlobalKey<FormState>();

class PhoneAuth extends StatefulWidget {
  const PhoneAuth({super.key});

  @override
  State<PhoneAuth> createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth> {
  late TextEditingController phone;
  late TextEditingController otp;
  Country? _selectedCountry;

  void _onPressedShowDialog() async {
    final country = await showCountryPickerDialog(
      context,
    );
    if (country != null) {
      setState(() {
        _selectedCountry = country;
      });
    }
  }

  void _onPressedShowBottomSheet() async {
    final country = await showCountryPickerSheet(
      context,
    );
    if (country != null) {
      setState(() {
        _selectedCountry = country;
      });
    }
  }

  Future<void> _sendVerificationCode(String phoneNumber) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval of verification code completed.
        // Sign in with the received credentials.
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');
        } else {
          print('Verification failed. Code: ${e.code}');
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        // Save the verification ID and resend token for later use
        // For now, just print them to the console
        print('Verification code sent to $phoneNumber');
        print('Verification ID: $verificationId');
        print('Resend token: $resendToken');
        preferences.setString('mail', phoneNumber);
        Get.off(otpVerify(
          verificationId: verificationId,
        ));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Called when the automatic code retrieval process times out
        // For now, just print to the console
        print('Auto retrieval timeout: $verificationId');
      },
    );
  }

  @override
  void initState() {
    initCountry();
    phone = TextEditingController(text: "");
    super.initState();
  }

  void initCountry() async {
    final country = await getDefaultCountry(context);
    setState(() {
      _selectedCountry = country;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Log in"),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Text(
                "Enter your phone number : ",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              child: GestureDetector(
                onTap: _onPressedShowBottomSheet,
                child: _selectedCountry == null
                    ? Container(
                        child: Text(
                          "Coutry code",
                        ),
                      )
                    : Row(
                        children: [
                          Image.asset(
                            _selectedCountry!.flag,
                            package: countryCodePackageName,
                            width: MediaQuery.of(context).size.width * 0.1,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            child: Text(
                              _selectedCountry!.callingCode,
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: Form(
                              key: _formKey,
                              child: TextFormField(
                                maxLength: 10,
                                autofocus: true,
                                controller: phone,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your Phone Number';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: "Phone Number",
                                  hintText: "0000000000",
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    String phoneNumber = phone.text.trim();
                    phoneNumber =
                        "${_selectedCountry!.callingCode}$phoneNumber";
                    print("PHONE NUMBER :: $phoneNumber");
                    _sendVerificationCode(phoneNumber);
                  }
                },
                child: Text(
                  'Generate OTP',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
