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
              fontFamily: 'Orbitron',
              fontSize: 14,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.4),
                  blurRadius: 8.0,
                  spreadRadius: -2.0,
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              initialValue: controller == null ? initialValue : null,
              onSaved: (value) => onSaved(value ?? ''),
              validator: validator,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 18,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface.withOpacity(0.3),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary.withOpacity(0.6),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.colorScheme.secondary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.colorScheme.error,
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.colorScheme.error,
                    width: 2.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
