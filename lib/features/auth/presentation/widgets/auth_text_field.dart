import 'package:finalyearproject/features/auth/presentation/theme/auth_theme.dart';
import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.iconAsset,
    this.icon,
    this.suffix,
    this.validator,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? iconAsset;
  final IconData? icon;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  Widget? _buildPrefix() {
    if (iconAsset != null) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Image.asset(
          iconAsset!,
          width: 20,
          height: 20,
          color: AuthTheme.darkBlue,
          errorBuilder: (_, __, ___) => Icon(
            icon ?? Icons.circle_outlined,
            color: AuthTheme.darkBlue,
            size: 20,
          ),
        ),
      );
    }
    if (icon != null) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(icon, color: AuthTheme.darkBlue, size: 20),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AuthTheme.fieldLabel()),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          style: const TextStyle(color: AuthTheme.darkBlue),
          decoration: AuthTheme.pillDecoration(
            hint: hint ?? label,
            prefixIcon: _buildPrefix(),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

class AuthDropdownField<T> extends StatelessWidget {
  const AuthDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AuthTheme.fieldLabel()),
        const SizedBox(height: 4),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: AuthTheme.pillDecoration(hint: label),
          dropdownColor: Colors.white,
          style: const TextStyle(color: AuthTheme.darkBlue),
        ),
      ],
    );
  }
}
