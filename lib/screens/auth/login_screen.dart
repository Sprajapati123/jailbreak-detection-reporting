import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:provider/provider.dart';

import '../../services/local_notification_service.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/global_ui_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool? _jailbroken;
  bool? _developerMode;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    bool jailbroken;
    bool developerMode;

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      jailbroken = await FlutterJailbreakDetection.jailbroken;
      developerMode = await FlutterJailbreakDetection.developerMode;
    } on PlatformException {
      jailbroken = true; // Default to true if there's an error.
      developerMode = true;
    }

    if (!mounted) return;

    // Get device details
    final deviceDetails = await getDeviceDetails();

    if (jailbroken) {
      // Add additional info about jailbroken state
      deviceDetails["jailbroken"] = jailbroken;
      deviceDetails["developerMode"] = developerMode;
      deviceDetails["email"] = _emailController.text ?? "n/a";
    }

    setState(() {
      _jailbroken = jailbroken;
      _developerMode = developerMode;
    });
  }

  // Method to add data
  Future<void> addData(Map<String, dynamic> deviceData) async {
    try {
      // Add data to a collection
      await firestore.collection("deviceData").add(deviceData);
      print("Device details sent to Firebase!");
    } catch (e) {
      print("Error sending device details to Firebase: $e");
    }
  }

  bool _obscureTextPassword = true;

  final _formKey = GlobalKey<FormState>();

  void login() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }
    _ui.loadState(true);
    try {
      if (_jailbroken == true) {
        // Send to Firebase
        final deviceDetails = await getDeviceDetails();
        deviceDetails["jailbroken"] = _jailbroken;
        deviceDetails["developerMode"] = _developerMode;
        deviceDetails["email"] = _emailController.text.trim();
        deviceDetails["created_at"] = FieldValue.serverTimestamp();

        // Add device details to Firestore
        await addData(deviceDetails);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Your device is jailbroken. Device details have been sent to Firebase."),
        ));
      } else {
        await _authViewModel
            .login(_emailController.text, _passwordController.text)
            .then((value) {
          NotificationService.display(
            title: "Welcome back",
            body:
                "Hello ${_authViewModel.loggedInUser?.name},\n Hope you are having a wonderful day.",
          );
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }).catchError((e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.message.toString())));
        });
      }
    } catch (err) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err.toString())));
    }
    _ui.loadState(false);
  }

  late GlobalUIViewModel _ui;
  late AuthViewModel _authViewModel;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _ui = Provider.of<GlobalUIViewModel>(context, listen: false);
      _authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    });
    initPlatformState();

    super.initState();
  }

  Future<Map<String, dynamic>> getDeviceDetails() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    Map<String, dynamic> deviceData = {};

    // Getting device information
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      deviceData = {
        "model": androidInfo.model,
        "name": androidInfo.brand,
        "systemVersion": androidInfo.version.release,
        "platform": "Android",
      };
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      deviceData = {
        "model": iosInfo.model,
        "name": iosInfo.name,
        "systemVersion": iosInfo.systemVersion,
        "platform": "iOS",
      };
    }

    // Getting IP address
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4) {
          deviceData["ipAddress"] = addr.address;
        }
      }
    }


    return deviceData;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Image.asset(
                    "assets/images/logo.jpg",
                    height: 300,
                    width: 300,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: ValidateLogin.emailValidate,
                    style: const TextStyle(
                        fontFamily: 'WorkSansSemiBold',
                        fontSize: 16.0,
                        color: Colors.black),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      border: InputBorder.none,
                      prefixIcon: const Icon(
                        Icons.email,
                        color: Colors.black,
                        size: 22.0,
                      ),
                      hintText: 'Email Address',
                      hintStyle: const TextStyle(
                          fontFamily: 'WorkSansSemiBold', fontSize: 17.0),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscureTextPassword,
                    validator: ValidateLogin.password,
                    style: const TextStyle(
                        fontFamily: 'WorkSansSemiBold',
                        fontSize: 16.0,
                        color: Colors.black),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      prefixIcon: const Icon(
                        Icons.lock,
                        size: 22.0,
                        color: Colors.black,
                      ),
                      hintText: 'Password',
                      hintStyle: const TextStyle(
                          fontFamily: 'WorkSansSemiBold', fontSize: 17.0),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscureTextPassword = !_obscureTextPassword;
                          });
                        },
                        child: Icon(
                          _obscureTextPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 20.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed("/forget-password");
                        },
                        child: Text(
                          "Forgot password?",
                          style: TextStyle(color: Colors.grey.shade800),
                        ),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(color: Colors.blue))),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              const EdgeInsets.symmetric(vertical: 20)),
                        ),
                        onPressed: () {
                          login();
                        },
                        child: const Text(
                          "Log In",
                          style: TextStyle(fontSize: 20),
                        )),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Are you new? Create an account ",
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                      InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed("/register");
                          },
                          child: const Text(
                            "Sign up",
                            style: TextStyle(color: Colors.blue),
                          ))
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ValidateLogin {
  static String? emailValidate(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    return null;
  }
}
