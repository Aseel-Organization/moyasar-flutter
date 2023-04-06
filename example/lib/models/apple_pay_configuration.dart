class ApplePayConfiguration {
  final String merchantIdentifier;
  final String displayName;
  final List<MerchantCapabilities>? merchantCapabilities;
  final List<SupportedNetworks>? supportedNetworks;
  final String countryCode;
  final String currencyCode;

  const ApplePayConfiguration({
    required this.merchantIdentifier,
    required this.displayName,
    this.merchantCapabilities,
    this.supportedNetworks,
    this.countryCode = 'SA',
    this.currencyCode = 'SAR',
  });

  Map<String, dynamic> toJson() {
    return {
      'provider': 'apple_pay',
      'data': {
        'merchantIdentifier': merchantIdentifier,
        'displayName': displayName,
        'merchantCapabilities': merchantCapabilities?.map((e) => e.name) ??
            [
              MerchantCapabilities.threeDS.name,
              MerchantCapabilities.debit.name,
              MerchantCapabilities.credit.name,
            ],
        'supportedNetworks': supportedNetworks?.map((e) => e.name) ??
            [
              SupportedNetworks.amex.name,
              SupportedNetworks.visa.name,
              SupportedNetworks.mada.name,
              SupportedNetworks.masterCard.name,
            ],
        'countryCode': countryCode,
        'currencyCode': currencyCode,
      }
    };
  }
}

enum MerchantCapabilities {
  threeDS(name: '3DS'),
  debit(name: 'debit'),
  credit(name: 'credit');

  final String? name;
  const MerchantCapabilities({this.name});
}

enum SupportedNetworks {
  amex,
  visa,
  mada,
  masterCard,
}
