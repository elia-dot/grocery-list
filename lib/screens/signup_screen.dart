import 'package:flutter/material.dart';
import 'package:grocery_list/models/fb_exeption.dart';
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
    "phone": ''
  };

  var _isLoading = false;
  final _passwordController = TextEditingController();

  var _isEmailError = false;
  var _isPasswordError = false;
  var _isConfirmError = false;
  var _isPhoneError = false;

  final FocusNode _emailNode = FocusNode();
  final FocusNode _passwordNode = FocusNode();
  final FocusNode _confirmNode = FocusNode();
  final FocusNode _phoneNode = FocusNode();

  var emailError = "";

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

  void throwConfirmError() {
    setState(() {
      _isConfirmError = true;
    });
  }

  void throwPhoneError() {
    setState(() {
      _isPhoneError = true;
    });
  }

  void removeErrors() {
    setState(() {
      _isConfirmError = false;
      _isEmailError = false;
      _isPasswordError = false;
      _isPhoneError = false;
      emailError = '';
    });
  }

  void setPhone(value) {
    setState(() {
      formData['phone'] = value;
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

    _confirmNode.addListener(() {
      if (_confirmNode.hasFocus) {
        removeErrors();
      }
    });

    _phoneNode.addListener(() {
      if (_phoneNode.hasFocus) {
        removeErrors();
      }
    });
    super.initState();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Auth>(context, listen: false).signup(formData['name']!,
          formData['email']!, formData['password']!, formData['phone']!);
    } on FBExeption catch (msg) {
      setState(() {
        emailError = msg.toString();
      });
    } catch (e) {
      print(e);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
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
                          _passwordController,
                          _isPasswordError,
                          _isConfirmError,
                          throwPasswordError,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        _confirmPasswordInput(
                          _confirmNode,
                          _passwordController,
                          _isConfirmError,
                          throwPasswordError,
                          throwConfirmError,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        _phoneInput(
                            formData, _isPhoneError, throwPhoneError, setPhone),
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
      style: const TextStyle(color: Colors.black),
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

Widget _emailInput(
  formData,
  emailNode,
  isEmailError,
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
      style: const TextStyle(color: Colors.black),
      keyboardType: TextInputType.emailAddress,
      focusNode: emailNode,
      decoration: InputDecoration(
        labelText: 'אימייל',
        errorText: emailError != "" ? emailError : null,
        suffixIcon: Icon(
          Icons.email_outlined,
          color: isEmailError ? Colors.red : Colors.indigo,
        ),
      ),
      validator: (value) {
        if (value!.isEmpty || !value.contains('@')) {
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
  passwordNode,
  _passwordController,
  isPasswordError,
  isConfirmError,
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
      style: const TextStyle(color: Colors.black),
      keyboardType: TextInputType.emailAddress,
      obscureText: true,
      focusNode: passwordNode,
      decoration: InputDecoration(
        labelText: 'סיסמא',
        suffixIcon: Icon(
          Icons.vpn_key_outlined,
          color: isPasswordError || isConfirmError ? Colors.red : Colors.indigo,
        ),
      ),
      controller: _passwordController,
      validator: (value) {
        if (value!.isEmpty || value.length < 6) {
          throwPasswordError();
          return 'נא הכנס סיסמא עם לפחות 6 תווים';
        }
        return null;
      },
      onSaved: (value) {
        formData['password'] = value;
      },
    ),
  );
}

Widget _confirmPasswordInput(
  confirmNode,
  _passwordController,
  isConfirmError,
  throwPasswordError,
  throwConfirmError,
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
      style: const TextStyle(color: Colors.black),
      keyboardType: TextInputType.emailAddress,
      obscureText: true,
      focusNode: confirmNode,
      decoration: InputDecoration(
        labelText: 'אשר סיסמא',
        suffixIcon: Icon(
          Icons.vpn_key_outlined,
          color: isConfirmError ? Colors.red : Colors.indigo,
        ),
      ),
      validator: (value) {
        if (value! != _passwordController.text) {
          throwConfirmError();
          throwPasswordError();
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

Widget _phoneInput(formData, isPhoneError, throwPhoneError, setPhone) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 10,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: TextFormField(
      style: const TextStyle(color: Colors.black),
      keyboardType: TextInputType.number,
      maxLength: 10,
      decoration: InputDecoration(
        counterText: "",
        labelText: "מס' טלפון",
        errorText: formData['phone'].contains('-') ||
                formData['phone'].contains(',') ||
                formData['phone'].contains('.')
            ? 'נא הכנס מספרים בלבד'
            : null,
        suffixIcon: Icon(
          Icons.phone,
          color: isPhoneError ? Colors.red : Colors.indigo,
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          throwPhoneError();
          return 'הכנס מספר טלפון ואפשר לחבריך לשתף עמך רשימות';
        }
        if (value.contains('-') || value.contains(',') || value.contains('.')) {
          throwPhoneError();
          return 'נא הכנס מספרים בלבד';
        }
        return null;
      },
      onChanged: (value) {
        setPhone(value);
      },
    ),
  );
}
