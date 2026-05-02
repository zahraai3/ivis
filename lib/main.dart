// import 'dart:convert'; // لتحويل البيانات من/إلى JSON عند التواصل مع الجهاز
import 'package:flutter/material.dart'; // مكتبة Flutter الأساسية للواجهة
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:ivis/screens/intro_screen.dart';
import 'package:ivis/screens/monitor_screen.dart';
import 'package:ivis/screens/room_screen.dart';
import 'package:ivis/screens/setup/capacity_screen.dart';
import 'package:ivis/screens/setup/fluid_screen.dart';
import 'package:ivis/screens/setup/group_screen.dart';
import 'package:ivis/screens/setup/summary_screen.dart';
import 'package:ivis/screens/waiting_screen.dart';
import 'theme/app_theme.dart'; //الملف الخاص بثيم التطبيق بشكل عام
import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http; // لإرسال طلبات HTTP للجهاز (ESP)
import 'models/capacity_option.dart';
import 'models/fluid_group.dart';
import 'data/iv_data.dart';
import 'widgets/buttons.dart';
import 'widgets/input_field.dart';
import 'widgets/header.dart';

// ── نقطة البداية ──────────────────────────────────────────
void main() {
  runApp(const CodeyApp()); // تشغيل التطبيق
}

// ── الـ Widget الجذر للتطبيق ───────────────────────────────
// هذا هو أول widget يشتغل، مهمته الوحيدة إنه يحدد
// الشاشة الأولى للتطبيق (CodeySetupScreen)
class CodeyApp extends StatelessWidget {
  const CodeyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // إخفاء شريط DEBUG الأحمر
      theme: AppTheme.themeData, //اضافه الثيم
      home: CodeySetupScreen(), // الشاشة الأولى عند فتح التطبيق
    );
  }
}

// ============================================================
// الشاشة الرئيسية — تحتوي كل منطق التطبيق
// ============================================================
// StatefulWidget لأن الشاشة تتغير (step يتغير = شاشة تتغير)
class CodeySetupScreen extends StatefulWidget {
  const CodeySetupScreen({super.key});

  @override
  State<CodeySetupScreen> createState() => _CodeySetupScreenState();
}

class _CodeySetupScreenState extends State<CodeySetupScreen> {

  // ── متغير الشاشة الحالية ────────────────────────────────
  // هذا المتغير هو قلب التطبيق — كل ما تغيّر، تتغير الشاشة
  // القيم: -1 (دخول), -2 (غرفة), 0-3 (الإعداد), 4 (انتظار), 5 (مراقبة)
  int step = -1;

  // ── متغيرات الاختيارات ──────────────────────────────────
  // تخزن ما اختارته الممرضة في خطوات الإعداد
  int? selectedCapacityMl; // السعة المختارة (مثلاً: 500)
  int? selectedGroupIndex; // رقم المجموعة في قائمة kFluidGroups (0-6)
  String? selectedFluid; // اسم السائل المختار (نص كامل)

  // ── أرقام للإرسال للجهاز ───────────────────────────────
  // الجهاز يفهم أرقام (1,2,3) أسهل من النصوص الطويلة
  int? selectedGroupNum; // رقم المجموعة للجهاز (1-7)
  int? selectedItemNum; // رقم السائل داخل المجموعة للجهاز (1-N)

  // ── مفتاح منع الإرسال المكرر ──────────────────────────
  // نحفظ آخر بيانات أُرسلت، لو نفس البيانات ما نرسل مجدداً
  // شكله: "500|2|Normal Saline|Room 5"
  String _lastSetupKey = '';

