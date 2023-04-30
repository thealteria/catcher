class LocalizationOptions {
  final String languageCode;
  final String notificationReportModeTitle;
  final String notificationReportModeContent;

  final String dialogReportModeTitle;
  final String dialogReportModeDescription;
  final String dialogReportModeAccept;
  final String dialogReportModeCancel;

  final String pageReportModeTitle;
  final String pageReportModeDescription;
  final String pageReportModeAccept;
  final String pageReportModeCancel;

  LocalizationOptions(
    this.languageCode, {
    this.notificationReportModeTitle = "Application error occurred",
    this.notificationReportModeContent =
        "Click here to send error report to support team.",
    this.dialogReportModeTitle = "Crash",
    this.dialogReportModeDescription =
        "Unexpected error occurred in application. Error report is ready to send to support team. Please click Accept to send error report or Cancel to dismiss report.",
    this.dialogReportModeAccept = "Accept",
    this.dialogReportModeCancel = "Cancel",
    this.pageReportModeTitle = "Crash",
    this.pageReportModeDescription =
        "Unexpected error occurred in application. Error report is ready to send to support team. Please click Accept to send error report or Cancel to dismiss report.",
    this.pageReportModeAccept = "Accept",
    this.pageReportModeCancel = "Cancel",
  });

  static LocalizationOptions buildDefaultEnglishOptions() {
    return LocalizationOptions("en");
  }

  static LocalizationOptions buildDefaultHindiOptions() {
    return LocalizationOptions(
      "hi",
      notificationReportModeTitle: "एप्लिकेशन त्रुटि हुई",
      notificationReportModeContent:
          "समर्थन टीम को त्रुटि रिपोर्ट भेजने के लिए यहां क्लिक करें।.",
      dialogReportModeTitle: "दुर्घटना",
      dialogReportModeDescription:
          "आवेदन में अप्रत्याशित त्रुटि हुई। त्रुटि रिपोर्ट समर्थन टीम को भेजने के लिए तैयार है। कृपया त्रुटि रिपोर्ट भेजने के लिए स्वीकार करें या रिपोर्ट को रद्द करने के लिए रद्द करें पर क्लिक करें।",
      dialogReportModeAccept: "स्वीकार करना",
      dialogReportModeCancel: "रद्द करना",
      pageReportModeTitle: "दुर्घटना",
      pageReportModeDescription:
          "आवेदन में अप्रत्याशित त्रुटि हुई। त्रुटि रिपोर्ट समर्थन टीम को भेजने के लिए तैयार है। कृपया त्रुटि रिपोर्ट भेजने के लिए स्वीकार करें या रिपोर्ट को रद्द करने के लिए रद्द करें पर क्लिक करें।",
      pageReportModeAccept: "स्वीकार करना",
      pageReportModeCancel: "रद्द करना",
    );
  }

  ///Helper method used to copy values of current LocalizationOptions with new
  ///values passed in method.
  LocalizationOptions copyWith({
    String? languageCode,
    String? notificationReportModeTitle,
    String? notificationReportModeContent,
    String? dialogReportModeTitle,
    String? dialogReportModeDescription,
    String? dialogReportModeAccept,
    String? dialogReportModeCancel,
    String? pageReportModeTitle,
    String? pageReportModeDescription,
    String? pageReportModeAccept,
    String? pageReportModeCancel,
  }) {
    return LocalizationOptions(
      languageCode ?? this.languageCode,
      notificationReportModeTitle:
          notificationReportModeTitle ?? this.notificationReportModeTitle,
      notificationReportModeContent:
          notificationReportModeContent ?? this.notificationReportModeContent,
      dialogReportModeTitle:
          dialogReportModeTitle ?? this.dialogReportModeTitle,
      dialogReportModeDescription:
          dialogReportModeDescription ?? this.dialogReportModeDescription,
      dialogReportModeAccept:
          dialogReportModeAccept ?? this.dialogReportModeAccept,
      dialogReportModeCancel:
          dialogReportModeCancel ?? this.dialogReportModeCancel,
      pageReportModeTitle: pageReportModeTitle ?? this.pageReportModeTitle,
      pageReportModeDescription:
          pageReportModeDescription ?? this.pageReportModeDescription,
      pageReportModeAccept: pageReportModeAccept ?? this.pageReportModeAccept,
      pageReportModeCancel: pageReportModeCancel ?? this.pageReportModeCancel,
    );
  }
}
