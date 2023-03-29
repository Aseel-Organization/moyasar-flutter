import 'package:moyasar/moyasar.dart';
import 'package:moyasar/src/models/payment_request.dart';
import 'package:moyasar/src/models/sources/apple_pay/apple_pay_request_source.dart';
import 'package:moyasar/src/models/sources/card/card_request_source.dart';
import 'package:moyasar/src/moyasar.dart';

class MoyasarService {
  static Future<PaymentResponse> pay({
    required PaymentConfig config,
    required CardFormModel cardData,
  }) async {
    try {
      final source = CardPaymentRequestSource(cardData);
      final paymentRequest = PaymentRequest(config, source);
      final result = await Moyasar.pay(
          apiKey: config.publishableApiKey, paymentRequest: paymentRequest);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  static Future<PaymentStatus> applePay({
    required PaymentConfig config,
    required String token,
  }) async {
    final source = ApplePayPaymentRequestSource(token);
    final paymentRequest = PaymentRequest(config, source);
    final result = await Moyasar.pay(
        apiKey: config.publishableApiKey, paymentRequest: paymentRequest);
    if (result is PaymentResponse) {
      return result.status;
    }
    return PaymentStatus.failed;
  }

  MoyasarService._();
}