  // ── دالة تسجيل الخروج الكاملة ─────────────────────────
  // تمسح كل البيانات وترجع لأول شاشة
  // ملاحظة: هذي الدالة معرّفة لكن مو مستخدمة حالياً في الكود
  // المستخدمة فعلياً هي _appLogoutToIntroOnly
  void _logout() {
    nurseNameCtrl.clear();
    nurseFullPhone = '';
    nursePhoneCtrl.text = '+964';
    roomCtrl.clear();
    _lastSetupKey = '';
    setState(() {
      step = -1;
    });
  }
  // ── عنوان جهاز ESP ─────────────────────────────────────
  // الجهاز يعمل كـ Access Point (نقطة WiFi)
  // والتطبيق يتصل فيه مباشرة على هذا الـ IP الثابت
  static const String espBaseUrl = 'http://192.168.4.1';

  // ── متغيرات الحالة ──────────────────────────────────────
  bool _sending = false; // true = جاري الإرسال للجهاز (نمنع الضغط مرتين)
  double remaining = 0; // نسبة السيروم المتبقية % (تتحدث كل ثانية)
  bool _running = false; // true = حلقة التحديث التلقائي شغّالة

  // ── متغيرات تحذير الـ 10% ──────────────────────────────
  bool _ack10Shown = false; // هل أرسلنا تأكيد للجهاز؟ (محفوظ للاستخدام لاحقاً)
  bool _lastRunning = false; // آخر حالة للجهاز (شغّال/موقف) — نستخدمه عند الدخول
  bool _alarm10DialogShown = false; // هل ظهر الـ Dialog للممرضة؟ (نمنع تكراره كل ثانية)

  // ── حقول الإدخال (Controllers) ─────────────────────────
  // TextEditingController يربط الـ TextField بالكود
  // ونقدر نقرأ/نمسح القيمة منه في أي وقت
  final TextEditingController nurseNameCtrl = TextEditingController();
  final TextEditingController nursePhoneCtrl =
  TextEditingController();
  final TextEditingController roomCtrl = TextEditingController();

  String nurseFullPhone = '';

  // ── دالة عرض رسالة مؤقتة (SnackBar) ───────────────────
  // تظهر في أسفل الشاشة لثواني ثم تختفي
  // نتحقق من mounted عشان ما نعرضها لو الشاشة اتدمرت
  void _showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ── إرسال تأكيد استلام تحذير الـ 10% للجهاز ───────────
  // لما الممرضة تضغط OK على تحذير "السيروم وصل 10%"
  // نرسل للجهاز إشعار إنها شافت التحذير (ACK = Acknowledge)
  // حالياً معلّق لأننا في وضع المحاكاة
  Future<void> _sendAck10() async {
    // try {
    //   final uri = Uri.parse('$espBaseUrl/ack10');
    //   await http.post(uri).timeout(const Duration(seconds: 3));
    // } catch (_) {}
  }

