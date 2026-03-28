// ============================================================
// main.dart — ملف التطبيق الرئيسي
// التطبيق: Codey — نظام مراقبة السيروم الوريدي (IV Monitor)
// الفكرة: الممرضة تدخل بياناتها وبيانات السيروم، والتطبيق
//         يتواصل مع جهاز ESP عبر WiFi ويعرض نسبة السيروم المتبقية
// ============================================================

// import 'dart:convert'; // لتحويل البيانات من/إلى JSON عند التواصل مع الجهاز
import 'package:flutter/material.dart'; // مكتبة Flutter الأساسية للواجهة
// import 'package:http/http.dart' as http; // لإرسال طلبات HTTP للجهاز (ESP)

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
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // إخفاء شريط DEBUG الأحمر
      home: CodeySetupScreen(), // الشاشة الأولى عند فتح التطبيق
    );
  }
}

// ── موديل خيار السعة ──────────────────────────────────────
// كلاس بسيط يمثل حجم كيس السيروم (مثلاً: 500 mL)
// استخدمناه بدل ما نكتب الأرقام مباشرة، عشان الكود يكون أوضح
class CapacityOption {
  final int ml; // الحجم بالمليلتر
  const CapacityOption(this.ml);
  String get label => '$ml mL'; // النص الي يظهر على الزر (مثلاً: "500 mL")
}

// ── موديل مجموعة السوائل ──────────────────────────────────
// كل مجموعة عندها عنوان وقائمة بأنواع السوائل اللي تنتمي لها
// مثلاً: مجموعة "Dextrose Solutions" تحتوي D5W, D10W, D20W
class FluidGroup {
  final String title; // اسم المجموعة
  final List<String> items; // قائمة أنواع السوائل داخل المجموعة
  const FluidGroup(this.title, this.items);
}

// ── البيانات الثابتة: خيارات السعة ────────────────────────
// قائمة ثابتة بأحجام الأكياس المتاحة في المستشفى
// الـ const تعني إنها تُحسب مرة وحدة عند تشغيل التطبيق ولا تتغير
const List<CapacityOption> kCapacities = [
  CapacityOption(100),
  CapacityOption(250),
  CapacityOption(500),
  CapacityOption(1000),
];

