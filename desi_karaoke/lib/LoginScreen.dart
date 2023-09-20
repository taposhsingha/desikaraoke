import 'package:desi_karaoke_lite/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:firebase_auth_ui/providers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_signin_button/button_builder.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatelessWidget {
  static const MethodChannel _channel = const MethodChannel('firebase_auth_ui');
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Login",
      home: Scaffold(
        body: LoginPage(),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({
    Key key,
  }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var nameEditingController = TextEditingController();
  var globalKey = GlobalKey();
  DatabaseReference userRef;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Spacer(flex: 3),
            Text(
              "Welcome to",
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              "Desi Karaoke",
              style: Theme.of(context).textTheme.headline3,
            ),
            Spacer(flex: 4),
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Please, sign in to continue:",
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                ),
                // SignInButton(
                //   Buttons.Google,
                //   onPressed: () {
                //     _handleSignIn();
                //   }, // default: false
                // ),
                // SignInButtonBuilder(
                //   text: "Sign In with Phone",
                //   backgroundColor: Colors.blueGrey[700],
                //   onPressed: () {},
                //   icon: Icons.phone,
                // ),
                ElevatedButton(child: Text("Get Started"),onPressed: launchNativeSignInUi,)
              ],
            ),
            Spacer(
              flex: 1,
            )
          ],
        ),
      ),
    );
  }

  void _handleSignIn(user) async {
    // final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    // final GoogleSignInAuthentication googleAuth =
    //     await googleUser.authentication;

    // final AuthCredential credential = GoogleAuthProvider.getCredential(
    //   accessToken: googleAuth.accessToken,
    //   idToken: googleAuth.idToken,
    // );

    // final User user = (await _auth.signInWithCredential(credential)).user;
    // print(user.uid);
    userRef = FirebaseDatabase.instance.reference().child("users/${user.uid}");

    userRef?.once()?.then((data) {
      if (data.value == null) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Your Full Name:"),
              content: Form(
                key: globalKey,
                child: TextFormField(
                  textCapitalization: TextCapitalization.words,
                  maxLines: 1,
                  controller: nameEditingController,
                  validator: (val) {
                    print("validating: $val");
                    if (val.length < 2) {
                      return "Name too short";
                    } else
                      return null;
                  },
                  decoration: InputDecoration(
                      hintMaxLines: 1, hintText: "Firstname Lastname"),
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context);
                    _auth.signOut();
                  },
                ),
                FlatButton(
                  child: Text("Confirm"),
                  onPressed: submitName,
                ),
              ],
            );
          },
        );
      } else {
        onSuccessfulLogin();
      }
    });
  }

  void onSuccessfulLogin() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => MyApp()));
  }

  @override
  void dispose() {
    nameEditingController.dispose();
    super.dispose();
  }

  void submitName() {
    print("submit is pressed");
    FormState state = globalKey.currentState;
    if (state.validate()) {
      var signUpData = Map<String, dynamic>();
      signUpData['name'] = nameEditingController.text;
      signUpData['signuptime'] = ServerValue.timestamp;
      signUpData['currenttime'] = ServerValue.timestamp;
      userRef?.set(signUpData)?.whenComplete(() {
        Navigator.of(context, rootNavigator: true).pop();
        onSuccessfulLogin();
      })?.catchError((error) {
        print("Aight imma head out");
        _auth.signOut();
      });
    }
  }

  launchNativeSignInUi() {
    FirebaseAuthUi.instance().launchAuth([
          // AuthProvider.email(),
          // Google ,facebook, twitter and phone auth providers are commented because this example
          // isn't configured to enable them. Please follow the README and uncomment
          // them if you want to integrate them in your project.

          AuthProvider.google(),
          // AuthProvider.facebook(),
          // AuthProvider.twitter(),
          AuthProvider.phone(),
        ]).then((firebaseUser) {
          _handleSignIn(firebaseUser);
          
        }).catchError((error) {
          if (error is PlatformException) {
            setState(() {
              if (error.code == FirebaseAuthUi.kUserCancelledError) {
                // _error = "User cancelled login";
              } else {
                // _error = error.message ?? "Unknown error!";
              }
            });
          }
        });
  }
}
