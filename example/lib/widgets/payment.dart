import 'dart:convert';

import 'package:coffee_flutter/models/apple_pay_configuration.dart';
import 'package:flutter/material.dart';
import 'package:moyasar/moyasar.dart';

class PaymentMethods extends StatefulWidget {
  final PaymentConfig paymentConfig;
  final void Function(String token) onApplePayResult;
  final void Function(PaymentResponse paymentResponse) onPaymentResult;

  const PaymentMethods({
    super.key,
    required this.paymentConfig,
    required this.onApplePayResult,
    required this.onPaymentResult,
  });

  @override
  State<PaymentMethods> createState() => _PaymentMethodsState();
}

class _PaymentMethodsState extends State<PaymentMethods> {
  CardFormModel? _cardData;
  bool _checkValidation = false;
  bool _isValid = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ApplePay(
            displayName: 'Coffee',
            paymentConfiguration: PaymentConfiguration.fromJsonString(
              jsonEncode(
                const ApplePayConfiguration(
                  merchantIdentifier: 'merchant.mysr.fghurayri',
                  displayName: 'Aseel',
                ),
              ),
            ),
            onPaymentResult: widget.onApplePayResult,
            amount: 10,
          ),
        ),
        const Text("or"),
        CreditCard(
          config: widget.paymentConfig,
          onPaymentResult: widget.onPaymentResult,
        ),
        CustomCreditCard(
          checkValidation: _checkValidation,
          onCreditCardFormChange: _onCreditCardFormChange,
        ),
        ElevatedButton(
          onPressed: _setCheckValidation,
          child: const Text('book'),
        ),
        if (_isValid && _cardData != null)
          CreditCardButton(
            cardData: _cardData!,
            config: widget.paymentConfig,
            onPaymentResult: widget.onPaymentResult,
          ),
      ],
    );
  }

  void _setCheckValidation() {
    setState(() {
      _checkValidation = true;
    });
  }

  void _onCreditCardFormChange(CardFormModel cardData, bool isValid) {
    if (isValid) {
      setState(() {
        _cardData = cardData;
      });
    }
    setState(() {
      _isValid = isValid;
    });
  }
}
