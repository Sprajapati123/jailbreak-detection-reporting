import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/local_notification_service.dart';
import '../../viewmodels/auth_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late AuthViewModel _authViewModel;


  Future<bool> checkRootCommands() async {
    try {
      if (Platform.isAndroid) {
        // Check for root binaries on Android
        ProcessResult result = await Process.run('which', ['su']);
        if (result.stdout.toString().isNotEmpty) {
          return true; // Root detected
        }
      } else if (Platform.isIOS) {
        // For iOS, check for jailbreak files instead of running shell commands
        List<String> suspiciousPaths = [
          "/bin/bash",
          "/usr/sbin/sshd",
          "/etc/apt",
          "/private/var/lib/apt/"
        ];
        for (String path in suspiciousPaths) {
          if (await File(path).exists()) {
            return true; // Jailbreak detected
          }
        }
      }
    } catch (e) {
      return false;
    }

    return false; // Not rooted or jailbroken
  }


  void checkLogin() async{
    bool rootCommands = await checkRootCommands();
    if (rootCommands) {
      print("Root commands detected!");
    }
    bool writable = await checkWritableSystemDir();
    if (writable) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Alert'),
            content: Text('System directory is writable. Device may be rooted or jailbroken'),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  // Perform an action
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );

    }
    String? token = await FirebaseMessaging.instance.getToken();

    await Future.delayed(const Duration(seconds: 2));
    // check for user detail first
    try{
      await _authViewModel.checkLogin(token);
      if(_authViewModel.user==null){
        Navigator.of(context).pushReplacementNamed("/login");
      }else{
        NotificationService.display(
          title: "Welcome back",
          body: "Hello ${_authViewModel.loggedInUser?.name},\n We have been waiting for you.",
        );
        if(_authViewModel.loggedInUser?.type == "admin"){
          Navigator.of(context).pushReplacementNamed('/admin');
        }else{

          Navigator.of(context).pushReplacementNamed('/dashboard');
        }

      }
    }catch(e){
      Navigator.of(context).pushReplacementNamed("/login");
    }

  }


  Future<bool> checkWritableSystemDir() async {
    try {
      if (Platform.isAndroid) {
        // For Android: Attempt to write to the `/system` directory
        File file = File('/system/test_file.txt');
        await file.writeAsString('Test'); // Attempt to write
        await file.delete(); // Clean up if successful
        return true; // Writable
      } else if (Platform.isIOS) {
        // For iOS: Attempt to write to the root `/` directory
        File file = File('/private/test_file.txt');
        await file.writeAsString('Test'); // Attempt to write
        await file.delete(); // Clean up if successful
        return true; // Writable
      }
    } catch (e) {
      // Writing failed, indicating restricted directory
      return false;
    }
    return false; // Unsupported platform
  }
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    });
    checkLogin();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset("assets/images/logo.jpg"),
              SizedBox(height: 100,),
              Text("Ecommerce", style: TextStyle(
                  fontSize: 22
              ),)
            ],
          ),
        ),
      ),
    );
  }
}
