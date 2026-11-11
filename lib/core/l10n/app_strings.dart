import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// اللغة الحالية (الافتراضي: عربي). التصميم المعتمد عربي فقط حالياً.
final localeProvider = StateProvider<Locale>((_) => const Locale('ar'));

const _ar = <String, String>{
  // عام
  'soon': 'قريباً',
  'notFound': 'لم يتم العثور على الشكوى',
  'hello': 'مرحباً،',
  'viewDetails': 'عرض التفاصيل',

  // التنقل
  'navHome': 'الرئيسية',
  'navMap': 'الخريطة',
  'navMine': 'شكاواي',
  'navMore': 'المزيد',
  'navComplaints': 'الشكاوى',
  'navProfile': 'الملف الشخصي',

  // حالات
  'statusNew': 'جديدة',
  'statusWaiting': 'قيد الانتظار',
  'statusProgress': 'قيد المعالجة',
  'statusDone': 'تم الإنجاز',

  // دخول
  'appSubtitle': 'لوحة موظف البلدية',
  'nationalId': 'الرقم الوطني',
  'password': 'كلمة المرور',
  'login': 'تسجيل الدخول',
  'devCitizen': 'دخول تجريبي كمواطن (DEV)',

  // رئيسية المواطن
  'citizenTagline': 'ساهم معنا في جعل مدينتك أفضل.',
  'heroTitle': 'لاحظت مشكلة في الشارع؟',
  'heroSub': 'صوّر المشكلة وحدد موقعها وساعد في تحسين مدينتك.',
  'mySummary': 'ملخص شكاواي',
  'viewAllMine': 'عرض جميع شكاواي',
  'latestUpdate': 'آخر تحديث على شكواك',
  'lastUpdated': 'آخر تحديث:',
  'twoHoursAgo': 'قبل ساعتين',
  'nearbyAlerts': 'تنبيهات بالقرب من أماكنك المحفوظة',
  'nearUni': 'بالقرب من جامعة اليرموك',
  'potholeHigh': 'حفرة في الشارع — أولوية عالية',
  'distance300': 'على بُعد 300 متر',
  'viewOnMap': 'عرض على الخريطة',
  'manageSaved': 'إدارة الأماكن المحفوظة',
  'routeTitle': 'قبل ما تطلع، افحص طريقك!',
  'routeSub': 'اعرف المشاكل المسجلة عبر طريقك قبل الانطلاق.',
  'checkRoute': 'فحص الطريق',

  // رئيسية الموظف
  'officerRegion': 'موظف منطقة',
  'newComplaints': 'شكاوى جديدة',
  'inProgress': 'قيد المعالجة',
  'done': 'تم الإنجاز',
  'viewMap': 'عرض خريطة الشكاوى',
  'latest': 'أحدث الشكاوى',

  // قوائم
  'reportsTitle': 'جميع الشكاوى',
  'tabAll': 'جميع الشكاوى',
  'tabNew': 'جديدة',
  'tabProgress': 'قيد المعالجة',
  'tabDone': 'تم الإنجاز',
  'empty': 'لا توجد شكاوى',
  'mapTitle': 'خريطة الشكاوى',

  // تفاصيل
  'detailsTitle': 'تفاصيل الشكوى',
  'category': 'نوع المشكلة',
  'aiResult': 'نتيجة تحليل الذكاء الاصطناعي',
  'priority': 'الأولوية',
  'priorityHigh': 'عالية',
  'priorityMedium': 'متوسطة',
  'priorityLow': 'منخفضة',
  'location': 'الموقع',
  'dateTime': 'التاريخ والوقت',
  'description': 'الوصف',
  'updateStatusBtn': 'تحديث حالة الشكوى',

  // تحديث الحالة
  'updateTitle': 'تحديث حالة الشكوى',
  'newStatus': 'الحالة الجديدة',
  'noteOptional': 'ملاحظة (اختياري)',
  'noteHint': 'أضف ملاحظة حول التحديث...',
  'addPhotoOptional': 'إضافة صورة بعد الإصلاح (اختياري)',
  'choosePhoto': 'التقط صورة',
  'saveUpdate': 'حفظ التحديث',
  'updatedOk': 'تم تحديث حالة الشكوى',
  'savedOk': 'تم حفظ التحديث بنجاح',
  'backToDetails': 'العودة إلى التفاصيل',

  // الملف الشخصي
  'profile': 'الملف الشخصي',
  'editData': 'تعديل بياناتي',
  'changePass': 'تغيير كلمة المرور',
  'notifications': 'الإشعارات',
  'help': 'المساعدة والدعم',
  'logout': 'تسجيل الخروج',
  'citizen': 'مواطن',
  'employee': 'موظف بلدية',
  'regionWord': 'منطقة',

  // إشعارات
  'markAllRead': 'تعليم الكل كمقروء',
  'noNotifications': 'لا توجد إشعارات',

  // تقديم شكوى
  'newComplaint': 'تقديم شكوى جديدة',
  'descHint': 'اشرح المشكلة باختصار...',
  'locationHint': 'العنوان أو أقرب معلم',
  'addPhoto': 'إضافة صورة',
  'camera': 'الكاميرا',
  'gallery': 'المعرض',
  'submit': 'إرسال الشكوى',
  'required': 'هذا الحقل مطلوب',
  'pickCategory': 'اختر نوع المشكلة',
  'submitted': 'تم إرسال شكواك بنجاح',
  'analyzing': 'قيد التحليل',
  'photoError': 'تعذّر الوصول إلى الصورة',
  'fixPhoto': 'صورة بعد الإصلاح',

  // أماكن محفوظة
  'savedPlaces': 'الأماكن المحفوظة',
  'addPlace': 'إضافة مكان',
  'placeName': 'اسم المكان',
  'add': 'إضافة',
  'cancel': 'إلغاء',
  'noPlaces': 'لا توجد أماكن محفوظة',
  'savedHint': 'ستصلك تنبيهات عند وجود شكاوى قريبة من هذه الأماكن.',

  // فحص الطريق
  'from': 'من',
  'to': 'إلى',
  'check': 'افحص الطريق',
  'routeResults': 'مشاكل مسجلة على طريقك',
  'noIssues': 'لا توجد مشاكل مسجلة على طريقك',
  'demoResult': 'نتيجة تجريبية: سيُربط الفحص بمسار الخريطة الحقيقي لاحقاً.',

  // بحث وتصفية
  'searchHint': 'ابحث برقم الشكوى أو العنوان...',
  'filterTitle': 'تصفية الشكاوى',
  'myLocation': 'موقعك الحالي',
  'layerChanged': 'تم تغيير نمط الخريطة',

  // ملف شخصي
  'editTitle': 'تعديل بياناتي',
  'fullName': 'الاسم الكامل',
  'region': 'المنطقة',
  'save': 'حفظ',
  'saved': 'تم الحفظ',
  'curPass': 'كلمة المرور الحالية',
  'newPass': 'كلمة المرور الجديدة',
  'confirmPass': 'تأكيد كلمة المرور',
  'passShort': '8 أحرف على الأقل',
  'passMismatch': 'كلمتا المرور غير متطابقتين',
  'passChanged': 'تم تغيير كلمة المرور',
  'helpTitle': 'المساعدة والدعم',
  'faq1q': 'كيف أقدّم شكوى؟',
  'faq1a': 'اضغط زر ＋ في الشريط السفلي، اختر نوع المشكلة، أضف وصفاً وصورة وموقعاً ثم اضغط «إرسال الشكوى».',
  'faq2q': 'كيف أتابع حالة شكواي؟',
  'faq2a': 'من تبويب «شكاواي» افتح الشكوى لترى حالتها: جديدة، قيد المعالجة، أو تم الإنجاز. وتصلك إشعارات عند كل تحديث.',
  'faq3q': 'ما معنى الأماكن المحفوظة؟',
  'faq3a': 'أماكن تهمّك (مثل منزلك أو جامعتك). نُنبّهك عند تسجيل شكاوى بالقرب منها.',
  'faq4q': 'كم يستغرق حل الشكوى؟',
  'faq4a': 'يعتمد على الأولوية التي يحددها النظام ونوع المشكلة. ستجد التحديثات في صفحة الشكوى.',

  // قائمة الموظف
  'menu': 'القائمة',
};

const _strings = <String, Map<String, String>>{'ar': _ar};

extension Tr on BuildContext {
  String tr(String key) {
    final lang = Localizations.localeOf(this).languageCode;
    return _strings[lang]?[key] ?? _ar[key] ?? key;
  }
}
