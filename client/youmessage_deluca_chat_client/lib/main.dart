import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui/flutter_firebase_ui.dart';
import 'package:uMessage/home.dart';

Future main() async {
  final prefs = await SharedPreferences.getInstance();
  bool skipL = false;
  if (prefs.getString("id") != null && prefs.getString("id").isNotEmpty)
    skipL = true;
  runApp(MyApp(skipLogin: skipL));
}

bool loginNeeded = false;

class MyApp extends StatelessWidget {
  bool skipLogin;
  MyApp({this.skipLogin = true});
  @override
  Widget build(BuildContext context) {
    if (skipLogin)
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'youMessage by DelU - chats',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          buttonTheme: ButtonThemeData(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50))),
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: TextTheme(
            title: TextStyle(color: Colors.black),
            body1: TextStyle(color: Colors.black),
            body2: TextStyle(color: Colors.black),
          ),
          buttonTheme: ButtonThemeData(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50))),
          inputDecorationTheme: InputDecorationTheme(
              hintStyle: TextStyle(color: Colors.black),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black))),
          brightness: Brightness.dark,
        ),
        home: Home(),
      );
    else
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'youMessage by DelU - Welcome',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          buttonTheme: ButtonThemeData(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50))),
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: TextTheme(
            title: TextStyle(color: Colors.black),
            body1: TextStyle(color: Colors.black),
            body2: TextStyle(color: Colors.black),
          ),
          buttonTheme: ButtonThemeData(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50))),
          inputDecorationTheme: InputDecorationTheme(
              hintStyle: TextStyle(color: Colors.black),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black))),
          brightness: Brightness.dark,
        ),
        home: MyLoginPage(),
      );
  }
}

class MyLoginPage extends StatefulWidget {
  MyLoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyLoginPage> {
  _MyHomePageState() {
    _checkCurrentUser();
  }
  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  @override
  void dispose() {
    _listener.cancel();
    super.dispose();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<FirebaseUser> _listener;
  FirebaseUser _currentUser;
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  static const _kFontFam = 'MyFlutterApp';
  static const IconData facebook_circled =
      const IconData(0xe800, fontFamily: _kFontFam);
  static const IconData google = const IconData(0xf1a0, fontFamily: _kFontFam);

  final myController = TextEditingController();

  void _checkCurrentUser() async {
    _currentUser = await _auth.currentUser();
    _currentUser?.getIdToken(refresh: true);
    final prefs = await SharedPreferences.getInstance();
    _listener = _auth.onAuthStateChanged.listen((FirebaseUser user) {
      setState(() {
        _currentUser = user;
        prefs.setString("id", _currentUser.email);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      });
    });
  }

  Future login() async {
    _checkCurrentUser();
    final prefs = await SharedPreferences.getInstance();
    if (_currentUser != null) {
      prefs.setString("id", _currentUser.email);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final idField = TextField(
      obscureText: true,
      style: style,
      controller: myController,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "ID",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.0),
              borderSide: BorderSide(color: Colors.black))),
    );

    final loginButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString("id", myController.text.toLowerCase());
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        },
        child: Text("Login",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
    if (_currentUser == null) {
      return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: SizedBox(
            width: window.physicalSize.width,
            height: window.physicalSize.height,
            child: SignInScreen(
              title: "uMessage - Login",
              header: new Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: new Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Column(
                    children: <Widget>[
                      Text("uMessage - Login",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 35)),
                      SizedBox(
                        height: 10,
                      ),
                      idField,
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            InkWell(
                              child: Icon(
                                facebook_circled,
                                size: 40,
                              ),
                              onTap: () {
                                login();
                              },
                            ),
                            InkWell(
                              child: Icon(
                                google,
                                size: 40,
                              ),
                              onTap: () {
                                login();
                              },
                            ),
                            InkWell(
                              child: Icon(
                                Icons.email,
                                size: 40,
                              ),
                              onTap: () {
                                login();
                              },
                            ),
                            InkWell(
                              child: Icon(
                                Icons.phone,
                                size: 40,
                              ),
                              onTap: () {
                                login();
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      loginButton,
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
              showBar: true,
              // horizontalPadding: 8,
              bottomPadding: 5,
              avoidBottomInset: true,
              color: Colors.white,
              providers: [
                ProvidersTypes.google,
                ProvidersTypes.facebook,
                ProvidersTypes.twitter,
                ProvidersTypes.email
              ],
              twitterConsumerKey: "",
              twitterConsumerSecret: "", horizontalPadding: 12,
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
          body: SingleChildScrollView(
        child: Center(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 155.0,
                    // child: Image.asset(
                    //   Icons.message,
                    //   fit: BoxFit.contain,
                    // ),
                  ),
                  SizedBox(height: 45.0),
                  idField,
                  SizedBox(
                    height: 35.0,
                  ),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        InkWell(
                          child: Icon(
                            facebook_circled,
                            size: 50,
                          ),
                          onTap: () {
                            login();
                          },
                        ),
                        InkWell(
                          child: Icon(
                            google,
                            size: 50,
                          ),
                          onTap: () {
                            login();
                          },
                        ),
                        InkWell(
                          child: Icon(
                            Icons.email,
                            size: 50,
                          ),
                          onTap: () {
                            login();
                          },
                        ),
                        InkWell(
                          child: Icon(
                            Icons.phone,
                            size: 50,
                          ),
                          onTap: () {
                            login();
                          },
                        ),
                      ],
                    ),
                  ),
                  loginButton,
                  SizedBox(
                    height: 15.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ));
    }
  }
}
