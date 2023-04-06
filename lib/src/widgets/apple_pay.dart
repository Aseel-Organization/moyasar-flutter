import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:moyasar/src/models/apple_pay_configuration.dart';
import 'package:pay/pay.dart';

/// The widget that shows the Apple Pay button.
class ApplePay extends StatefulWidget {
  const ApplePay({
    super.key,
    required this.amount,
    required this.onPaymentResult,
    required this.applePayConfiguration,
    this.onApplePayError,
    this.onPressed,
  });

  final int amount;
  final void Function(String token) onPaymentResult;
  final ApplePayConfiguration applePayConfiguration;
  final void Function(Object? error)? onApplePayError;
  final VoidCallback? onPressed;

  @override
  State<ApplePay> createState() => _ApplePayState();
}

class _ApplePayState extends State<ApplePay> {
  void _onApplePayError(Object? error) {
    widget.onApplePayError?.call(error);
  }

  Future<void> _onApplePayResult(Map<String, dynamic> paymentResult) async {
    try {
      final String token = paymentResult['token'];
      widget.onPaymentResult(token);
    } catch (e) {
      _onApplePayError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ApplePayButton(
      paymentConfiguration: PaymentConfiguration.fromJsonString(
        jsonEncode(widget.applePayConfiguration),
      ),
      paymentItems: [
        PaymentItem(
          label: widget.applePayConfiguration.displayName,
          amount: (widget.amount / 100).toStringAsFixed(2),
        ),
      ],
      type: ApplePayButtonType.inStore,
      onPaymentResult: _onApplePayResult,
      onPressed: widget.onPressed,
      width: MediaQuery.of(context).size.width,
      height: 40,
      onError: _onApplePayError,
      loadingIndicator: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
