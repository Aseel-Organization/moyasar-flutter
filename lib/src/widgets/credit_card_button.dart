import 'package:flutter/material.dart';

import 'package:moyasar/moyasar.dart';
import 'package:moyasar/src/moyasar.dart';

import 'package:moyasar/src/models/payment_request.dart';
import 'package:moyasar/src/models/sources/card/card_request_source.dart';

/// The widget that shows the Credit Card form and manages the 3DS step.
class CreditCardButton extends StatefulWidget {
  const CreditCardButton({
    super.key,
    this.onPressed,
    required this.cardData,
    required this.config,
    required this.onPaymentResult,
    this.onPaymentError,
    this.buttonTitle,
    this.buttonStyle,
    this.showLoading = true,
    this.locale = const Localization.en(),
  });

  final void Function(bool isLoading)? onPressed;
  final void Function(PaymentResponse paymentResponse) onPaymentResult;
  final void Function(dynamic error)? onPaymentError;
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

  void _pay() async {
    final CardPaymentRequestSource source =
        CardPaymentRequestSource(widget.cardData);
    final PaymentRequest paymentRequest = PaymentRequest(
      widget.config,
      source,
    );

    setState(() => _isSubmitting = true);
    widget.onPressed?.call(_isSubmitting);

    final dynamic result = await Moyasar.pay(
      apiKey: widget.config.publishableApiKey,
      paymentRequest: paymentRequest,
    );

    setState(() => _isSubmitting = false);
    widget.onPressed?.call(_isSubmitting);
    _handlePaymentResponse(result);
  }

  void _handlePaymentResponse(dynamic result) {
    if (result is! PaymentResponse ||
        result.status != PaymentStatus.initiated) {
      widget.onPaymentError?.call(result);
      return;
    }
    if (result.source is CardPaymentResponseSource) {
      final String transactionUrl =
          (result.source as CardPaymentResponseSource).transactionUrl;
      if (mounted) {
        _openThreeDSecure(
          result,
          transactionUrl,
        );
      }
    }
  }

  void _openThreeDSecure(
    PaymentResponse result,
    String transactionUrl,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        maintainState: false,
        builder: (context) => ThreeDSWebView(
          transactionUrl: transactionUrl,
          callbackUrl: widget.config.callbackUrl,
          on3dsDone: (
            String? status,
            String? message,
          ) =>
              _on3dsDone(
            result,
            status,
            message,
          ),
        ),
      ),
    );
  }

  void _on3dsDone(
    PaymentResponse result,
    String? status,
    String? message,
  ) {
    if (status == PaymentStatus.paid.name) {
      result.status = PaymentStatus.paid;
    } else {
      result.status = PaymentStatus.failed;
      if (result.source is CardPaymentResponseSource) {
        (result.source as CardPaymentResponseSource).message = message;
      }
    }

    Navigator.pop(context);
    widget.onPaymentResult(result);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isSubmitting ? () {} : _pay,
      style: widget.buttonStyle,
      child: Row(
        children: [
          Text(widget.buttonTitle ?? 'Pay'),
          if (_isSubmitting && widget.showLoading) ...[
            const SizedBox(
              width: 10,
            ),
            const CircularProgressIndicator.adaptive(),
          ],
        ],
      ),
    );
  }
}
