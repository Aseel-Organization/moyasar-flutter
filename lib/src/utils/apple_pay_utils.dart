import 'dart:convert';

import 'package:flutter/services.dart';

class ApplePayUtils {
  static Future<String> getMerchantName(String paymentConfigFile) async {
    final String config =
        await rootBundle.loadString('assets/$paymentConfigFile');
    return await json.decode(config)["data"]["displayName"];
  }
}
