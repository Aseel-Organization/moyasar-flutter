import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:moyasar/moyasar.dart';
import 'package:moyasar/src/moyasar.dart';

import 'package:moyasar/src/models/payment_request.dart';
import 'package:moyasar/src/models/sources/card/card_request_source.dart';

import 'package:moyasar/src/utils/card_utils.dart';
import 'package:moyasar/src/utils/input_formatters.dart';
import 'package:moyasar/src/utils/themes/credit_form_theme.dart';
import 'package:moyasar/src/widgets/card_form_field.dart';

/// The widget that shows the Credit Card form and manages the 3DS step.
class CreditCard extends StatefulWidget {
  const CreditCard({
    super.key,
    required this.config,
    required this.onPaymentResult,
    this.locale = const Localization.en(),
  });

  final Function onPaymentResult;
  final PaymentConfig config;
  final Localization locale;

  @override
  State<CreditCard> createState() => _CreditCardState();
}

class _CreditCardState extends State<CreditCard> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final CardFormModel _cardData = CardFormModel();

  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  bool isSubmitting = false;

  void _saveForm() async {
    FocusManager.instance.primaryFocus?.unfocus();
    bool isValidForm =
        _formKey.currentState != null && _formKey.currentState!.validate();

    if (!isValidForm) {
      setState(() => _autoValidateMode = AutovalidateMode.onUserInteraction);
      return;
    }

    _formKey.currentState?.save();

    final CardPaymentRequestSource source = CardPaymentRequestSource(_cardData);
    final PaymentRequest paymentRequest = PaymentRequest(
      widget.config,
      source,
    );

    setState(() => isSubmitting = true);

    final result = await Moyasar.pay(
      apiKey: widget.config.publishableApiKey,
      paymentRequest: paymentRequest,
    );

    setState(() => isSubmitting = false);

    _handlePaymentResponse(result);
  }

  void _handlePaymentResponse(dynamic result) {
    if (result is! PaymentResponse ||
        result.status != PaymentStatus.initiated) {
      widget.onPaymentResult(result);
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
      (result.source as CardPaymentResponseSource).message = message;
    }

    Navigator.pop(context);
    widget.onPaymentResult(result);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: _autoValidateMode,
      key: _formKey,
      child: Column(
        children: [
          CardFormField(
            inputDecoration: CreditFormTheme.buildInputDecoration(
              hintText: widget.locale.nameOnCard,
            ),
            keyboardType: TextInputType.text,
            validator: (String? input) =>
                CardUtils.validateName(input, widget.locale),
            onChanged: _onChangeName,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp('[a-zA-Z. ]'),
              ),
            ],
          ),
          CardFormField(
            inputDecoration: CreditFormTheme.buildInputDecoration(
                hintText: widget.locale.cardNumber, addNetworkIcons: true),
            validator: (String? input) => CardUtils.validateCardNum(
              input,
              widget.locale,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              CardNumberInputFormatter(),
            ],
            onChanged: _onChangeCardNumber,
          ),
          CardFormField(
            inputDecoration: CreditFormTheme.buildInputDecoration(
              hintText: '${widget.locale.expiry} (MM / YY)',
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
              CardMonthInputFormatter(),
            ],
            validator: (String? input) => CardUtils.validateDate(
              input,
              widget.locale,
            ),
            onChanged: _onChangeExpiryDate,
          ),
          CardFormField(
            inputDecoration: CreditFormTheme.buildInputDecoration(
              hintText: widget.locale.cvc,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            validator: (String? input) => CardUtils.validateCVC(
              input,
              widget.locale,
            ),
            onChanged: _onChangeCvc,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SizedBox(
              child: ElevatedButton(
                style: ButtonStyle(
                  minimumSize:
                      const MaterialStatePropertyAll<Size>(Size.fromHeight(55)),
                  backgroundColor:
                      MaterialStatePropertyAll<Color>(Colors.blue[700]!),
                ),
                onPressed: isSubmitting ? () {} : _saveForm,
                child: isSubmitting
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : Text(
                        _getShowAmount(
                          widget.config.amount,
                          widget.locale,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onChangeCvc(String? value) => _cardData.cvc = value ?? '';

  void _onChangeName(String? value) => _cardData.name = value ?? '';

  void _onChangeCardNumber(String? value) {
    if (value != null) {
      _cardData.number = CardUtils.getCleanedNumber(value);
    }
  }

  void _onChangeExpiryDate(String? value) {
    if (value != null) {
      List<String> expireDate = CardUtils.getExpiryDate(value);
      _cardData.month = expireDate.first;
      _cardData.year = expireDate[1];
    }
  }

  String _getShowAmount(int amount, Localization locale) {
    final String formattedAmount = (amount / 100).toStringAsFixed(2);

    if (locale.languageCode == 'en') {
      return '${locale.pay} SAR $formattedAmount';
    }

    return '${locale.pay} $formattedAmount ر.س';
  }
}
