import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'arb/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Headline of Capture Page
  ///
  /// In en, this message translates to:
  /// **'How was your experience?'**
  String get captureTitle;

  /// Message displayed under headline on Capture Page
  ///
  /// In en, this message translates to:
  /// **'Let us know by rating it.'**
  String get captureMessage;

  /// Label of lowest score on Capture Page
  ///
  /// In en, this message translates to:
  /// **'Not a fan'**
  String get captureMinLabel;

  /// Label of highest score on Capture Page
  ///
  /// In en, this message translates to:
  /// **'Love it!'**
  String get captureMaxLabel;

  /// Text displayed on submit button on Capture Page
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Text saying thank you
  ///
  /// In en, this message translates to:
  /// **'Thank you!'**
  String get thankYou;

  /// Message displayed on submit of feedback
  ///
  /// In en, this message translates to:
  /// **'Your feedback has been submitted.'**
  String get feedbackSubmittedMessage;

  /// Quick chip
  ///
  /// In en, this message translates to:
  /// **'Quick'**
  String get quickResponse;

  /// Great UI chip
  ///
  /// In en, this message translates to:
  /// **'Great UI'**
  String get greatUIResponse;

  /// Friendly chip
  ///
  /// In en, this message translates to:
  /// **'Friendly'**
  String get friendlyResponse;

  /// Fun chip
  ///
  /// In en, this message translates to:
  /// **'Fun!'**
  String get funResponse;

  /// Responsive chip
  ///
  /// In en, this message translates to:
  /// **'Responsive'**
  String get responsiveResponse;

  /// Simple chip
  ///
  /// In en, this message translates to:
  /// **'Simple'**
  String get simpleResponse;

  /// Bug-free chip
  ///
  /// In en, this message translates to:
  /// **'Bug-Free'**
  String get bugFreeResponse;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
