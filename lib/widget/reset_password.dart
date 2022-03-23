import 'package:flutter/material.dart';
import 'package:grocery_list/models/fb_exeption.dart';
import 'package:grocery_list/providers/auth.dart';
import 'package:provider/provider.dart';

enum Step { email, sent }

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  String email = '';
  String emailError = '';
  Step step = Step.email;
  var isLoading = false;

  Future<void> sendEmail(String email) async {
    setState(() {
      isLoading = true;
    });
    try {
      await Provider.of<Auth>(context, listen: false).resetPassword(email);
      setState(() {
        isLoading = false;
        step = Step.sent;
      });
    } on FBExeption catch (msg) {
      setState(() {
        isLoading = false;
        emailError = msg.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, _setState) {
        return Dialog(
          backgroundColor: Theme.of(context).primaryColor,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'שחזור סיסמא',
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                  if (step == Step.email)
                    const SizedBox(
                      height: 20,
                    ),
                  if (step == Step.email)
                    const Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        'הכנס את האימייל עימו נרשמת.',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  if (step == Step.email)
                    TextFormField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        errorStyle: const TextStyle(color: Colors.red),
                        errorText: emailError == '' ? null : emailError,
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        errorBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          emailError = '';
                          email = value;
                        });
                      },
                    ),
                  const SizedBox(
                    height: 15,
                  ),
                  if (step == Step.email)
                    ElevatedButton(
                      onPressed: email == ''
                          ? () {}
                          : () {
                              sendEmail(email);
                            },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('שלח אימייל'),
                          if (isLoading)
                            const SizedBox(
                              width: 10,
                            ),
                          if (isLoading)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(),
                            )
                        ],
                      ),
                    ),
                  if (step == Step.sent)
                    const Text(
                      'אימייל נשלח בהצלחה. עקוב אחר ההוראות לאיפוס הסיסמה',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 18,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