// ── البيانات الثابتة: مجموعات السوائل الطبية ──────────────
// قائمة كاملة بكل أنواع السوائل الوريدية المستخدمة في المستشفيات
// مقسمة لمجموعات طبية منطقية عشان يسهل على الممرضة تلاقي ما تريد
const List<FluidGroup> kFluidGroups = [
  // ── مجموعة 1: محاليل الصوديوم كلوريد (الملح) ──
  FluidGroup('Intravenous Sodium Chloride Solutions', [
    'Half Normal Saline (0.45% NaCl)', // ملح خفيف، للأطفال وحالات خاصة
    'Normal Saline (0.9% NaCl)', // الأكثر شيوعاً — ترطيب عام
    'Hypertonic Saline (3% NaCl)', // ملح مركّز — لحالات تورم الدماغ
    'Hypertonic Saline (5% NaCl)',
    'Hypertonic Saline (7.5% NaCl)',
  ]),
  // ── مجموعة 2: محاليل رينجر ──
  FluidGroup('Intravenous Ringer\u2019s Solutions', [
    "Lactated Ringer's (Hartmann)", // الأشهر — يشبه تركيب بلازما الدم
    "Acetated Ringer's", // بديل Lactated Ringer's
    "Lactated Ringer's + Dextrose 5%", // رينجر + سكر
    "Acetated Ringer's + Dextrose 5%",
  ]),
  // ── مجموعة 3: محاليل السكر (Dextrose) ──
  FluidGroup('Intravenous Dextrose Solutions', [
    'D5W (Dextrose 5% in Water)', // سكر خفيف — شائع جداً
    'D10W (Dextrose 10% in Water)', // تغذية وريدية
    'D20W (Dextrose 20% in Water)', // تغذية مركّزة
  ]),
  // ── مجموعة 4: سكر + ملح مع بعض ──
  FluidGroup('Combined Dextrose and Sodium Chloride Solutions', [
    'D5 1/2NS (D5 in 0.45% Saline)',
    'D5NS (D5 in Normal Saline)',
    'D10NS (D10 in Normal Saline)',
  ]),
  // ── مجموعة 5: مانيتول ──
  FluidGroup('Intravenous Mannitol Solutions', [
    'Mannitol 5%', // لتخفيف ضغط الدماغ
    'Mannitol 10%',
    'Mannitol 15%',
    'Mannitol 20%',
  ]),
  // ── مجموعة 6: محاليل الإلكتروليت المتعددة ──
  FluidGroup('Intravenous Multiple Electrolyte Solutions', [
    'Plasma-Lyte A', // بديل متطور عن رينجر
    'Plasma-Lyte + Dextrose 5%',
    "Hartmann's",
  ]),
  // ── مجموعة 7: محاليل إضافية ──
  FluidGroup('Additional', [
    'Dextran 40 10% in Saline', // لتعويض حجم الدم
    'Dextran 70 6% in Saline',
    'Hydroxyethyl Starch 6% (HES 6%)', // بديل بلازما الدم
  ]),
];

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
  int? selectedCapacityMl;   // السعة المختارة (مثلاً: 500)
  int? selectedGroupIndex;   // رقم المجموعة في قائمة kFluidGroups (0-6)
  String? selectedFluid;     // اسم السائل المختار (نص كامل)

  // ── أرقام للإرسال للجهاز ───────────────────────────────
  // الجهاز يفهم أرقام (1,2,3) أسهل من النصوص الطويلة
  int? selectedGroupNum; // رقم المجموعة للجهاز (1-7)
  int? selectedItemNum;  // رقم السائل داخل المجموعة للجهاز (1-N)

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
  bool _sending = false;   // true = جاري الإرسال للجهاز (نمنع الضغط مرتين)
  double remaining = 0;    // نسبة السيروم المتبقية % (تتحدث كل ثانية)
  bool _running = false;   // true = حلقة التحديث التلقائي شغّالة

  // ── متغيرات تحذير الـ 10% ──────────────────────────────
  bool _ack10Shown = false;        // هل أرسلنا تأكيد للجهاز؟ (محفوظ للاستخدام لاحقاً)
  bool _lastRunning = false;       // آخر حالة للجهاز (شغّال/موقف) — نستخدمه عند الدخول
  bool _alarm10DialogShown = false; // هل ظهر الـ Dialog للممرضة؟ (نمنع تكراره كل ثانية)

  // ── حقول الإدخال (Controllers) ─────────────────────────
  // TextEditingController يربط الـ TextField بالكود
  // ونقدر نقرأ/نمسح القيمة منه في أي وقت
  final TextEditingController nurseNameCtrl = TextEditingController();
  final TextEditingController nursePhoneCtrl =
  TextEditingController(text: '+964'); // رقم العراق افتراضي
  final TextEditingController roomCtrl = TextEditingController();

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
      'need_setup': false,    // false = مو محتاج إعادة إعداد
      'reset': false,         // false = مو محتاج إعادة تشغيل
      'percent': remaining > 0 ? remaining - 1 : 75.0, // ينقص 1% كل ثانية
      'running': true,        // الجهاز شغّال
      'alarm10_active': false, // مافي تحذير 10% الآن
      'alarm10_ack': false,   // ما أُرسل تأكيد
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
      remaining = percent;       // حدّث نسبة المتبقي
      _lastRunning = isRunning;  // احفظ حالة الجهاز

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
      await _fetchStatus();        // اجلب البيانات
      await Future.delayed(const Duration(seconds: 1)); // انتظر ثانية
      return _running;             // كرر لو _running لا زال true
    });
  }

  // ── تسجيل الخروج وإعادة لأول شاشة ────────────────────
  // تمسح بيانات الممرضة وتوقف التحديث وترجع لشاشة الدخول
  Future<void> _appLogoutToIntroOnly() async {
    _running = false;   // أوقف التحديث التلقائي
    remaining = 0;      // صفّر النسبة

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
              child: _LogoutPill(onTap: _appLogoutToIntroOnly),
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
              child: _LogoutPill(onTap: _appLogoutToIntroOnly),
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
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [bgTop, bgBottom], // من أزرق فاتح لأغمق
              ),
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
            child: _LogoutPill(onTap: _appLogoutToIntroOnly),
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
      return LayoutBuilder(
        builder: (context, c) => _introPage(c),
      );
    }

    // ── step -2: شاشة رقم الغرفة ────────────────────────
    if (step == -2) {
      return LayoutBuilder(
        builder: (context, c) => _roomPage(c),
      );
    }

    // ── step 0: اختيار سعة الكيس ────────────────────────
    if (step == 0) {
      return LayoutBuilder(
        builder: (context, c) {
          return Column(
            children: [
              const SizedBox(height: 10),
              const _Header(title1: 'SELECT', title2: 'CAPACITY'),
              const SizedBox(height: 26),
              // عرض زر لكل حجم متاح
              ...kCapacities.map(
                    (cap) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _BigPillButton(
                    text: cap.label,
                    onTap: () {
                      setState(() {
                        selectedCapacityMl = cap.ml; // احفظ الاختيار
                        step = 1; // انتقل لاختيار المجموعة
                      });
                    },
                  ),
                ),
              ),
              const Spacer(),
              // شعار التطبيق في المنتصف
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 170,
                  fit: BoxFit.contain,
                ),
              ),
              const Spacer(),
              _BottomBar(
                showBack: true,
                showSend: false,
                onBack: () => setState(() => step = -2), // ارجع لشاشة الغرفة
                onSend: () {},
              ),
            ],
          );
        },
      );
    }

    // ── step 1: اختيار مجموعة السوائل ───────────────────
    if (step == 1) {
      return Column(
        children: [
          const SizedBox(height: 10),
          const _Header(title1: 'SELECT', title2: 'GROUP'),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                // نعرض زر لكل مجموعة من kFluidGroups
                for (int i = 0; i < kFluidGroups.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _BigPillButton(
                      text: kFluidGroups[i].title,
                      onTap: () {
                        setState(() {
                          selectedGroupIndex = i;     // رقم المجموعة (0-based)
                          selectedGroupNum = i + 1;   // رقم للجهاز (1-based)
                          step = 2; // انتقل لاختيار نوع السائل
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _BottomBar(
            showBack: true,
            showSend: false,
            onBack: () => setState(() => step = 0), // ارجع لاختيار السعة
            onSend: () {},
          ),
        ],
      );
    }

    // ── step 2: اختيار نوع السائل ───────────────────────
    if (step == 2) {
      // نجيب المجموعة المختارة عشان نعرض أنواعها
      final g = kFluidGroups[selectedGroupIndex ?? 0];
      return Column(
        children: [
          const SizedBox(height: 10),
          const _Header(title1: 'SELECT', title2: 'FLUID TYPE'),
          const SizedBox(height: 14),
          Expanded(
            child: ListView(
              children: [
                // نعرض زر لكل نوع سائل داخل المجموعة المختارة
                for (final item in g.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _BigPillButton(
                      text: item,
                      onTap: () {
                        setState(() {
                          selectedFluid = item;
                          selectedItemNum = g.items.indexOf(item) + 1; // رقم للجهاز (1-based)
                          step = 3; // انتقل للملخص
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _BottomBar(
            showBack: true,
            showSend: false,
            onBack: () => setState(() => step = 1), // ارجع لاختيار المجموعة
            onSend: () {},
          ),
        ],
      );
    }

    // ── step 3: ملخص الاختيارات قبل الإرسال ─────────────
    if (step == 3) {
      return Column(
        children: [
          const SizedBox(height: 10),
          const _Header(title1: 'DONE', title2: 'SUMMARY'),
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
                  'Group: ${selectedGroupIndex != null ? kFluidGroups[selectedGroupIndex!].title : ''}',
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
          _BottomBar(
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
      'capacity_ml': cap,   // سعة الكيس
      'group': selectedGroupNum, // رقم المجموعة
      'item': selectedItemNum,   // رقم السائل داخل المجموعة
      'room': room,              // رقم الغرفة
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

  // ============================================================
  // شاشة تسجيل الدخول (step -1)
  // ============================================================
  Widget _introPage(BoxConstraints c) {
    return Stack(
      children: [
        // خلفية بيضاء
        const Positioned.fill(
          child: ColoredBox(color: Colors.white),
        ),
        // صورة كيس السيروم في الخلفية (يمين أسفل)
        // IgnorePointer عشان ما تستقبل اللمسات وتتعارض مع حقول الإدخال
        Positioned(
          right: -30,
          bottom: -20,
          child: IgnorePointer(
            child: Image.asset(
              'assets/images/ivbag.jpg',
              width: c.maxWidth * 0.95,
              fit: BoxFit.contain,
            ),
          ),
        ),
        // حقول الإدخال وزر المتابعة
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 24),
            child: SizedBox(
              width: c.maxWidth * 0.85,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _IntroField(controller: nurseNameCtrl, hint: 'Nurse Name'),
                  const SizedBox(height: 18),
                  _IntroField(
                    controller: nursePhoneCtrl,
                    hint: '+964XXXXXXXXXX',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: 260,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005BA7),
                        shape: const StadiumBorder(),
                        elevation: 6,
                      ),
                      onPressed: () async {
                        final name = nurseNameCtrl.text.trim();
                        final phone = nursePhoneCtrl.text.trim();

                        // تحقق إن الاسم مو فاضي
                        if (name.isEmpty) {
                          _showMsg('Please fill name');
                          return;
                        }

                        // الكود الحقيقي لإرسال بيانات الممرضة للجهاز (معلّق):
                        // try {
                        //   final uri = Uri.parse('$espBaseUrl/intro');
                        //   final res = await http.post(
                        //     uri,
                        //     headers: {'Content-Type': 'application/json'},
                        //     body: jsonEncode({'name': name, 'phone': phone}),
                        //   );
                        //   if (res.statusCode == 200) { ... } else { ... }
                        // } catch (e) { _showMsg('Error: $e'); }

                        _showMsg('Saved ✅');

                        // _lastRunning = false → انتقل لإعداد جديد (step -2)
                        // _lastRunning = true  → يعني الجهاز كان شغّال قبل
                        //                        (مثلاً الممرضة خرجت وعادت)
                        //                        فنرجعها مباشرة للمراقبة (step 5)
                        _lastRunning = false;

                        if (!mounted) return;

                        if (_lastRunning == true) {
                          setState(() => step = 5); // رجوع للمراقبة
                          if (!_running) _startLiveUpdates();
                        } else {
                          setState(() => step = -2); // انتقل لشاشة الغرفة
                        }
                      },
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // شاشة رقم الغرفة (step -2)
  // ============================================================
  Widget _roomPage(BoxConstraints c) {
    const Color roomColor = Color(0xFF396B70); // لون مخصص لهذي الشاشة

    return Stack(
      children: [
        // صورة خلفية غرفة المستشفى
        Positioned.fill(
          child: Image.asset(
            'assets/images/room.jpg',
            fit: BoxFit.cover,
          ),
        ),
        // طبقة شفافة فوق الصورة لتحسين وضوح النص
        Positioned.fill(
          child: Container(
            color: Colors.white.withOpacity(0.12),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Room number\ud83e\udd23', // النص + إيموجي مستشفى
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: roomColor,
                ),
              ),
              const SizedBox(height: 16),
              // حقل إدخال رقم الغرفة
              Container(
                width: 260,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: roomColor, width: 2),
                ),
                alignment: Alignment.center,
                child: TextField(
                  controller: roomCtrl,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: roomColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter room',
                    hintStyle: TextStyle(
                      color: roomColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 220,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: roomColor,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {
                    final room = roomCtrl.text.trim();
                    if (room.isEmpty) {
                      _showMsg('Please enter room number');
                      return;
                    }
                    setState(() => step = 0); // انتقل لاختيار السعة
                  },
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Widgets مستقلة (Reusable Components)
// ============================================================

// ── عنوان الشاشة ─────────────────────────────────────────
// يعرض سطر من كلمتين — الأولى زرقاء والثانية بيضاء
// مثال: "SELECT" (أزرق) + "CAPACITY" (أبيض)
class _Header extends StatelessWidget {
  final String title1; // الجزء الأزرق
  final String title2; // الجزء الأبيض

  const _Header({required this.title1, required this.title2});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        // RichText يسمح لنا بتلوين كل كلمة بشكل مستقل
        text: TextSpan(
          style: const TextStyle(fontSize: 26),
          children: [
            TextSpan(
              text: '$title1 ',
              style: const TextStyle(
                color: Color(0xFF005BA7),
                fontWeight: FontWeight.w800,
              ),
            ),
            TextSpan(
              text: title2,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── زر الاختيار الكبير المستدير ──────────────────────────
// يستخدم في كل شاشات الاختيار (السعة، المجموعة، النوع)
// Material + InkWell أفضل من ElevatedButton لأنه يعطي تحكم كامل بالشكل
class _BigPillButton extends StatelessWidget {
  final String text;       // النص على الزر
  final VoidCallback onTap; // الدالة التي تُستدعى عند الضغط

  const _BigPillButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.9),
      shape: const StadiumBorder(), // شكل بيضاوي/Pill
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(), // تأثير الموجة يتبع الشكل
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF25406B),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

// ── شريط الأزرار السفلي ───────────────────────────────────
// يظهر في أسفل شاشات الإعداد (0-3)
// يحتوي زر Back (دائماً يسار) + زر Send (في المنتصف، يظهر فقط في step 3)
class _BottomBar extends StatelessWidget {
  final bool showBack; // هل نعرض زر Back؟
  final bool showSend; // هل نعرض زر Send؟
  final VoidCallback onBack;
  final VoidCallback onSend;

  const _BottomBar({
    required this.showBack,
    required this.showSend,
    required this.onBack,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showBack)
            Align(
              alignment: Alignment.centerLeft,
              child: _BottomBack(onTap: onBack),
            ),
          if (showSend)
            Align(
              alignment: Alignment.center,
              child: _SendButton(onTap: onSend),
            ),
        ],
      ),
    );
  }
}

// ── زر Back ───────────────────────────────────────────────
class _BottomBack extends StatelessWidget {
  final VoidCallback onTap;
  const _BottomBack({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Text(
            'Back',
            style: TextStyle(
              color: Color(0xFF25406B),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

// ── زر Send ───────────────────────────────────────────────
// يظهر فقط في شاشة الملخص (step 3)
// لونه رمادي عشان يبيّن إنه إجراء نهائي
class _SendButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SendButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF9E9E9E), // رمادي
      shape: const StadiumBorder(),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 14),
          child: Text(
            'Send',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

// ── حقل الإدخال في شاشة الدخول ───────────────────────────
// مخصص للاسم ورقم الهاتف
// نفصله عن الـ TextField العادي عشان له ستايل موحد ونستخدمه مرتين
class _IntroField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;                        // النص التوضيحي
  final TextInputType? keyboardType;        // نوع لوحة المفاتيح (اختياري)

  const _IntroField({
    required this.controller,
    required this.hint,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Color(0xFF25406B),
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF25406B),
            fontWeight: FontWeight.w700,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF25406B), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF005BA7), width: 2.5),
          ),
        ),
      ),
    );
  }
}

// ── زر Logout العائم ──────────────────────────────────────
// يظهر في الزاوية العلوية اليسرى في كل الشاشات ما عدا شاشة الدخول
// Positioned في build() يضعه فوق كل شيء
class _LogoutPill extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const StadiumBorder(),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Text(
            'Logout',
            style: TextStyle(
              color: Color(0xFF25406B),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}