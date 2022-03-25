import 'package:flutter/material.dart';
import 'package:grocery_list/models/fb_exeption.dart';
import 'package:grocery_list/widget/reset_password.dart';
import 'package:provider/provider.dart';

import '/providers/auth.dart';
import '/screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  Map<String, String> formData = {
    "email": '',
    "password": '',
  };

  var _isLoading = false;
  var _isEmailError = false;
  var _isPasswordError = false;

  final FocusNode _emailNode = FocusNode();
  final FocusNode _passwordNode = FocusNode();

  var emailError = "";
  var passwordError = "";

  void throwEmailError() {
    setState(() {
      _isEmailError = true;
    });
  }

  void throwPasswordError() {
    setState(() {
      _isPasswordError = true;
    });
  }

  void removeErrors() {
    setState(() {
      _isEmailError = false;
      _isPasswordError = false;
      emailError = '';
    });
  }

  @override
  void initState() {
    _emailNode.addListener(() {
      if (_emailNode.hasFocus) {
        removeErrors();
      }
    });

    _passwordNode.addListener(() {
      if (_passwordNode.hasFocus) {
        removeErrors();
      }
    });

    super.initState();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Auth>(context, listen: false)
          .login(formData['email']!, formData['password']!);
      setState(() {
        _isLoading = false;
      });
    } on FBExeption catch (msg) {
      if (msg.toString() == 'משתמש לא נמצא') {
        setState(() {
          emailError = msg.toString();
        });
      }
      if (msg.toString() == 'סיסמא לא נכונה') {
        setState(() {
          passwordError = msg.toString();
        });
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircleAvatar(
                    child: Icon(
                      Icons.person_outline_outlined,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 80,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _emailInput(
                        formData,
                        _emailNode,
                        _isEmailError,
                        throwEmailError,
                        emailError,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      _passwordInput(
                        formData,
                        _passwordNode,
                        _isPasswordError,
                        passwordError,
                        throwPasswordError,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (ctx) => const ResetPassword());
                            },
                            child: const Text(
                              'שכחתי סיסמא',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          _submitButton(_isLoading, _submit, formData),
                        ],
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacementNamed(SignupScreen.routeName);
                  },
                  child: const Text(
                    'צור חשבון משתמש חדש',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _emailInput(
  formData,
  _emailNode,
  _isEmailError,
  throwEmailError,
  emailError,
) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 10,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: TextFormField(
      keyboardType: TextInputType.emailAddress,
      focusNode: _emailNode,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: 'אימייל',
        errorText: emailError != "" ? emailError : null,
        suffixIcon: Icon(
          Icons.email_outlined,
          color: _isEmailError ? Colors.red : Colors.indigo,
        ),
      ),
      validator: (value) {
        if (!value!.contains('@')) {
          throwEmailError();
          return 'אימייל לא תקין';
        }
        return null;
      },
      onSaved: (value) {
        formData['email'] = value;
      },
    ),
  );
}

Widget _passwordInput(
  formData,
  _passwordNode,
  _isPasswordError,
  passwordError,
  throwPasswordError,
) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 10,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: TextFormField(
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.black),
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'סיסמא',
        errorText: passwordError != "" ? passwordError : null,
        suffixIcon: Icon(
          Icons.vpn_key_outlined,
          color: _isPasswordError ? Colors.red : Colors.indigo,
        ),
      ),
      onSaved: (value) {
        formData['password'] = value;
      },
    ),
  );
}

Widget _submitButton(_isLoading, _submit, formData) {
  return Expanded(
    child: ElevatedButton(
      onPressed: _isLoading ? null : () => _submit(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'התחבר',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_isLoading)
            const SizedBox(
              width: 20,
            ),
          if (_isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.indigo,
              ),
            )
        ],
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.redAccent),
      ),
    ),
  );
}
