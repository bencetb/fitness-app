import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  void checkAuth() async {
    final result = FirebaseAuth.instance.currentUser;
    if (result != null) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness alkalmazás'),
        centerTitle: true,
      ),
      //resizeToAvoidBottomInset: true,
      body: Stack(
        children: <Widget>[
          Container(
            height: deviceSize.height,
            width: deviceSize.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  flex: deviceSize.width > 600 ? 2 : 1,
                  child: AuthCard(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({Key? key}) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  final _passwordController = TextEditingController();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    if (_authMode == AuthMode.Login) {
      try {
        await _firebaseAuth.signInWithEmailAndPassword(
            email: _authData['email'] as String,
            password: _authData['password'] as String);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          Fluttertoast.showToast(
            msg: "Ehhez az e-mail címhez nem tartozik regisztrált felhasználő!",
            backgroundColor: Color.fromARGB(210, 37, 37, 37),
          );
        } else if (e.code == 'wrong-password') {
          Fluttertoast.showToast(
            msg: "Helytelen jelszó!",
            backgroundColor: Color.fromARGB(210, 37, 37, 37),
          );
        }
        return;
      }
      Navigator.of(context).popAndPushNamed('/home');
    } else {
      try {
        await _firebaseAuth.createUserWithEmailAndPassword(
            email: _authData['email'] as String,
            password: _authData['password'] as String);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          Fluttertoast.showToast(
            msg: "Ez az e-mail cím már foglalt!",
            backgroundColor: Color.fromARGB(210, 37, 37, 37),
          );
          return;
        }
      } catch (e) {
        print(e);
        return;
      }
      Navigator.of(context).popAndPushNamed('/register_info');
    }
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        height: _authMode == AuthMode.Signup ? 320 : 260,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value!) ==
                        false) {
                      return 'Helytelen e-mail cím!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value as String;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Jelszó'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 6) {
                      return 'A jelszó legalább 6 karakter kell, hogy legyen!';
                    }
                  },
                  onSaved: (value) {
                    _authData['password'] = value as String;
                  },
                ),
                if (_authMode == AuthMode.Signup)
                  TextFormField(
                    enabled: _authMode == AuthMode.Signup,
                    decoration: InputDecoration(labelText: 'Jelszó újra'),
                    obscureText: true,
                    validator: _authMode == AuthMode.Signup
                        ? (value) {
                            if (value != _passwordController.text) {
                              return 'A jelszavak nem egyeznek!';
                            }
                          }
                        : null,
                  ),
                SizedBox(
                  height: 20,
                ),
                RaisedButton(
                  child: Text(_authMode == AuthMode.Login
                      ? 'BEJELENTKEZÉS'
                      : 'REGISZTRÁCIÓ'),
                  onPressed: _submit,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                  color: Theme.of(context).primaryColor,
                  textColor: Theme.of(context).primaryTextTheme.button!.color,
                ),
                FlatButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'REGISZTRÁCIÓ' : 'BEJELENTKEZÉS'}'),
                  onPressed: _switchAuthMode,
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
