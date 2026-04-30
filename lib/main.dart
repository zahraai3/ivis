// import 'dart:convert'; // لتحويل البيانات من/إلى JSON عند التواصل مع الجهاز
import 'package:flutter/material.dart'; // مكتبة Flutter الأساسية للواجهة
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:ivis/screens/intro_screen.dart';
import 'package:ivis/screens/room_screen.dart';
import 'package:ivis/screens/setup/capacity_screen.dart';
import 'package:ivis/screens/setup/group_screen.dart';
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

  // ── ألوان الخلفية للشاشات الوسطى (0-3) ────────────────
  // Gradient من أزرق فاتح لأزرق أغمق
  static const Color bgTop = Color(0xFFDFF5F4);
  static const Color bgBottom = Color(0xFF78C9C8);

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
        onContinue: () => setState(() => step = 0),
        onLogout: _appLogoutToIntroOnly,
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
      // نجيب المجموعة المختارة عشان نعرض أنواعها
      final g = kFluidGroups[selectedGroupIndex ?? 0];

      return Container(
        // خلفية الشاشة بالـ gradient من الثيم
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPaddingH,
              vertical: AppDimensions.screenPaddingV,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                SizedBox(height: 80),
                // ── عنوان الشاشة ──
                Text(
                  'Fluid Type',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: AppDimensions.spaceSM),

                // ── اسم المجموعة المختارة كـ subtitle ──
                // يساعد الممرضة تتأكد إنها بالمجموعة الصحيحة
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceMD,
                    vertical: AppDimensions.spaceSM,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentLight,
                    borderRadius: BorderRadius.circular(
                        AppDimensions.radiusFull),
                  ),
                  child: Text(
                    g.title, // عنوان المجموعة المختارة من kFluidGroups
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spaceLG),

                // ── قائمة أنواع السوائل داخل المجموعة المختارة ──
                Expanded(
                  child: ListView(
                    children: [
                      // نعرض زر لكل نوع سائل داخل المجموعة المختارة
                      for (final item in g.items)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppDimensions.spaceMD,
                          ),
                          child: BigPillButton(
                            text: item,
                            onTap: () {
                              setState(() {
                                selectedFluid = item;
                                selectedItemNum = g.items.indexOf(item) +
                                    1; // رقم للجهاز (1-based)
                                step = 3; // انتقل للملخص
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                ),

                // ── شريط الأزرار السفلي ──
                BottomBar(
                  showBack: true,
                  showSend: false,
                  onBack: () => setState(() => step = 1),
                  // ارجع لاختيار المجموعة
                  onSend: () {},
                ),

              ],
            ),
          ),
        ),
      );
    }
    // ── step 3: ملخص الاختيارات قبل الإرسال ─────────────
    if (step == 3) {
      return Column(
        children: [
          const SizedBox(height: 10),
          const Header(title1: 'DONE', title2: 'SUMMARY'),
          const SizedBox(height: 25),
          // بطاقة بيضاء تعرض ملخص كل ما اختارته الممرضة
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Capacity: ${selectedCapacityMl ?? 0} mL',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Group: ${selectedGroupIndex != null
                      ? kFluidGroups[selectedGroupIndex!].title
                      : ''}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(
                  'Fluid: ${selectedFluid ?? ''}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                // عنوان الجهاز — مفيد للتشخيص في حالة مشاكل الاتصال
                Text(
                  'ESP: $espBaseUrl',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const Spacer(),
          BottomBar(
            showBack: true,
            showSend: true,
            onBack: () => setState(() => step = 2), // ارجع لاختيار السائل
            // لو جاري الإرسال (_sending=true) ما نسمح بضغط Send مجدداً
            onSend: _sending ? () {} : _sendSetupToEsp,
          ),
        ],
      );
    }

    // ── step 4: انتظار بدء السيروم ───────────────────────
    // تظهر بعد الإرسال للجهاز
    // نبدأ التحديث التلقائي هنا — لما الجهاز يبدأ يرسل running=true
    // سينتقل تلقائياً لـ step 5
    if (step == 4) {
      if (!_running) _startLiveUpdates(); // ابدأ التحديث لو ما بدأ بعد

      return Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/nnnn.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.25), // طبقة شفافة فوق الصورة
            ),
          ),
          // رسالة الانتظار في أسفل الشاشة
          Align(
            alignment: const Alignment(0, 0.75),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 22),
              padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.88),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Text(
                'Please complete the required data entry.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF25406B),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // ── step 5: شاشة المراقبة الحية ─────────────────────
    // تعرض نسبة السيروم المتبقية % وتتحدث كل ثانية
    if (step == 5) {
      // ── دالة تحديد لون المؤشر حسب النسبة ──
      // أحمر: خطر (≤10%) | برتقالي: تحذير (<50%) | أخضر: طبيعي
      Color getColor(double value) {
        if (value <= 10) return Colors.red;
        if (value < 50) return Colors.orange;
        return Colors.green;
      }

      Color dynamicColor = getColor(remaining);
      if (!_running) _startLiveUpdates(); // تأكد إن التحديث شغّال

      return Stack(
        children: [
          // صورة الخلفية
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgrawnd.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.white.withOpacity(0.12)),
          ),
          // صورة كيس السيروم في الزاوية السفلى اليمنى
          Positioned(
            right: -10,
            bottom: -10,
            child: Image.asset(
              'assets/images/iv.png',
              width: 330,
              fit: BoxFit.contain,
            ),
          ),
          // البطاقة الرئيسية في المنتصف
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 22),
              padding:
              const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.75),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Remaining %',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF20375C),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // الرقم الكبير — لونه يتغير حسب النسبة
                  Text(
                    '${remaining.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w900,
                      color: dynamicColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // شريط التقدم (Progress Bar)
                  // عرضه الكلي 220px × نسبة المتبقي = العرض الملوّن
                  Container(
                    width: 220,
                    height: 18,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.grey.shade300, // الخلفية الرمادية
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 220 * (remaining / 100), // العرض الملوّن
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: dynamicColor, // نفس لون الرقم
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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