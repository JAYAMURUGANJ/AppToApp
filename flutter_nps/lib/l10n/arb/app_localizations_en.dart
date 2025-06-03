// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get captureTitle => 'How was your experience?';

  @override
  String get captureMessage => 'Let us know by rating it.';

  @override
  String get captureMinLabel => 'Not a fan';

  @override
  String get captureMaxLabel => 'Love it!';

  @override
  String get submit => 'Submit';

  @override
  String get thankYou => 'Thank you!';

  @override
  String get feedbackSubmittedMessage => 'Your feedback has been submitted.';

  @override
  String get quickResponse => 'Quick';

  @override
  String get greatUIResponse => 'Great UI';

  @override
  String get friendlyResponse => 'Friendly';

  @override
  String get funResponse => 'Fun!';

  @override
  String get responsiveResponse => 'Responsive';

  @override
  String get simpleResponse => 'Simple';

  @override
  String get bugFreeResponse => 'Bug-Free';
}
