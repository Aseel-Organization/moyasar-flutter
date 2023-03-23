import 'package:flutter/material.dart';

import 'package:moyasar/moyasar.dart';
import 'package:moyasar/src/moyasar.dart';

import 'package:moyasar/src/models/card_form_model.dart';
import 'package:moyasar/src/models/payment_request.dart';
import 'package:moyasar/src/models/sources/card/card_request_source.dart';

import 'package:moyasar/src/widgets/three_d_s_webview.dart';

/// The widget that shows the Credit Card form and manages the 3DS step.
class CreditCardButton extends StatefulWidget {
  const CreditCardButton(
      {super.key,
      this.onPressed,
      required this.cardData,
      required this.config,
      required this.onPaymentResult,
      this.buttonTitle,
      this.buttonStyle,
      this.showLoading = true,
      this.locale = const Localization.en()});

  final Function(bool isLoading)? onPressed;
  final Function onPaymentResult;
  final PaymentConfig config;
  final CardFormModel cardData;
  final Localization locale;
  final String? buttonTitle;
  final ButtonStyle? buttonStyle;
  final bool showLoading;

  @override
  State<CreditCardButton> createState() => _CreditCardButtonState();
}

class _CreditCardButtonState extends State<CreditCardButton> {
  bool _isSubmitting = false;

  void _saveForm() async {
    final source = CardPaymentRequestSource(widget.cardData);
    final paymentRequest = PaymentRequest(widget.config, source);

    setState(() => _isSubmitting = true);
    widget.onPressed?.call(_isSubmitting);

    final result = await Moyasar.pay(
        apiKey: widget.config.publishableApiKey,
        paymentRequest: paymentRequest);

    setState(() => _isSubmitting = false);
    widget.onPressed?.call(_isSubmitting);
    if (result is! PaymentResponse ||
        result.status != PaymentStatus.initiated) {
      widget.onPaymentResult(result);
      return;
    }

    final String transactionUrl =
        (result.source as CardPaymentResponseSource).transactionUrl;

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            maintainState: false,
            builder: (context) => ThreeDSWebView(
                transactionUrl: transactionUrl,
                callbackUrl: widget.config.callbackUrl,
                on3dsDone: (String status, String message) async {
                  if (status == PaymentStatus.paid.name) {
                    result.status = PaymentStatus.paid;
                  } else {
                    result.status = PaymentStatus.failed;
                    (result.source as CardPaymentResponseSource).message =
                        message;
                  }

                  Navigator.pop(context);
                  widget.onPaymentResult(result);
                })),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isSubmitting ? () {} : _saveForm,
      style: widget.buttonStyle,
      child: Row(
        children: [
          Text(widget.buttonTitle ?? 'Pay'),
          if (_isSubmitting && widget.showLoading) ...[
            const SizedBox(
              width: 10,
            ),
            const CircularProgressIndicator.adaptive()
          ],
        ],
      ),
    );
  }
}