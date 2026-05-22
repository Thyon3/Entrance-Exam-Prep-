import 'package:finalyearproject/features/auth/presentation/theme/auth_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Six OTP boxes styled like nexatracker (compact row, green when filled).
class AuthOtpInput extends StatelessWidget {
  const AuthOtpInput({
    super.key,
    required this.controllers,
    this.onCompleted,
  });

  final List<TextEditingController> controllers;
  final VoidCallback? onCompleted;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) => _OtpBox(
            controller: controllers[i],
            onChanged: (v) {
              if (v.isNotEmpty && i < 5) {
                FocusScope.of(context).nextFocus();
              }
              if (controllers.every((c) => c.text.isNotEmpty)) {
                onCompleted?.call();
              }
            },
          )),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final filled = controller.text.isNotEmpty;
    final borderColor = filled ? AuthTheme.green : AuthTheme.fieldBorder;
    final textColor = filled ? AuthTheme.green : AuthTheme.darkBlue;

    return SizedBox(
      width: 44,
      height: 56,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          fontSize: 28,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: borderColor, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: borderColor, width: 2),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
