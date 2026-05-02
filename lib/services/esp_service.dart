// lib/services/esp_service.dart
// ============================================================
// طبقة HTTP الخام — كل تواصل مع جهاز ESP يمر من هنا فقط
// ============================================================

// import 'dart:convert';
// import 'package:http/http.dart' as http;

class EspService {
  // ── عنوان جهاز ESP ─────────────────────────────────────
  // الجهاز يعمل كـ Access Point (نقطة WiFi)
  // والتطبيق يتصل فيه مباشرة على هذا الـ IP الثابت
  static const String baseUrl = 'http://192.168.4.1';

  // ── جلب حالة السيروم من الجهاز ─────────────────────────
  // ترجع Map تحتوي: percent, running, alarm10_active, alarm10_ack,
  //                 need_setup, reset
  // في وضع المحاكاة ترجع بيانات وهمية
  static Future<Map<String, dynamic>> fetchStatus({
    required double currentRemaining,
  }) async {
    // الكود الحقيقي (معلّق):
    // try {
    //   final uri = Uri.parse('$baseUrl/status');
    //   final res = await http.get(uri).timeout(const Duration(seconds: 3));
    //   if (res.statusCode != 200) return {};
    //   return jsonDecode(res.body) as Map<String, dynamic>;
    // } catch (_) {
    //   return {};
    // }

    // بيانات وهمية للمحاكاة:
    // كل ثانية تنقص remaining بـ 1 (لمحاكاة نزول السيروم)
    return {
      'need_setup': false,       // false = مو محتاج إعادة إعداد
      'reset': false,            // false = مو محتاج إعادة تشغيل
      'percent': currentRemaining > 0 ? currentRemaining - 1 : 75.0,
      'running': true,           // الجهاز شغّال
      'alarm10_active': false,   // مافي تحذير 10% الآن
      'alarm10_ack': false,      // ما أُرسل تأكيد
    };
  }

  // ── إرسال بيانات الإعداد للجهاز ────────────────────────
  // ترجع true عند النجاح، false عند الفشل
  static Future<bool> sendSetup({
    required int capacityMl,
    required int groupNum,
    required int itemNum,
    required String room,
  }) async {
    // البيانات التي سترسل للجهاز بصيغة JSON
    // final payload = {
    //   'capacity_ml': capacityMl, // سعة الكيس
    //   'group': groupNum,         // رقم المجموعة
    //   'item': itemNum,           // رقم السائل داخل المجموعة
    //   'room': room,              // رقم الغرفة
    // };

    // الكود الحقيقي للإرسال (معلّق - وضع المحاكاة):
    // try {
    //   final uri = Uri.parse('$baseUrl/setup');
    //   final res = await http.post(
    //     uri,
    //     headers: {'Content-Type': 'application/json'},
    //     body: jsonEncode(payload),
    //   ).timeout(const Duration(seconds: 3));
    //   return res.statusCode == 200;
    // } catch (e) {
    //   return false;
    // }

    // محاكاة تأخير الإرسال (500ms بدل الطلب الحقيقي)
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  // ── إرسال تأكيد استلام تحذير الـ 10% للجهاز ───────────
  // لما الممرضة تضغط OK على تحذير "السيروم وصل 10%"
  // نرسل للجهاز إشعار إنها شافت التحذير (ACK = Acknowledge)
  static Future<void> sendAck10() async {
    // الكود الحقيقي (معلّق):
    // try {
    //   final uri = Uri.parse('$baseUrl/ack10');
    //   await http.post(uri).timeout(const Duration(seconds: 3));
    // } catch (_) {}
  }
}