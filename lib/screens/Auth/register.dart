import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


import '../../main.dart';
import '../homepage.dart';
import 'login.dart';

// ignore: must_be_immutable
class RegisterPage extends StatelessWidget {
  static const String idScreen = "register";

  TextEditingController txtName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPhone = TextEditingController();
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
                " Register as a Rider",
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
                      controller: txtName,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          labelText: "Name",
                          labelStyle:
                              TextStyle(color: Colors.grey, fontSize: 10.0)),
                      style: TextStyle(fontSize: 14.0),
                    ),
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
                      controller: txtPhone,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                          labelText: "Phone",
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
                        if (txtName.text.length < 4) {
                          displayMessage(
                              context, 'Name cannot be less than 4 Character');
                        } else if (!txtEmail.text.contains('@')) {
                          displayMessage(context, 'Email Address is not Valid');
                        } else if (txtPhone.text.isEmpty) {
                          displayMessage(context, 'Phone Number is mandatory');
                        } else if (txtPassword.text.length < 4) {
                          displayMessage(context,
                              'Password must be at least 6 Characters');
                        }else{
                           registerNewUser(context);
                        }
                       
                      },
                      color: Colors.yellow,
                      textColor: Colors.white,
                      child: Container(
                        height: 50.0,
                        child: Center(
                          child: Text(
                            "Create an Account",
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
                        context, LoginPage.idScreen, (route) => false);
                  },
                  child: Text(
                    "Already have an Account? Login Here.",
                  ))
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  void registerNewUser(BuildContext context) async {
    final User firebaseUser = (await _firebaseAuth
            .createUserWithEmailAndPassword(
                email: txtEmail.text, password: txtPassword.text)
            .catchError((err) {
              displayMessage(context, "Error: $err");
            }))
        .user;
    if (firebaseUser != null) {
      //save user info to firebase database
      Map userDataMap = {
        "name" : txtName.text.trim(),
        "email": txtEmail.text.trim(),
        "phone":txtPhone.text.trim(),
      };
       usersRef.child(firebaseUser.uid).set(userDataMap);
       displayMessage(context, "Congratulations, Your Account has be created");
       Navigator.pushNamedAndRemoveUntil(context, MyHomePage.idScreen, (route) => false);
    } else {
      displayMessage(context, "New User Account could not be created");
    }
  }
}

displayMessage(BuildContext context, String message) {
  Fluttertoast.showToast(msg: message);
}
