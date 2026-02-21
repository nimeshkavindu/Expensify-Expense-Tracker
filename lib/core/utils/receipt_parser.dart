import 'package:google_ml_kit/google_ml_kit.dart';

class ReceiptParser {
  static Future<Map<String, dynamic>> parseReceipt(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();

    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      String fullText = recognizedText.text;

      // 1. Extract the Merchant (Assume it's the first line of the receipt)
      String merchant = 'Unknown Merchant';
      if (recognizedText.blocks.isNotEmpty) {
        merchant = recognizedText.blocks.first.text.split('\n').first;
      }

      // 2. Extract the Total Amount using Regex
      // Looks for $ signs and decimals, e.g., $12.99, 12.99, Total: 12.99
      double maxAmount = 0.0;
      RegExp amountRegex = RegExp(r'\$?\s*(\d+\.\d{2})');
      Iterable<RegExpMatch> matches = amountRegex.allMatches(fullText);

      for (final match in matches) {
        if (match.group(1) != null) {
          double? amount = double.tryParse(match.group(1)!);
          // We assume the largest number on a receipt is usually the Total
          if (amount != null && amount > maxAmount && amount < 10000) {
            maxAmount = amount;
          }
        }
      }

      return {
        'merchant': merchant,
        'amount': maxAmount,
        'date': DateTime.now(), // Default to today
        'text': fullText, // Raw text for debugging
      };
    } finally {
      textRecognizer.close();
    }
  }
}
