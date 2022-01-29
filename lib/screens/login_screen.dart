import 'package:flutter/material.dart';

import '/screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  var _isLoading = false;

  void _submit() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Center(
        child: Container(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
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
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _emailInput(),
                    const SizedBox(
                      height: 30,
                    ),
                    _passwordInput(),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {},
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
                        _submitButton(_isLoading, _submit),
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
    );
  }
}

Widget _emailInput() {
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
    ),
  );
}

Widget _passwordInput() {
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
    ),
  );
}

Widget _submitButton(_isLoading, _submit) {
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
