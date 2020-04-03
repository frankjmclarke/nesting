import 'package:flutter/material.dart';
import '../../services/services.dart';

/*
PrimaryButton(
                labelText: 'UPDATE',
                onPressed: () => print('Submit'),
              ),
*/

class PrimaryButton extends StatelessWidget {
  PrimaryButton({this.labelText, this.onPressed});

  final String labelText;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onPressed: onPressed,
      padding: EdgeInsets.all(12),
      color: Palette.primaryButtonColor,
      child: Text(labelText,
          style: TextStyle(color: Palette.primaryButtonTextColor)),
    );
  }
}