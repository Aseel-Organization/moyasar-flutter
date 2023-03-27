import 'package:flutter/material.dart';
import 'package:moyasar/moyasar.dart';

class PaymentMethods extends StatefulWidget {
  final PaymentConfig paymentConfig;
  final Function onPaymentResult;

  const PaymentMethods(
      {super.key, required this.paymentConfig, required this.onPaymentResult});

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
            config: widget.paymentConfig,
            onPaymentResult: widget.onPaymentResult,
          ),
        ),
        const Text("or"),
        CreditCard(
            config: widget.paymentConfig,
            onPaymentResult: widget.onPaymentResult),
        CustomCreditCard(
          checkValidation: _checkValidation,
          onCreditCardFormChange: (cardData, isValid) {
            if (isValid) {
              setState(() {
                _cardData = cardData;
              });
            }
            setState(() {
              _isValid = isValid;
            });
          },
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _checkValidation = true;
            });
            debugPrint('${_cardData != null}');
          },
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
}
