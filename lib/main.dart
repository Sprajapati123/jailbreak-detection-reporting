import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jailbreak_detection/screens/auth/login_screen.dart';
import 'package:jailbreak_detection/screens/auth/register_screen.dart';
import 'package:jailbreak_detection/services/local_notification_service.dart';
import 'package:jailbreak_detection/viewmodels/auth_viewmodel.dart';
import 'package:jailbreak_detection/viewmodels/category_viewmodel.dart';
import 'package:jailbreak_detection/viewmodels/global_ui_viewmodel.dart';
import 'package:jailbreak_detection/viewmodels/product_viewmodel.dart';
import 'package:overlay_kit/overlay_kit.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  NotificationService.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GlobalUIViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => CategoryViewModel()),
        ChangeNotifierProvider(create: (_) => ProductViewModel()),
      ],
      child: OverlayKit(
        child: Consumer<GlobalUIViewModel>(builder: (context, loader, child) {
          // if (loader.isLoading) {
          //   OverlayLoadingProgress.start();
          // } else {
          //   OverlayLoadingProgress.stop();
          // }
          return MaterialApp(
            title: 'Flutter Demo',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              // This is the theme of your application.
              //
              // Try running your application with "flutter run". You'll see the
              // application has a blue toolbar. Then, without quitting the app, try
              // changing the primarySwatch below to Colors.green and then invoke
              // "hot reload" (press "r" in the console where you ran "flutter run",
              // or simply save your changes to "hot reload" in a Flutter IDE).
              // Notice that the counter didn't reset back to zero; the application
              // is not restarted.
              fontFamily: "Poppins",
              primarySwatch: Colors.green,
              textTheme: GoogleFonts.aBeeZeeTextTheme(),
            ),
            initialRoute: "/splash",
            routes: {
              "/login": (BuildContext context) => LoginScreen(),
              "/splash": (BuildContext context) => LoginScreen(),
              "/register": (BuildContext context) => RegisterScreen(),

            },
          );
        }),
      ),
    );
  }
}
