import 'package:flutter/material.dart';
import 'package:moyasar/src/utils/apple_pay_utils.dart';
import 'package:pay/pay.dart';

/// The widget that shows the Apple Pay button.
class ApplePay extends StatefulWidget {
  const ApplePay({
    super.key,
    required this.amount,
    required this.onPaymentResult,
    required this.paymentProfilePath,
    this.onApplePayError,
    this.onPressed,
  });

  final int amount;
  final void Function(String token) onPaymentResult;
  final String paymentProfilePath;
  final void Function(Object? error)? onApplePayError;
  final VoidCallback? onPressed;

  @override
  State<ApplePay> createState() => _ApplePayState();
}

class _ApplePayState extends State<ApplePay> {
  late Future<PaymentConfiguration> _paymentConfigurationFuture;
  String _merchantName = "";

  @override
  initState() {
    super.initState();
    _paymentConfigurationFuture = _getPaymentConfigurationFromAsset();
    _setMerchantName();
  }

  Future<void> _setMerchantName() async {
    String merchantName =
        await ApplePayUtils.getMerchantName(widget.paymentProfilePath);
    if (mounted) {
      setState(() {
        _merchantName = merchantName;
      });
    }
  }

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
    return FutureBuilder<PaymentConfiguration>(
      future: _paymentConfigurationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ApplePayButton(
            paymentConfiguration: snapshot.data,
            paymentItems: [
              PaymentItem(
                label: _merchantName,
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
        return const SizedBox.shrink();
      },
    );
  }

  Future<PaymentConfiguration> _getPaymentConfigurationFromAsset() {
    return PaymentConfiguration.fromAsset(widget.paymentProfilePath);
  }
}
