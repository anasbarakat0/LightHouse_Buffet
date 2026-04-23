abstract final class ScanPageConstants {
  static const Duration verificationDuration = Duration(seconds: 2);
  static const Duration pulseDuration = Duration(milliseconds: 1800);
  static const Duration focusRestoreDelay = Duration(milliseconds: 100);

  static const String arabicLogoAsset = 'assets/svg/ar-logo.svg';
  static const String englishLogoAsset = 'assets/svg/en-logo.svg';
  static const String backgroundPatternAsset = 'assets/svg/lighthouse_ch.svg';
  static const String scannerGifAsset = 'assets/gif/qr_scanner_transparent.gif';

  static const String verificationSuccessMessage =
      'QR Code verified successfully';
  static const String genericErrorMessage =
      'An error occurred. Please try again.';
}
