import 'package:flutter/material.dart';
import 'package:moyasar/src/widgets/network_icons.dart';

class CreditFormTheme {
  static InputDecoration buildInputDecoration({
    required String hintText,
    bool addNetworkIcons = false,
  }) {
    return InputDecoration(
      suffixIcon: addNetworkIcons ? const NetworkIcons() : null,
      hintText: hintText,
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[400]!),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[600]!),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    );
  }
}
