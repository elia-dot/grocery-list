import 'package:flutter/material.dart';
import 'package:grocery_list/providers/auth.dart';
import 'package:provider/provider.dart';

import '/screens/login_screen.dart';

class SignupScreen extends StatefulWidget {
  static const routeName = '/signup';
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  Map<String, String> formData = {
    "name": '',
    "email": '',
    "password": '',
  };

  var _isLoading = false;
  final _passwordController = TextEditingController();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Auth>(context, listen: false).signup(
        formData['name']!,
        formData['email']!,
        formData['password']!,
      );
    } catch (e) {
      print(e);
    }
    setState(() {
      _isLoading = false;
    });
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
          child: Container(
            width: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  child: CircleAvatar(
                    child: Icon(
                      Icons.person_add_outlined,
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
                      _userInput(formData),
                      const SizedBox(
                        height: 30,
                      ),
                      _emailInput(formData),
                      const SizedBox(
                        height: 30,
                      ),
                      _passwordInput(formData, _passwordController),
                      const SizedBox(
                        height: 30,
                      ),
                      _confirmPasswordInput(_passwordController),
                      const SizedBox(
                        height: 30,
                      ),
                      _submitButton(_isLoading, _submit),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacementNamed(LoginScreen.routeName);
                  },
                  child: const Text(
                    'התחבר לחשבון שלך',
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

Widget _userInput(formData) {
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
      decoration: const InputDecoration(
        labelText: 'שם משתמש',
        suffixIcon: Icon(
          Icons.person_outline_outlined,
          color: Colors.indigo,
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'נא הכנס שם משתמש';
        }
        return null;
      },
      onSaved: (value) {
        formData['name'] = value;
      },
    ),
  );
}

Widget _emailInput(formData) {
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
      decoration: const InputDecoration(
        labelText: 'אימייל',
        suffixIcon: Icon(
          Icons.email_outlined,
          color: Colors.indigo,
        ),
      ),
      validator: (value) {
        if (value!.isEmpty || !value.contains('@')) {
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

Widget _passwordInput(formData, _passwordController) {
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
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'סיסמא',
        suffixIcon: Icon(
          Icons.vpn_key_outlined,
          color: Colors.indigo,
        ),
      ),
      controller: _passwordController,
      validator: (value) {
        if (value!.isEmpty || value.length < 6) {
          return 'נא הכנב סיסמא עם לפחות 6 תווים';
        }
        return null;
      },
      onSaved: (value) {
        formData['password'] = value;
      },
    ),
  );
}

Widget _confirmPasswordInput(_passwordController) {
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
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'אשר סיסמא',
        suffixIcon: Icon(
          Icons.vpn_key_outlined,
          color: Colors.indigo,
        ),
      ),
      validator: (value) {
        if (value! != _passwordController.text) {
          return 'סיסמאות לא תואמות';
        }
        return null;
      },
    ),
  );
}

Widget _submitButton(bool _isLoading, Function _submit) {
  return ElevatedButton(
    onPressed: _isLoading ? null : () => _submit(),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'הירשם',
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
  );
}
