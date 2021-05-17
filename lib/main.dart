import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'DataHandler/appData.dart';
import 'screens/Auth/register.dart';
import 'screens/auth/login.dart';
import 'screens/homepage.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

DatabaseReference usersRef = FirebaseDatabase.instance.reference().child("users");

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:(context) => AppData(),
          child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Taxi Rider App',
        theme: ThemeData(
          // fontFamily: "Signatra",
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: FirebaseAuth.instance.currentUser == null ? LoginPage.idScreen : MyHomePage.idScreen,
        routes: {
          RegisterPage.idScreen:(context) => RegisterPage(),
          LoginPage.idScreen:(context) => LoginPage(),
          MyHomePage.idScreen:(context) => MyHomePage()
        },
      ),
    );
  }
}
