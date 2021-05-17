import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uber_clone/widget/progressdialog.dart';


import '../../main.dart';
import '../homepage.dart';
import 'register.dart';

// ignore: must_be_immutable
class LoginPage extends StatelessWidget {
  static const String idScreen = "login";

  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 35.0,
              ),
              Image(
                image: AssetImage("assets/images/logo.png"),
                width: 390.0,
                height: 250.0,
                alignment: Alignment.center,
              ),
              SizedBox(
                height: 1.0,
              ),
              Text(
                " Login as a Rider",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 1.0,
                    ),
                    TextField(
                      controller: txtEmail,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle:
                              TextStyle(color: Colors.grey, fontSize: 10.0)),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(
                      height: 1.0,
                    ),
                    TextField(
                      controller: txtPassword,
                      obscureText: true,
                      decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle:
                              TextStyle(color: Colors.grey, fontSize: 10.0)),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    RaisedButton(
                      onPressed: () {
                        if (!txtEmail.text.contains('@')) {
                          displayMessage(context, 'Email Address is not Valid');
                        } else if (txtPassword.text.length < 4) {
                          displayMessage(context,
                              'Password must be at least 6 Characters');
                        } else {
                          loginUser(context);
                        }
                      },
                      color: Colors.yellow,
                      textColor: Colors.white,
                      child: Container(
                        height: 50.0,
                        child: Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                                fontSize: 18.0, fontFamily: "Brand Bold"),
                          ),
                        ),
                      ),
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(24.0),
                      ),
                    )
                  ],
                ),
              ),
              FlatButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, RegisterPage.idScreen, (route) => false);
                  },
                  child: Text(
                    "Do not have an Account? Register Here.",
                  ))
            ],
          ),
        ),
      ),
    );
  }

// Come back to Catch Auth Errors
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Future<void> loginUser(context) async {
    showDialog(context: context,
    barrierDismissible: false,
    builder: (BuildContext context){
      return ProgressDialog(message: "Authenticating, Please Wait...");
    }
    
    );
    try {
      final User firebaseUser = (await _firebaseAuth
              .signInWithEmailAndPassword(
                  email: txtEmail.text, password: txtPassword.text)
              .catchError((err) {
                Navigator.pop(context);
        displayMessage(context, "Error: $err");
        return null;
      }).catchError((onError) {
        Navigator.pop(context);
        displayMessage(context, "Errors: $onError");
          return null;
      }))
          .user;
      if (firebaseUser != null) {
        //save user info to firebase database

        usersRef.child(firebaseUser.uid).once().then((DataSnapshot snapshot) {
          if (snapshot.value != null) {
            Navigator.pushNamedAndRemoveUntil(
                context, MyHomePage.idScreen, (route) => false);
            displayMessage(context, "Successfully Logged In");
          } else {
            Navigator.pop(context);
            _firebaseAuth.signOut();
            displayMessage(context, "No User Found, Please Create New Account");
          }
        });
      } else {
        Navigator.pop(context);
         _firebaseAuth.signOut();
        displayMessage(context, "Error Occur, Could Not be signed-in");
      }
    } on PlatformException catch (e) {
      Navigator.pop(context);
      print(e.message);
    } on FirebaseAuthException catch (e) {
      // Your logic for Firebase related exceptions
      Navigator.pop(context);
      print("firebase $e");
    } on Exception catch (e) {
      Navigator.pop(context);
      print(e);
      // if (e.code == 'user-not-found') {
      //   displayMessage(context, 'No user found for that email.');
      // } else if (e.code == 'wrong-password') {
      //   displayMessage(context, 'Wrong password provided for that user.');
      // }
    }
  }
}
