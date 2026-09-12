import 'package:url_launcher/url_launcher.dart';
import '../logger/app_logger.dart';

/// Helper utility for handling phone calls and WhatsApp messaging.
class ContactHelper {
  const ContactHelper._();

  /// Cleans and formats a phone number for direct calling.
  static String sanitizePhoneForCall(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }

  /// Cleans and formats a phone number for WhatsApp wa.me links.
  /// Converts Egyptian local format (e.g. 010xxxxxxxx) to international 2010xxxxxxxx.
  static String formatPhoneForWhatsApp(String phone) {
    // Remove all non-digits except optional plus
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    if (cleaned.startsWith('+')) {
      cleaned = cleaned.substring(1);
    } else if (cleaned.startsWith('00')) {
      cleaned = cleaned.substring(2);
    }

    // If Egyptian 11-digit local mobile starting with 01 (010, 011, 012, 015)
    if (cleaned.startsWith('01') && cleaned.length == 11) {
      cleaned = '2$cleaned';
    }

    return cleaned;
  }

  /// Initiates a phone call via the device dialer.
  static Future<bool> callPhoneNumber(String phone) async {
    final sanitized = sanitizePhoneForCall(phone);
    if (sanitized.isEmpty) {
      appLogger.w('[ContactHelper] Empty phone number provided for call');
      return false;
    }

    final uri = Uri(scheme: 'tel', path: sanitized);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        appLogger.w('[ContactHelper] Could not launch tel:$sanitized');
        return false;
      }
      return true;
    } catch (e, stack) {
      appLogger.e(
        '[ContactHelper] Error calling $sanitized: $e',
        error: e,
        stackTrace: stack,
      );
      return false;
    }
  }

  /// Opens a WhatsApp chat with the specified phone number and optional message.
  static Future<bool> openWhatsApp(
    String phone, {
    String? message,
  }) async {
    final formattedNumber = formatPhoneForWhatsApp(phone);
    if (formattedNumber.isEmpty) {
      appLogger.w('[ContactHelper] Empty phone number provided for WhatsApp');
      return false;
    }

    final queryParams = <String, String>{};
    if (message != null && message.trim().isNotEmpty) {
      queryParams['text'] = message.trim();
    }

    final uri = Uri.https(
      'wa.me',
      '/$formattedNumber',
      queryParams.isEmpty ? null : queryParams,
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        appLogger.w('[ContactHelper] Could not launch WhatsApp url: $uri');
        return false;
      }
      return true;
    } catch (e, stack) {
      appLogger.e(
        '[ContactHelper] Error launching WhatsApp for $formattedNumber: $e',
        error: e,
        stackTrace: stack,
      );
      return false;
    }
  }
}