  // ── عرض تحذير وصول السيروم لـ 10% ─────────────────────
  // يظهر Dialog لا يمكن تجاهله (barrierDismissible: false)
  // الممرضة لازم تضغط OK عشان يختفي
  void _showAlarm10Dialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false, // ما يختفي بالضغط برا الـ dialog
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Warning'),
          content: const Text(
            'IV fluid reached 10%.\nPress OK to acknowledge.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _sendAck10(); // أرسل تأكيد للجهاز
                if (mounted) Navigator.of(ctx).pop(); // أغلق الـ dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // ── جلب حالة السيروم من الجهاز ─────────────────────────
  // هذي الدالة تُستدعى كل ثانية من _startLiveUpdates
  // تجلب: نسبة المتبقي % + هل الجهاز شغّال + هل في تحذير 10%
  Future<void> _fetchStatus() async {
    // ── وضع المحاكاة (Emulator Mode) ──
    // الكود الحقيقي للجهاز معلّق بالتعليقات أدناه
    // بدله نصنع بيانات وهمية للتجربة على المحاكي

    // الكود الحقيقي (معلّق):
    // try {
    //   final uri = Uri.parse('$espBaseUrl/status');
    //   final res = await http.get(uri).timeout(const Duration(seconds: 3));
    //   if (res.statusCode != 200) return;
    //   final data = jsonDecode(res.body);
    //   ...
    // } catch (_) {}

    // بيانات وهمية للمحاكاة:
    // كل ثانية تنقص remaining بـ 1 (لمحاكاة نزول السيروم)
    final data = <String, dynamic>{
      'need_setup': false, // false = مو محتاج إعادة إعداد
      'reset': false, // false = مو محتاج إعادة تشغيل
      'percent': remaining > 0 ? remaining - 1 : 75.0, // ينقص 1% كل ثانية
      'running': true, // الجهاز شغّال
      'alarm10_active': false, // مافي تحذير 10% الآن
      'alarm10_ack': false, // ما أُرسل تأكيد
    };

    // ── تحقق: هل الجهاز يطلب إعادة إعداد؟ ──
    // يصير هذا لو انقطع الاتصال أو أُعيد تشغيل الجهاز
    final needSetup = (data['need_setup'] == true);
    final reset = (data['reset'] == true);

    if (needSetup || reset) {
      if (!mounted) return;
      setState(() {
        step = -2; // ارجع لشاشة الغرفة لإعادة الإعداد
        remaining = 0;
      });
      _running = false; // أوقف التحديث التلقائي
      return;
    }

    // ── استخراج البيانات من الرد ──
    final p = data['percent'];
    final r = data['running'];
    if (p == null) return; // لو ما فيه بيانات، تجاهل

    final percent = (p as num).toDouble();
    final isRunning = (r == true);

    if (!mounted) return;

    // ── تحديث الواجهة بالبيانات الجديدة ──
    setState(() {
      remaining = percent; // حدّث نسبة المتبقي
      _lastRunning = isRunning; // احفظ حالة الجهاز

      // لو كنا بشاشة الانتظار (4) والجهاز بدأ يشتغل → انتقل للمراقبة (5)
      if (step == 4 && isRunning) {
        step = 5;
      }
    });

    // ── منطق تحذير الـ 10% ──────────────────────────────
    final alarm10Active = (data['alarm10_active'] == true);
    final alarm10Ack = (data['alarm10_ack'] == true);

    // أظهر التحذير فقط لو:
    // 1. الجهاز شغّال
    // 2. النسبة وصلت 10% أو أقل
    // 3. الجهاز أرسل إشارة التحذير
    // 4. الممرضة ما أكدت بعد
    // 5. ما أظهرنا الـ dialog قبل (نمنع التكرار كل ثانية)
    if (isRunning &&
        percent <= 10 &&
        alarm10Active &&
        !alarm10Ack &&
        !_alarm10DialogShown) {
      _alarm10DialogShown = true; // علّم إننا أظهرنا الـ dialog
      _showAlarm10Dialog();
    }

    // إعادة تفعيل التحذير لو تغيرت الظروف
    // (مثلاً لو بدأ سيروم جديد وارتفعت النسبة فوق 10% مجدداً)
    if (!alarm10Active || alarm10Ack || percent > 10 || !isRunning) {
      _alarm10DialogShown = false;
    }
  }

  // ── بدء التحديث التلقائي كل ثانية ─────────────────────
  // تُستدعى مرة وحدة عند الوصول لشاشة المراقبة
  // تستمر حتى يتغير _running لـ false (عند الـ Logout)
  void _startLiveUpdates() {
    _running = true;

    // Future.doWhile = حلقة غير متزامنة
    // تكرر طالما الدالة ترجع true
    Future.doWhile(() async {
      if (!_running) return false; // أوقف الحلقة
      await _fetchStatus(); // اجلب البيانات
      await Future.delayed(const Duration(seconds: 1)); // انتظر ثانية
      return _running; // كرر لو _running لا زال true
    });
  }

  // ── تسجيل الخروج وإعادة لأول شاشة ────────────────────
  // تمسح بيانات الممرضة وتوقف التحديث وترجع لشاشة الدخول
  Future<void> _appLogoutToIntroOnly() async {
    _running = false; // أوقف التحديث التلقائي
    remaining = 0; // صفّر النسبة

    // أعد تهيئة متغيرات التحذير
    _alarm10DialogShown = false;
    _ack10Shown = false;

    // امسح بيانات الممرضة
    nurseNameCtrl.clear();
    nursePhoneCtrl.text = '+964';

    if (!mounted) return;
    setState(() => step = -1); // ارجع لشاشة الدخول
    _showMsg('Logout (Switch nurse) ✅');
  }

  // ============================================================
  // بناء الواجهة الرئيسية
  // ============================================================
  // build يُستدعى كل مرة setState تُستدعى
  // يقرر أي Scaffold يعرض حسب قيمة step
  @override
  Widget build(BuildContext context) {
    // ── شاشة الدخول: بيضاء بدون gradient ──
    if (step == -1) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: _buildStep(),
          ),
        ),
      );
    }

    // ── شاشة الغرفة: مع زر Logout ──
    if (step == -2) {
      return Scaffold(
        body: Stack(
          children: [
            _buildStep(),
            Positioned(
              left: 16,
              top: 16,
              child: LogoutPill(onTap: _appLogoutToIntroOnly),
            ),
          ],
        ),
      );
    }

    // ── شاشات المراقبة (4 و5): مع زر Logout ──
    if (step >= 4) {
      return Scaffold(
        body: Stack(
          children: [
            _buildStep(),
            Positioned(
              left: 16,
              top: 16,
              child: LogoutPill(onTap: _appLogoutToIntroOnly),
            ),
          ],
        ),
      );
    }

    // ── شاشات الإعداد (0-3): مع gradient وزر Logout ──
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundGradient,
            ),
            child: SafeArea(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: _buildStep(),
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 16,
            child: LogoutPill(onTap: _appLogoutToIntroOnly),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // دالة بناء محتوى كل شاشة حسب قيمة step
  // ============================================================
  Widget _buildStep() {
    // ── step -1: شاشة تسجيل الدخول ─────────────────────
    // LayoutBuilder يعطينا أبعاد الشاشة عشان نضبط الحجم ديناميكياً
    if (step == -1) {
      return IntroScreen(
        onContinue: (name, phone) {
          nurseFullPhone = phone;
          _showMsg('Saved ✅');
          _lastRunning = false;
          if (_lastRunning) {
            setState(() => step = 5);
            if (!_running) _startLiveUpdates();
          } else {
            setState(() => step = -2);
          }
        },
      );
    }

    // ── step -2: شاشة رقم الغرفة ────────────────────────
    if (step == -2) {
      return RoomScreen(
          onContinue: (room) => setState(() {
            roomCtrl.text = room;
            step = 0;
          }),
          onLogout : _appLogoutToIntroOnly,
      );
    }

    //step 0: capacity choosing
    if (step == 0) {
      return CapacityScreen(
        onSelect: (ml) => setState(() {
          selectedCapacityMl = ml;
          step = 1;
        }),
        onBack: () => setState(() => step = -2),
        onLogout: _appLogoutToIntroOnly,
      );
    }
    //------ step 1: choosing the fluid group
    if (step == 1) {
      return GroupScreen(
        onSelect: (groupIndex) => setState(() {
          selectedGroupIndex = groupIndex;
          selectedGroupNum = groupIndex + 1;
          step = 2;
        }),
        onBack: () => setState(() => step = 0),
        onLogout: _appLogoutToIntroOnly,
      );
    }
    // ── step 2: اختيار نوع السائل ───────────────────────
    if (step == 2) {
      return FluidScreen(
        groupIndex: selectedGroupIndex ?? 0,
        onSelect: (fluid, itemNum) => setState(() {
          selectedFluid = fluid;
          selectedItemNum = itemNum;
          step = 3;
        }),
        onBack: () => setState(() => step = 1),
        onLogout: _appLogoutToIntroOnly,
      );
    }
    //---step 3: summary screen ───────────────────────────
    if (step == 3) {
      return SummaryScreen(
        capacityMl: selectedCapacityMl ?? 0,
        groupIndex: selectedGroupIndex ?? 0,
        fluid: selectedFluid ?? '',
        room: roomCtrl.text,
        espBaseUrl: espBaseUrl,
        isSending: _sending,
        onSend: _sendSetupToEsp,
        onBack: () => setState(() => step = 2),
        onLogout: _appLogoutToIntroOnly,
      );
    }

    // ── step 4: انتظار بدء السيروم ───────────────────────
    // تظهر بعد الإرسال للجهاز
    // نبدأ التحديث التلقائي هنا — لما الجهاز يبدأ يرسل running=true
    // سينتقل تلقائياً لـ step 5
    if (step == 4) {
      if (!_running) _startLiveUpdates();
      return WaitingScreen(
        onLogout: _appLogoutToIntroOnly,
      );
    }

    // ── step 5: شاشة المراقبة الحية ─────────────────────
    // تعرض نسبة السيروم المتبقية % وتتحدث كل ثانية
    if (step == 5) {
      if (!_running) _startLiveUpdates();
      return MonitorScreen(
        remaining: remaining,
        onLogout: _appLogoutToIntroOnly, room: '',
      );
    }
    // احتياطي: لو step بقيمة غير متوقعة
    return const SizedBox.shrink();
  }

  // ── إرسال بيانات الإعداد للجهاز ────────────────────────
  // تُستدعى عند الضغط على Send في step 3
  Future<void> _sendSetupToEsp() async {
    if (_sending) return; // منع الضغط المزدوج

    // تحقق إن كل الاختيارات مكتملة
    final cap = selectedCapacityMl;
    final gi = selectedGroupIndex;
    final fl = selectedFluid;

    if (cap == null || gi == null || fl == null) {
      _showMsg('Please complete selections first.');
      return;
    }

    final room = roomCtrl.text.trim();

    // ── منع الإرسال المكرر لنفس البيانات ──
    // نبني "مفتاح" من كل الاختيارات، لو نفس المفتاح ما نرسل
    final key = '$cap|$gi|$fl|$room';
    if (key == _lastSetupKey) return;
    _lastSetupKey = key;

    // البيانات التي سترسل للجهاز بصيغة JSON
    final payload = {
      'capacity_ml': cap, // سعة الكيس
      'group': selectedGroupNum, // رقم المجموعة
      'item': selectedItemNum, // رقم السائل داخل المجموعة
      'room': room, // رقم الغرفة
    };

    // الكود الحقيقي للإرسال (معلّق - وضع المحاكاة):
    // final uri = Uri.parse('$espBaseUrl/setup');

    setState(() => _sending = true); // أظهر حالة الإرسال (يعطّل زر Send)

    // محاكاة تأخير الإرسال (500ms بدل الطلب الحقيقي):
    // try {
    //   final res = await http.post(
    //     uri,
    //     headers: {'Content-Type': 'application/json'},
    //     body: jsonEncode(payload),
    //   ).timeout(const Duration(seconds: 3));
    //   if (res.statusCode == 200) { ... } else { ... }
    // } catch (e) { _showMsg('Error sending: $e'); }
    // finally { if (mounted) setState(() => _sending = false); }

    await Future.delayed(const Duration(milliseconds: 500));

    _showMsg('Sent ✅');

    // أعد تهيئة متغيرات التحذير لبداية جلسة جديدة
    _alarm10DialogShown = false;
    _ack10Shown = false;

    // قيمة بداية وهمية للمحاكاة
    remaining = 75.0;

    if (mounted) {
      setState(() {
        _sending = false;
        step = 4; // انتقل لشاشة الانتظار
      });
    }
  }
}