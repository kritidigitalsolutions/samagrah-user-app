import 'package:flutter/foundation.dart';
import 'package:samagrah/res/app_urls.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> makePhoneCall(String? phone) async {
  if (phone == null || phone.isEmpty) {
    debugPrint("Phone number is empty");
    return;
  }

  final Uri url = Uri(scheme: 'tel', path: phone);

  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    debugPrint("Could not launch $url");
  }
}

Future<void> openWhatsApp(String? phone) async {
  if (phone == null || phone.isEmpty) {
    debugPrint("WhatsApp number is empty");
    return;
  }

  // IMPORTANT: phone must be in international format (e.g., +919876543210)
  final String formattedPhone = phone.startsWith('+')
      ? phone
      : '+91$phone'; // adjust if needed

  final Uri url = Uri.parse(
    "https://wa.me/$formattedPhone?text=${Uri.encodeComponent("Hello Pandit Ji 🙏")}",
  );

  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    debugPrint("Could not open WhatsApp");
  }
}

String capitalizeWords(String text) {
  if (text.isEmpty) return text;

  return text
      .toLowerCase()
      .split(' ')
      .map(
        (word) =>
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '',
      )
      .join(' ');
}

Future<void> openZoom(String url) async {
  final Uri uri = Uri.parse(url);

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
