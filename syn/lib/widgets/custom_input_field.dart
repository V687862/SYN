import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final String hint;
  final void Function(String) onSaved;
  final String? Function(String?)? validator;
  final String? initialValue;
  final TextEditingController? controller;

  const CustomInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.onSaved,
    this.validator,
    this.initialValue,
    this.controller,
  }) : assert(
          !(controller != null && initialValue != null),
          'Cannot provide both a controller and an initialValue',
        );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: theme.colorScheme.secondary.withOpacity(0.8),
              fontSize: 14,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: controller,
            initialValue: controller == null ? initialValue : null,
            onSaved: (value) => onSaved(value ?? ''),
            validator: validator,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Colors.black,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withOpacity(.12), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: theme.colorScheme.primary.withOpacity(.6), width: 1),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: theme.colorScheme.error, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: theme.colorScheme.error, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
