/// Bundled ISO-4217 currency list — symbol/label/formatting only. No
/// exchange-rate lookup or conversion of any kind (Zakah figures are
/// entered and reported in one chosen currency). Offline by design.
library;

class Currency {
  const Currency(this.code, this.symbol, this.name);

  /// ISO-4217 alphabetic code, e.g. `USD`.
  final String code;

  /// Display symbol, e.g. `$`. Falls back to the code where no short
  /// symbol is in common use.
  final String symbol;

  final String name;

  /// Formats [amount] as `<symbol><value>` with two decimals — deliberately
  /// simple (no locale grouping) so it is deterministic and testable.
  String format(double amount) => '$symbol${amount.toStringAsFixed(2)}';
}

/// A broad, alphabetically-ordered subset of circulating ISO-4217
/// currencies covering the app's expected audience. Symbol-only; extend as
/// needed. `SAR`/`USD` lead the common defaults.
const List<Currency> currencies = [
  Currency('AED', 'د.إ', 'UAE Dirham'),
  Currency('AFN', '؋', 'Afghan Afghani'),
  Currency('ALL', 'L', 'Albanian Lek'),
  Currency('AZN', '₼', 'Azerbaijani Manat'),
  Currency('BDT', '৳', 'Bangladeshi Taka'),
  Currency('BHD', '.د.ب', 'Bahraini Dinar'),
  Currency('BND', r'$', 'Brunei Dollar'),
  Currency('BRL', r'R$', 'Brazilian Real'),
  Currency('CAD', r'C$', 'Canadian Dollar'),
  Currency('CHF', 'Fr', 'Swiss Franc'),
  Currency('CNY', '¥', 'Chinese Yuan'),
  Currency('DZD', 'د.ج', 'Algerian Dinar'),
  Currency('EGP', 'ج.م', 'Egyptian Pound'),
  Currency('EUR', '€', 'Euro'),
  Currency('GBP', '£', 'Pound Sterling'),
  Currency('GHS', '₵', 'Ghanaian Cedi'),
  Currency('IDR', 'Rp', 'Indonesian Rupiah'),
  Currency('INR', '₹', 'Indian Rupee'),
  Currency('IQD', 'ع.د', 'Iraqi Dinar'),
  Currency('IRR', '﷼', 'Iranian Rial'),
  Currency('JOD', 'د.ا', 'Jordanian Dinar'),
  Currency('JPY', '¥', 'Japanese Yen'),
  Currency('KES', 'KSh', 'Kenyan Shilling'),
  Currency('KWD', 'د.ك', 'Kuwaiti Dinar'),
  Currency('KZT', '₸', 'Kazakhstani Tenge'),
  Currency('LBP', 'ل.ل', 'Lebanese Pound'),
  Currency('LKR', 'Rs', 'Sri Lankan Rupee'),
  Currency('LYD', 'ل.د', 'Libyan Dinar'),
  Currency('MAD', 'د.م.', 'Moroccan Dirham'),
  Currency('MVR', '.ރ', 'Maldivian Rufiyaa'),
  Currency('MYR', 'RM', 'Malaysian Ringgit'),
  Currency('NGN', '₦', 'Nigerian Naira'),
  Currency('NOK', 'kr', 'Norwegian Krone'),
  Currency('OMR', 'ر.ع.', 'Omani Rial'),
  Currency('PKR', 'Rs', 'Pakistani Rupee'),
  Currency('QAR', 'ر.ق', 'Qatari Riyal'),
  Currency('RUB', '₽', 'Russian Ruble'),
  Currency('SAR', 'ر.س', 'Saudi Riyal'),
  Currency('SDG', 'ج.س', 'Sudanese Pound'),
  Currency('SEK', 'kr', 'Swedish Krona'),
  Currency('SGD', r'S$', 'Singapore Dollar'),
  Currency('SOS', 'Sh', 'Somali Shilling'),
  Currency('SYP', 'ل.س', 'Syrian Pound'),
  Currency('THB', '฿', 'Thai Baht'),
  Currency('TND', 'د.ت', 'Tunisian Dinar'),
  Currency('TRY', '₺', 'Turkish Lira'),
  Currency('TZS', 'TSh', 'Tanzanian Shilling'),
  Currency('USD', r'$', 'US Dollar'),
  Currency('UZS', "so'm", 'Uzbekistani Som'),
  Currency('YER', '﷼', 'Yemeni Rial'),
  Currency('ZAR', 'R', 'South African Rand'),
];

Currency currencyByCode(String code) =>
    currencies.firstWhere((c) => c.code == code, orElse: () => currencies.first);

const defaultCurrencyCode = 'USD';
