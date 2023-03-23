import 'package:moyasar/moyasar.dart';
import 'package:moyasar/src/models/payment_request.dart';
import 'package:moyasar/src/models/sources/card/card_request_source.dart';
import 'package:moyasar/src/moyasar.dart';

class MoyasarService {
  final CardFormModel _cardData;
  final PaymentConfig _config;
  MoyasarService({
    required CardFormModel cardData,
    required PaymentConfig config,
  })  : _cardData = cardData,
        _config = config;

  Future<PaymentResponse?> pay() async {
    final source = CardPaymentRequestSource(_cardData);
    final paymentRequest = PaymentRequest(_config, source);

    final result = await Moyasar.pay(
        apiKey: _config.publishableApiKey, paymentRequest: paymentRequest);

    if (result is! PaymentResponse ||
        result.status != PaymentStatus.initiated) {
      return null;
    }

    return result;
  }
}
