import 'package:flutter/material.dart';

enum Step { email, password }

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, _setState) {
        Step step = Step.email;
        return Dialog(
          backgroundColor: Theme.of(context).primaryColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'שחזור סיסמא',
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
