import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:easy_localization/easy_localization.dart';

enum AuthMode { signup, login }

class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  void checkAuth() async {
    final result = FirebaseAuth.instance.currentUser;
    var user = await FirebaseFirestore.instance
        .collection('users')
        .doc(result?.uid)
        .get();

    if (user.exists) {
      Navigator.of(context).pushReplacementNamed('/main_controller');
    } else if (result != null) {
      Navigator.of(context).pushReplacementNamed('/register_info');
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
        title: Text('title'.tr()),
        centerTitle: true,
      ),
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
  AuthMode _authMode = AuthMode.login;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  final _passwordController = TextEditingController();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    if (_authMode == AuthMode.login) {
      try {
        await _firebaseAuth.signInWithEmailAndPassword(
            email: _authData['email'] as String,
            password: _authData['password'] as String);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          Fluttertoast.showToast(
            msg: 'userNotFound'.tr(),
            backgroundColor: Color.fromARGB(210, 37, 37, 37),
          );
        } else if (e.code == 'wrong-password') {
          Fluttertoast.showToast(
            msg: 'incorrectPw'.tr(),
            backgroundColor: Color.fromARGB(210, 37, 37, 37),
          );
        }
        return;
      }
      Navigator.of(context).popAndPushNamed('/main_controller');
    } else {
      try {
        await _firebaseAuth.createUserWithEmailAndPassword(
            email: _authData['email'] as String,
            password: _authData['password'] as String);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          Fluttertoast.showToast(
            msg: 'emailTaken'.tr(),
            backgroundColor: Color.fromARGB(210, 37, 37, 37),
          );
          return;
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'error'.tr(),
          backgroundColor: Color.fromARGB(210, 37, 37, 37),
        );
        return;
      }
      Navigator.of(context).popAndPushNamed('/register_info');
    }
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.login) {
      setState(() {
        _authMode = AuthMode.signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.login;
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
        height: 330,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.signup ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'email'.tr()),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value!) ==
                        false) {
                      return 'emailError'.tr();
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value as String;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'password'.tr()),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 6) {
                      return 'weakPw'.tr();
                    }
                  },
                  onSaved: (value) {
                    _authData['password'] = value as String;
                  },
                ),
                if (_authMode == AuthMode.signup)
                  TextFormField(
                    enabled: _authMode == AuthMode.signup,
                    decoration: InputDecoration(labelText: 'pwAgain'.tr()),
                    obscureText: true,
                    validator: _authMode == AuthMode.signup
                        ? (value) {
                            if (value != _passwordController.text) {
                              return 'pwNotMatch'.tr();
                            }
                          }
                        : null,
                  ),
                SizedBox(
                  height: 20,
                ),
                RaisedButton(
                  child: Text(_authMode == AuthMode.login
                      ? 'login'.tr().toUpperCase()
                      : 'register'.tr().toUpperCase()),
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
                  child: Text(_authMode == AuthMode.login
                      ? 'register'.tr().toUpperCase()
                      : 'login'.tr().toUpperCase()),
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
