import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_ar.dart';
import 'app_localizations_az.dart';
import 'app_localizations_bg.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_bs.dart';
import 'app_localizations_ckb.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_da.dart';
import 'app_localizations_de.dart';
import 'app_localizations_dv.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_fil.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_ha.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_km.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ku.dart';
import 'app_localizations_ky.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_my.dart';
import 'app_localizations_nb.dart';
import 'app_localizations_ne.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_ps.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sd.dart';
import 'app_localizations_si.dart';
import 'app_localizations_so.dart';
import 'app_localizations_sq.dart';
import 'app_localizations_sr.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_sw.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';
import 'app_localizations_tg.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tk.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_ug.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_uz.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_yo.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('ar'),
    Locale('az'),
    Locale('bg'),
    Locale('bn'),
    Locale('bs'),
    Locale('ckb'),
    Locale('cs'),
    Locale('da'),
    Locale('de'),
    Locale('dv'),
    Locale('el'),
    Locale('en'),
    Locale('es'),
    Locale('fa'),
    Locale('fi'),
    Locale('fil'),
    Locale('fr'),
    Locale('gu'),
    Locale('ha'),
    Locale('hi'),
    Locale('hu'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('kk'),
    Locale('km'),
    Locale('kn'),
    Locale('ko'),
    Locale('ku'),
    Locale('ky'),
    Locale('ml'),
    Locale('mr'),
    Locale('ms'),
    Locale('my'),
    Locale('nb'),
    Locale('ne'),
    Locale('nl'),
    Locale('pa'),
    Locale('pl'),
    Locale('ps'),
    Locale('pt'),
    Locale('ro'),
    Locale('ru'),
    Locale('sd'),
    Locale('si'),
    Locale('so'),
    Locale('sq'),
    Locale('sr'),
    Locale('sv'),
    Locale('sw'),
    Locale('ta'),
    Locale('te'),
    Locale('tg'),
    Locale('th'),
    Locale('tk'),
    Locale('tr'),
    Locale('ug'),
    Locale('uk'),
    Locale('ur'),
    Locale('uz'),
    Locale('vi'),
    Locale('yo'),
    Locale('zh'),
  ];

  /// The app name. Usually left untranslated (proper noun).
  ///
  /// In en, this message translates to:
  /// **'Wird'**
  String get appTitle;

  /// Generic 'Continue' / 'Next' button used across onboarding and the session flow.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// Generic 'Start' call-to-action.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get commonStart;

  /// Generic 'Cancel' action button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Generic 'Save' action button.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// Generic 'Delete' action button.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// Generic 'Done' action button.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// Generic 'Close' action button.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// Generic 'Search' placeholder or label.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// Settings navigation item or screen title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get commonSettings;

  /// Bottom navigation bar item for Today screen.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// Bottom navigation bar item for Quran tab.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get navQuran;

  /// Bottom navigation bar item for Hadith hub.
  ///
  /// In en, this message translates to:
  /// **'Hadith'**
  String get navHadith;

  /// Quran hub card title shown once the user has a saved reading position.
  ///
  /// In en, this message translates to:
  /// **'Continue Reading'**
  String get readerContinueReading;

  /// Quran hub card title shown on first boot before any reading position exists.
  ///
  /// In en, this message translates to:
  /// **'Start Reading'**
  String get readerStartReading;

  /// Memorization session step indicator, e.g. 'Step 3 of 7'.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String progressStepOf(int current, int total);

  /// Locked-achievement progress hint, e.g. '5 / 7'. Usually just digits+slash; translate only if the language needs different numerals/format.
  ///
  /// In en, this message translates to:
  /// **'{current} / {target}'**
  String achievementProgress(int current, int target);

  /// Settings line showing when the last automatic local backup ran.
  ///
  /// In en, this message translates to:
  /// **'Last automatic backup: {date}'**
  String backupLastAuto(String date);

  /// Settings screen title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Language selection option in Settings.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Theme mode selection option in Settings.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// Backup section title in Settings.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get settingsBackup;

  /// Snackbar notice when monthly automatic backup succeeds.
  ///
  /// In en, this message translates to:
  /// **'Monthly backup saved to this device'**
  String get settingsMonthlyBackupNotice;

  /// Bottom navigation bar item for Home tab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom navigation bar item for Explore tab.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// Bottom navigation bar item for Duas tab.
  ///
  /// In en, this message translates to:
  /// **'Duas'**
  String get navDuas;

  /// Bottom navigation bar item for More tab.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// Bottom navigation bar item for Al-Manhaj tab.
  ///
  /// In en, this message translates to:
  /// **'Al-Manhaj'**
  String get navAlManhaj;

  /// Tooltip for profile button in home header.
  ///
  /// In en, this message translates to:
  /// **'Profile & settings'**
  String get headerProfileTooltip;

  /// Tooltip for reminders bell button in home header.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get headerRemindersTooltip;

  /// Section header title for location selection.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationTitle;

  /// Loading state indicator for location.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get locationLoading;

  /// Button label to auto-detect device location.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get locationUseMyLocation;

  /// Button label to open city selection dialog.
  ///
  /// In en, this message translates to:
  /// **'Choose city'**
  String get locationChooseCity;

  /// Button label while detecting GPS location.
  ///
  /// In en, this message translates to:
  /// **'Detecting…'**
  String get locationDetecting;

  /// Page title on Today progress screen.
  ///
  /// In en, this message translates to:
  /// **'My Progress'**
  String get todayMyProgress;

  /// Default Islamic greeting.
  ///
  /// In en, this message translates to:
  /// **'Assalamu alaikum'**
  String get todayGreeting;

  /// Status when all daily items are finished.
  ///
  /// In en, this message translates to:
  /// **'All done for today'**
  String get todayAllDone;

  /// Button to start daily session.
  ///
  /// In en, this message translates to:
  /// **'Start Session'**
  String get todayStartSession;

  /// Card action to continue reading Quran.
  ///
  /// In en, this message translates to:
  /// **'Continue reading'**
  String get todayContinueReading;

  /// Title for 7-day activity chart.
  ///
  /// In en, this message translates to:
  /// **'Key Insights'**
  String get todayKeyInsights;

  /// Title for Explore hub screen.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreTitle;

  /// Section title for Duas & Adhkar in Explore.
  ///
  /// In en, this message translates to:
  /// **'Duas & Adhkar'**
  String get exploreSectionDuasAdhkar;

  /// Card title for Daily Adhkar.
  ///
  /// In en, this message translates to:
  /// **'Daily Adhkar'**
  String get exploreDailyAdhkarTitle;

  /// Card description for Daily Adhkar.
  ///
  /// In en, this message translates to:
  /// **'Morning & Evening Remembrance'**
  String get exploreDailyAdhkarDesc;

  /// Card title for Dua collections.
  ///
  /// In en, this message translates to:
  /// **'Dua Collections'**
  String get exploreDuaCollectionsTitle;

  /// Card description for Dua collections.
  ///
  /// In en, this message translates to:
  /// **'Supplications by Circumstance'**
  String get exploreDuaCollectionsDesc;

  /// Title for More screen.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreTitle;

  /// Section title on More screen.
  ///
  /// In en, this message translates to:
  /// **'Your Journey'**
  String get moreYourJourney;

  /// Card title for Progress on More screen.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get moreProgressTitle;

  /// Card description for Progress on More screen.
  ///
  /// In en, this message translates to:
  /// **'Your heatmap, streaks, and totals'**
  String get moreProgressDesc;

  /// Card title for Achievements on More screen.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get moreAchievementsTitle;

  /// Card description for Achievements on More screen.
  ///
  /// In en, this message translates to:
  /// **'Milestones unlocked on your journey'**
  String get moreAchievementsDesc;

  /// Title for Qibla compass screen.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get qiblaTitle;

  /// Title for Zakah screen.
  ///
  /// In en, this message translates to:
  /// **'Zakah calculator'**
  String get zakahTitle;

  /// Title for Tasbih screen.
  ///
  /// In en, this message translates to:
  /// **'Tasbih'**
  String get tasbihTitle;

  /// Title for Quran screen.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get quranTitle;

  /// Title for Quran hub screen.
  ///
  /// In en, this message translates to:
  /// **'The Holy Quran'**
  String get quranHubTitle;

  /// Title for Progress screen.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTitle;

  /// Title for Knowledge Library screen.
  ///
  /// In en, this message translates to:
  /// **'Knowledge Library'**
  String get knowledgeLibraryTitle;

  /// Title for Hadith collections screen.
  ///
  /// In en, this message translates to:
  /// **'Hadith Collections'**
  String get hadithCollectionsTitle;

  /// Title for Search screen.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// Title for 40 Hadith Nawawi screen.
  ///
  /// In en, this message translates to:
  /// **'40 Hadith of an-Nawawi'**
  String get hadithNawawiTitle;

  /// Title for Duas screen.
  ///
  /// In en, this message translates to:
  /// **'Duas'**
  String get duasTitle;

  /// Title for 99 Names of Allah screen.
  ///
  /// In en, this message translates to:
  /// **'99 Names of Allah'**
  String get namesOfAllahTitle;

  /// Title for Library screen.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// Title for Al-Manhaj screen.
  ///
  /// In en, this message translates to:
  /// **'Al-Manhaj'**
  String get alManhajTitle;

  /// Title for Achievements screen.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsTitle;

  /// Title for Session screen.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get sessionTitle;

  /// Title for About screen.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// Title for Downloads screen.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloadsTitle;

  /// Message shown on session celebration screen.
  ///
  /// In en, this message translates to:
  /// **'Today\'s portion complete!'**
  String get celebrationPortionComplete;

  /// Section header for study and reference in Explore.
  ///
  /// In en, this message translates to:
  /// **'Study & Reference'**
  String get exploreSectionStudy;

  /// Reading hub section header above the resume/index cards.
  ///
  /// In en, this message translates to:
  /// **'Surah collections'**
  String get readingSurahCollections;

  /// Reading hub Start card subtitle when the user has not read before.
  ///
  /// In en, this message translates to:
  /// **'Begin with Al-Fatiha'**
  String get readingBeginFatiha;

  /// Reading hub Continue card button.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get readingResume;

  /// Reading hub card title: browse the full surah list.
  ///
  /// In en, this message translates to:
  /// **'Surah index'**
  String get readingSurahIndex;

  /// Reading hub Surah index card subtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse all 114 surahs'**
  String get readingBrowseAll;

  /// Reading hub Surah index card button.
  ///
  /// In en, this message translates to:
  /// **'Index list'**
  String get readingIndexList;

  /// Reading hub section header + card title for the spaced-repetition session.
  ///
  /// In en, this message translates to:
  /// **'Memorization'**
  String get readingMemorization;

  /// Reading hub Memorization card subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your spaced-repetition session'**
  String get readingMemorizationDesc;

  /// Generic Open button.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get commonOpen;

  /// Generic Browse button.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get commonBrowse;

  /// Generic Explore button.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get commonExplore;

  /// Generic Review button.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get commonReview;

  /// Generic View button.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get commonView;

  /// Explore hub search launcher placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search surahs, duas & hadiths'**
  String get exploreSearchHint;

  /// Explore section header for Zakah + Qibla.
  ///
  /// In en, this message translates to:
  /// **'Calculate & navigate'**
  String get exploreSectionCalcNavigate;

  /// Explore section header for adhkar reminders.
  ///
  /// In en, this message translates to:
  /// **'Time-aware reminders'**
  String get exploreSectionReminders;

  /// Explore section header for Tasbih + 99 Names.
  ///
  /// In en, this message translates to:
  /// **'Dhikr & devotion'**
  String get exploreSectionDhikr;

  /// Explore Hadith collections card subtitle.
  ///
  /// In en, this message translates to:
  /// **'Sahih Bukhari, Muslim & more'**
  String get exploreHadithDesc;

  /// Explore Knowledge Library card subtitle.
  ///
  /// In en, this message translates to:
  /// **'Books on Aqeedah, Fiqh, Tafsir & more'**
  String get exploreKnowledgeDesc;

  /// Explore Zakah card subtitle.
  ///
  /// In en, this message translates to:
  /// **'Calculate your obligatory Zakah'**
  String get exploreZakahDesc;

  /// Explore Zakah card button.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get exploreCalculate;

  /// Explore Qibla card subtitle.
  ///
  /// In en, this message translates to:
  /// **'Find the direction to the Ka\'bah'**
  String get exploreQiblaDesc;

  /// Explore Qibla card button.
  ///
  /// In en, this message translates to:
  /// **'Find Qibla'**
  String get exploreFindQibla;

  /// Explore morning adhkar card title.
  ///
  /// In en, this message translates to:
  /// **'Morning adhkar'**
  String get exploreMorningAdhkarTitle;

  /// Explore morning adhkar card subtitle.
  ///
  /// In en, this message translates to:
  /// **'Hisn al-Muslim morning remembrance'**
  String get exploreMorningAdhkarDesc;

  /// Explore evening adhkar card title.
  ///
  /// In en, this message translates to:
  /// **'Evening adhkar'**
  String get exploreEveningAdhkarTitle;

  /// Explore evening adhkar card subtitle.
  ///
  /// In en, this message translates to:
  /// **'Hisn al-Muslim evening remembrance'**
  String get exploreEveningAdhkarDesc;

  /// Explore adhkar card button.
  ///
  /// In en, this message translates to:
  /// **'Recite'**
  String get exploreRecite;

  /// Explore Tasbih card title.
  ///
  /// In en, this message translates to:
  /// **'Tasbih counter'**
  String get exploreTasbihTitle;

  /// Explore Tasbih card subtitle.
  ///
  /// In en, this message translates to:
  /// **'Digital counter for daily dhikr'**
  String get exploreTasbihDesc;

  /// Explore Tasbih card button.
  ///
  /// In en, this message translates to:
  /// **'Open tasbih'**
  String get exploreOpenTasbih;

  /// Explore 99 Names card subtitle.
  ///
  /// In en, this message translates to:
  /// **'Asma ul-Husna with meanings'**
  String get exploreNamesDesc;

  /// Explore 99 Names card button.
  ///
  /// In en, this message translates to:
  /// **'Open names'**
  String get exploreOpenNames;

  /// More tab section header.
  ///
  /// In en, this message translates to:
  /// **'Library & downloads'**
  String get moreLibraryDownloads;

  /// More tab: manage translation/hadith downloads card.
  ///
  /// In en, this message translates to:
  /// **'Content Library'**
  String get moreContentLibraryTitle;

  /// More Content Library card subtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage translations & collections'**
  String get moreContentLibraryDesc;

  /// More Knowledge Library card subtitle.
  ///
  /// In en, this message translates to:
  /// **'Islamic books to read offline'**
  String get moreKnowledgeDesc;

  /// More Al-Manhaj card subtitle.
  ///
  /// In en, this message translates to:
  /// **'Guided learning — coming soon'**
  String get moreAlManhajDesc;

  /// More Al-Manhaj card button.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get moreDiscover;

  /// More tab section header.
  ///
  /// In en, this message translates to:
  /// **'Settings & about'**
  String get moreSettingsAbout;

  /// More Settings tile subtitle.
  ///
  /// In en, this message translates to:
  /// **'Plan, reciter, theme, notifications'**
  String get moreSettingsSubtitle;

  /// More About tile subtitle.
  ///
  /// In en, this message translates to:
  /// **'Foundation, license, and credits'**
  String get moreAboutSubtitle;

  /// Home greeting with the user's name.
  ///
  /// In en, this message translates to:
  /// **'Assalamu alaikum, {name}'**
  String todayGreetingNamed(Object name);

  /// Home hero card when nothing remains for today.
  ///
  /// In en, this message translates to:
  /// **'Today\'s goal: done!'**
  String get todayGoalDone;

  /// Home hero card goal heading with progress.
  ///
  /// In en, this message translates to:
  /// **'Today\'s goal: {done}/{planned}'**
  String todayGoalProgress(Object done, Object planned);

  /// Home hero breakdown: new items, reviews, estimated minutes.
  ///
  /// In en, this message translates to:
  /// **'{newCount} new · {reviews} reviews · ~{minutes} min'**
  String todayBreakdown(Object newCount, Object reviews, Object minutes);

  /// Home hero streak + weekly goal line.
  ///
  /// In en, this message translates to:
  /// **'{streak} day streak · {completed}/{goal} this week'**
  String todayStreakWeek(Object streak, Object completed, Object goal);

  /// Breakdown row: new memorization.
  ///
  /// In en, this message translates to:
  /// **'Sabaq (new)'**
  String get todaySabaq;

  /// Breakdown row: recent revision.
  ///
  /// In en, this message translates to:
  /// **'Sabqi (recent revision)'**
  String get todaySabqi;

  /// Breakdown row: long-term revision.
  ///
  /// In en, this message translates to:
  /// **'Manzil (long-term revision)'**
  String get todayManzil;

  /// Home section eyebrow above the continue-reading card.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get todaySectionContinue;

  /// Home section eyebrow.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get todaySectionRecent;

  /// Home section eyebrow.
  ///
  /// In en, this message translates to:
  /// **'Streak & insights'**
  String get todaySectionStreak;

  /// Home section eyebrow above adhkar tiles.
  ///
  /// In en, this message translates to:
  /// **'Remembrance'**
  String get todaySectionRemembrance;

  /// Home section eyebrow above the tools row.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get todaySectionTools;

  /// Recent-activity row, session not yet done.
  ///
  /// In en, this message translates to:
  /// **'Today\'s session in progress'**
  String get todaySessionInProgress;

  /// Recent-activity row, session done.
  ///
  /// In en, this message translates to:
  /// **'Today\'s session completed'**
  String get todaySessionCompleted;

  /// Recent-activity row for a newly unlocked achievement.
  ///
  /// In en, this message translates to:
  /// **'Unlocked: {title}'**
  String todayUnlocked(Object title);

  /// Streak card label.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get todayCurrentStreak;

  /// Home card label for the normal Quran reading streak (distinct from the memorization streak).
  ///
  /// In en, this message translates to:
  /// **'Reading streak'**
  String get todayReadingStreak;

  /// Streak card day count.
  ///
  /// In en, this message translates to:
  /// **'{streak} days'**
  String todayStreakDays(Object streak);

  /// Key-insights empty state on a fresh install.
  ///
  /// In en, this message translates to:
  /// **'Complete a session to start\nyour 7-day activity chart'**
  String get todayInsightsEmpty;

  /// Ease-back banner after a break.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Today\'s new material is halved to help you ease back in.'**
  String get todayWelcomeBack;

  /// Al-Manhaj teaser card on Home.
  ///
  /// In en, this message translates to:
  /// **'Discover Al-Manhaj — coming soon'**
  String get todayAlManhajTeaser;

  /// Short Zakah label for the Home tools pill.
  ///
  /// In en, this message translates to:
  /// **'Zakah'**
  String get zakahShort;

  /// Reader options bottom-sheet title.
  ///
  /// In en, this message translates to:
  /// **'Reader options'**
  String get readerOptions;

  /// Reader option toggle.
  ///
  /// In en, this message translates to:
  /// **'Classic Mushaf mode'**
  String get readerMushafMode;

  /// Reader Mushaf-mode subtitle.
  ///
  /// In en, this message translates to:
  /// **'Continuous Arabic page layout'**
  String get readerMushafModeDesc;

  /// Reader option toggle.
  ///
  /// In en, this message translates to:
  /// **'Tajweed highlighting'**
  String get readerTajweed;

  /// Reader Tajweed subtitle.
  ///
  /// In en, this message translates to:
  /// **'Color-coded waqf & elongation marks'**
  String get readerTajweedDesc;

  /// Reader translation toggle + inline label.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get readerTranslation;

  /// Inline bold lead-in before the ayah translation.
  ///
  /// In en, this message translates to:
  /// **'Translation:'**
  String get readerTranslationLabel;

  /// Reader transliteration toggle.
  ///
  /// In en, this message translates to:
  /// **'Transliteration'**
  String get readerTransliteration;

  /// Reader translation-language chooser label.
  ///
  /// In en, this message translates to:
  /// **'Translation language'**
  String get readerTranslationLanguage;

  /// Reader link to the Content Library.
  ///
  /// In en, this message translates to:
  /// **'More translations in Library'**
  String get readerMoreTranslations;

  /// Reader font-size slider label.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get readerFontSize;

  /// Reader reciter picker label.
  ///
  /// In en, this message translates to:
  /// **'Reciter'**
  String get readerReciter;

  /// Reader auto-play toggle.
  ///
  /// In en, this message translates to:
  /// **'Auto-play on swipe'**
  String get readerAutoPlaySwipe;

  /// Reader auto-play subtitle.
  ///
  /// In en, this message translates to:
  /// **'Paging to another ayah plays it automatically'**
  String get readerAutoPlaySwipeDesc;

  /// SnackBar when picking an uninstalled translation language.
  ///
  /// In en, this message translates to:
  /// **'{language} isn\'t downloaded yet — get it from the Library.'**
  String readerLangNotDownloaded(Object language);

  /// Reader reciter sample-play tooltip.
  ///
  /// In en, this message translates to:
  /// **'Play sample'**
  String get readerPlaySample;

  /// Generic Download button/tooltip.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get commonDownload;

  /// Generic Read tooltip.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get commonRead;

  /// Book reader app-bar fallback title.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get bookReaderTitle;

  /// Knowledge book-list search placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search titles and authors'**
  String get bookSearchHint;

  /// Knowledge book-list empty state.
  ///
  /// In en, this message translates to:
  /// **'No books match'**
  String get bookNoMatch;

  /// Book download confirm dialog title.
  ///
  /// In en, this message translates to:
  /// **'Download book?'**
  String get bookDownloadConfirmTitle;

  /// Book download confirm dialog body.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" is {size}. It will be saved to this device for offline reading.'**
  String bookDownloadConfirmBody(Object title, Object size);

  /// Surah screen: open the paged reader tooltip.
  ///
  /// In en, this message translates to:
  /// **'Open in reader'**
  String get surahOpenInReader;

  /// Dua group screen fallback title.
  ///
  /// In en, this message translates to:
  /// **'Unknown group'**
  String get duaUnknownGroup;

  /// Hadith chapter detail search placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search by hadith number or keyword'**
  String get hadithSearchHint;

  /// Hadith chapter detail empty state.
  ///
  /// In en, this message translates to:
  /// **'No matching hadith'**
  String get hadithNoMatch;

  /// Duas tab section header.
  ///
  /// In en, this message translates to:
  /// **'Daily Adhkar'**
  String get duasDailyAdhkar;

  /// Duas tab search placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search occasions (e.g. \"travel\", \"sleep\")'**
  String get duasSearchHint;

  /// Duas tab section header for the essential shelf.
  ///
  /// In en, this message translates to:
  /// **'Essential'**
  String get duasEssential;

  /// Duas tab section header grouping occasions.
  ///
  /// In en, this message translates to:
  /// **'By circumstance'**
  String get duasByCircumstance;

  /// Duas tab search empty state.
  ///
  /// In en, this message translates to:
  /// **'No matching occasions'**
  String get duasNoMatch;

  /// Adhkar card status, done.
  ///
  /// In en, this message translates to:
  /// **'Completed today'**
  String get duasCompletedToday;

  /// Adhkar card status, pending.
  ///
  /// In en, this message translates to:
  /// **'Not done yet today'**
  String get duasNotDoneToday;

  /// Link to switch to morning adhkar.
  ///
  /// In en, this message translates to:
  /// **'View morning adhkar'**
  String get duasViewMorning;

  /// Link to switch to evening adhkar.
  ///
  /// In en, this message translates to:
  /// **'View evening adhkar'**
  String get duasViewEvening;

  /// Hadith shelf search placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search collections by book or title'**
  String get hadithSearchCollections;

  /// Count pill on a hadith collection card.
  ///
  /// In en, this message translates to:
  /// **'{count} hadiths'**
  String hadithCount(Object count);

  /// Nawawi 40 collection card subtitle.
  ///
  /// In en, this message translates to:
  /// **'Essential compilation covering core principles of Islam'**
  String get hadithNawawiDesc;

  /// Hadith collection download status.
  ///
  /// In en, this message translates to:
  /// **'Downloaded — tap to open'**
  String get hadithStatusDownloaded;

  /// Hadith collection download status.
  ///
  /// In en, this message translates to:
  /// **'Download failed — tap to retry'**
  String get hadithStatusFailed;

  /// Hadith collection download status.
  ///
  /// In en, this message translates to:
  /// **'Not downloaded'**
  String get hadithStatusNotDownloaded;

  /// Hadith collection details tooltip.
  ///
  /// In en, this message translates to:
  /// **'Collection details'**
  String get hadithCollectionDetails;

  /// Hadith list search placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search hadith'**
  String get hadithListSearch;

  /// Generic All filter chip.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get commonAll;

  /// Bookmarked filter chip.
  ///
  /// In en, this message translates to:
  /// **'Bookmarked'**
  String get commonBookmarked;

  /// Hadith list empty state.
  ///
  /// In en, this message translates to:
  /// **'No hadith match'**
  String get hadithListNoMatch;

  /// Tasbih preset section header.
  ///
  /// In en, this message translates to:
  /// **'Multi-stage remembrance'**
  String get tasbihMultiStage;

  /// Tasbih preset section header.
  ///
  /// In en, this message translates to:
  /// **'Individual dhikr presets'**
  String get tasbihIndividualPresets;

  /// Tasbih counter hint.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere'**
  String get tasbihTapAnywhere;

  /// Tasbih counter: change preset link.
  ///
  /// In en, this message translates to:
  /// **'Choose another preset'**
  String get tasbihChooseAnother;

  /// Tasbih completed count.
  ///
  /// In en, this message translates to:
  /// **'Complete — {done} / {total}'**
  String tasbihComplete(Object done, Object total);

  /// Qibla empty state.
  ///
  /// In en, this message translates to:
  /// **'Set your city to calculate the Qibla direction — the same location used for prayer times.'**
  String get qiblaSetCity;

  /// Qibla accuracy disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Based on {city} — a city-level estimate, not exact GPS.'**
  String qiblaBasedOn(Object city);

  /// Qibla bearing readout.
  ///
  /// In en, this message translates to:
  /// **'{degrees}° from North'**
  String qiblaFromNorth(Object degrees);

  /// Qibla live-compass loading.
  ///
  /// In en, this message translates to:
  /// **'Reading compass…'**
  String get qiblaReadingCompass;

  /// Qibla live heading vs bearing.
  ///
  /// In en, this message translates to:
  /// **'Facing {heading}° — Qibla is {qibla}°'**
  String qiblaFacing(Object heading, Object qibla);

  /// Compass north abbreviation.
  ///
  /// In en, this message translates to:
  /// **'N'**
  String get qiblaNorth;

  /// 99 Names search placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search by name or meaning'**
  String get asmaSearchHint;

  /// 99 Names empty state.
  ///
  /// In en, this message translates to:
  /// **'No matching name'**
  String get asmaNoMatch;

  /// Adhkar reader completion.
  ///
  /// In en, this message translates to:
  /// **'All done! 🎉'**
  String get adhkarAllDone;

  /// Adhkar reader complete button.
  ///
  /// In en, this message translates to:
  /// **'Mark as completed'**
  String get adhkarMarkCompleted;

  /// Adhkar reader restart button.
  ///
  /// In en, this message translates to:
  /// **'Read again'**
  String get adhkarReadAgain;

  /// Progress stat tile.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get progressCurrentStreak;

  /// Progress stat tile.
  ///
  /// In en, this message translates to:
  /// **'Longest streak'**
  String get progressLongestStreak;

  /// Progress stat tile.
  ///
  /// In en, this message translates to:
  /// **'Days consistent'**
  String get progressDaysConsistent;

  /// Progress stat tile: memorized ayahs.
  ///
  /// In en, this message translates to:
  /// **'Ayahs'**
  String get progressAyahs;

  /// Progress stat tile: hadith learned.
  ///
  /// In en, this message translates to:
  /// **'Hadith'**
  String get progressHadith;

  /// Progress stat tile: duas learned.
  ///
  /// In en, this message translates to:
  /// **'Duas'**
  String get progressDuas;

  /// Progress stat label.
  ///
  /// In en, this message translates to:
  /// **'Review accuracy'**
  String get progressReviewAccuracy;

  /// Progress review-accuracy empty state.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get progressNoReviews;

  /// Progress estimate label.
  ///
  /// In en, this message translates to:
  /// **'Estimated completion'**
  String get progressEstimatedCompletion;

  /// Progress estimate empty state.
  ///
  /// In en, this message translates to:
  /// **'Not enough pace data yet'**
  String get progressNoPaceData;

  /// Achievements category.
  ///
  /// In en, this message translates to:
  /// **'Quranic journey'**
  String get achievementsQuranicJourney;

  /// Achievements category.
  ///
  /// In en, this message translates to:
  /// **'Path of hadith'**
  String get achievementsPathOfHadith;

  /// Achievements category.
  ///
  /// In en, this message translates to:
  /// **'Dhikr & devotion'**
  String get achievementsDhikrDevotion;

  /// Achievements category.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get achievementsConsistency;

  /// Achievements progress header (N of M unlocked).
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get achievementsUnlocked;

  /// Knowledge Library subtitle.
  ///
  /// In en, this message translates to:
  /// **'Books published by IslamHouse, downloaded on demand.'**
  String get knowledgePublishedBy;

  /// Knowledge Library empty state for a language.
  ///
  /// In en, this message translates to:
  /// **'No books in this language yet.'**
  String get knowledgeNoBooks;

  /// Content Library section header.
  ///
  /// In en, this message translates to:
  /// **'Quran audio'**
  String get libraryQuranAudio;

  /// Content Library Quran-audio card.
  ///
  /// In en, this message translates to:
  /// **'Recitation audio downloads'**
  String get libraryRecitationDownloads;

  /// Content Library section header.
  ///
  /// In en, this message translates to:
  /// **'Quran translations'**
  String get libraryQuranTranslations;

  /// Content Library translation search placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search languages'**
  String get librarySearchLanguages;

  /// Content Library section header.
  ///
  /// In en, this message translates to:
  /// **'Hadith collections'**
  String get libraryHadithCollections;

  /// Content Library item status: complete.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get libraryDownloaded;

  /// Content Library item status: failed.
  ///
  /// In en, this message translates to:
  /// **'Download failed — tap to retry'**
  String get libraryDownloadFailed;

  /// Content Library item status: not downloaded.
  ///
  /// In en, this message translates to:
  /// **'Not downloaded'**
  String get libraryNotDownloaded;

  /// Al-Manhaj coming-soon description.
  ///
  /// In en, this message translates to:
  /// **'A structured Islamic-studies platform — coming soon, in shā’ Allah. It will offer sequenced courses grounded in the Qur’an and Sunnah upon the understanding of the Salaf: guided study tracks, vetted texts and audio, and teacher commentary — all in the same neutral, aqeedah-safe spirit as Wird.'**
  String get almanhajComingSoon;

  /// Al-Manhaj offline reassurance.
  ///
  /// In en, this message translates to:
  /// **'Wird itself stays fully offline and account-free — no sign-in, ever.'**
  String get almanhajOfflineNote;

  /// Al-Manhaj support card title.
  ///
  /// In en, this message translates to:
  /// **'Support this project'**
  String get almanhajSupportTitle;

  /// Al-Manhaj support card body.
  ///
  /// In en, this message translates to:
  /// **'Wird has no account, no ads, and no server — it stays free. If it has been useful, you can support development here:'**
  String get almanhajSupportBody;

  /// Knowledge Library discipline card: book count.
  ///
  /// In en, this message translates to:
  /// **'{count} books'**
  String knowledgeBooksCount(Object count);

  /// Generic Copy action.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get commonCopy;

  /// Generic Share action.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get commonShare;

  /// Generic Clear action.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// The word 'Surah' as a standalone label.
  ///
  /// In en, this message translates to:
  /// **'Surah'**
  String get commonSurahWord;

  /// Session screen empty state.
  ///
  /// In en, this message translates to:
  /// **'Nothing to do right now.'**
  String get sessionNothingToDo;

  /// Memorization fade step 1.
  ///
  /// In en, this message translates to:
  /// **'Read it once more, in full.'**
  String get flowReadOnceMore;

  /// Memorization fade step 2.
  ///
  /// In en, this message translates to:
  /// **'Just the first word of each line now — recall the rest.'**
  String get flowFirstWord;

  /// Memorization fade step 3.
  ///
  /// In en, this message translates to:
  /// **'Fully hidden — recall it from memory.'**
  String get flowFullyHidden;

  /// Talqin step, with audio.
  ///
  /// In en, this message translates to:
  /// **'Listen & repeat — play the recitation, or recite it yourself and press Continue when ready.'**
  String get flowListenRepeatAudio;

  /// Talqin step, no audio.
  ///
  /// In en, this message translates to:
  /// **'Listen & repeat — read the text aloud, then Continue.'**
  String get flowListenRepeatText;

  /// Session play button.
  ///
  /// In en, this message translates to:
  /// **'Play recitation'**
  String get flowPlayRecitation;

  /// Session repeat-counter hint.
  ///
  /// In en, this message translates to:
  /// **'Tap after each repeat'**
  String get flowTapAfterRepeat;

  /// Session meaning step header.
  ///
  /// In en, this message translates to:
  /// **'Meaning'**
  String get flowMeaning;

  /// Chain-recall step.
  ///
  /// In en, this message translates to:
  /// **'Chain recall — tap each line to reveal it, and recall the next one\'s beginning from the previous one\'s ending.'**
  String get flowChainRecall;

  /// Self-test step.
  ///
  /// In en, this message translates to:
  /// **'Self-test — recite it fully from memory, then reveal to check.'**
  String get flowSelfTest;

  /// Self-test reveal button.
  ///
  /// In en, this message translates to:
  /// **'Reveal'**
  String get flowReveal;

  /// Self-grade: needs more practice.
  ///
  /// In en, this message translates to:
  /// **'Needs work'**
  String get flowNeedsWork;

  /// Downloads screen web note.
  ///
  /// In en, this message translates to:
  /// **'The web app streams audio — install the Android app for offline recitation.'**
  String get downloadsWebNote;

  /// Downloads scope option.
  ///
  /// In en, this message translates to:
  /// **'My plan'**
  String get downloadsMyPlan;

  /// Downloads scope option.
  ///
  /// In en, this message translates to:
  /// **'Full Quran'**
  String get downloadsFullQuran;

  /// Downloads Wi-Fi toggle.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi only'**
  String get downloadsWifiOnly;

  /// Download status: paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get downloadsPaused;

  /// Download status: failed.
  ///
  /// In en, this message translates to:
  /// **'Failed — tap to retry'**
  String get downloadsFailed;

  /// Data sources screen title.
  ///
  /// In en, this message translates to:
  /// **'Data sources & licenses'**
  String get dataSourcesTitle;

  /// Log viewer title.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics & logs'**
  String get logsTitle;

  /// Log viewer copied toast.
  ///
  /// In en, this message translates to:
  /// **'Logs copied'**
  String get logsCopied;

  /// Log viewer empty state.
  ///
  /// In en, this message translates to:
  /// **'No logs captured yet.'**
  String get logsEmpty;

  /// Plan edit screen title.
  ///
  /// In en, this message translates to:
  /// **'Edit Quran plan'**
  String get planEditTitle;

  /// Plan edit section: what to memorize.
  ///
  /// In en, this message translates to:
  /// **'Selection'**
  String get planSelection;

  /// Plan scope option.
  ///
  /// In en, this message translates to:
  /// **'The whole Quran'**
  String get planWholeQuran;

  /// Plan scope option.
  ///
  /// In en, this message translates to:
  /// **'Specific juz (para)'**
  String get planSpecificJuz;

  /// Plan scope option.
  ///
  /// In en, this message translates to:
  /// **'Specific surahs'**
  String get planSpecificSurahs;

  /// Plan edit section: order.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get planDirection;

  /// Plan order option.
  ///
  /// In en, this message translates to:
  /// **'Normal order (start to end)'**
  String get planNormalOrder;

  /// Plan order option.
  ///
  /// In en, this message translates to:
  /// **'Reversed order (an-Nas first)'**
  String get planReversedOrder;

  /// Plan edit daily-minutes label.
  ///
  /// In en, this message translates to:
  /// **'Daily minutes'**
  String get planDailyMinutes;

  /// Plan edit save button.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get planSaveChanges;

  /// Short minutes label for chips.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String commonMinutesShort(Object count);

  /// Talqin repeat counter.
  ///
  /// In en, this message translates to:
  /// **'Repeated {done} of {target} times'**
  String flowRepeatedCount(Object done, Object target);

  /// Generic Stop button.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get commonStop;

  /// Self-grade: memorized well.
  ///
  /// In en, this message translates to:
  /// **'I\'ve got it'**
  String get flowGotIt;

  /// Reset confirm dialog title.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get settingsResetSure;

  /// Reset confirm dialog body.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone from within the app — you would need to restore the backup manually. Reset {label} progress now?'**
  String settingsResetBody(Object label);

  /// Settings section: memorization plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get settingsPlan;

  /// Settings note when plan has no Quran.
  ///
  /// In en, this message translates to:
  /// **'No Quran selection in your current plan.'**
  String get settingsNoQuranSelection;

  /// Settings theme-colour label.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get settingsColour;

  /// Settings section.
  ///
  /// In en, this message translates to:
  /// **'Prayer times'**
  String get settingsPrayerTimes;

  /// Settings section.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// Settings web notifications limitation note.
  ///
  /// In en, this message translates to:
  /// **'The web app can\'t reliably post reminders while it isn\'t open — install the Android app for daily and adhkar reminders. The Duas tab still shows which adhkar period it is right now.'**
  String get settingsWebNotifNote;

  /// Settings backup export button.
  ///
  /// In en, this message translates to:
  /// **'Export my data'**
  String get settingsExportData;

  /// Settings backup note when none yet.
  ///
  /// In en, this message translates to:
  /// **'Automatic backups run monthly on this device.'**
  String get settingsBackupsMonthly;

  /// Settings reset section header.
  ///
  /// In en, this message translates to:
  /// **'Reset progress'**
  String get settingsResetProgress;

  /// Settings reset-all button.
  ///
  /// In en, this message translates to:
  /// **'Reset everything'**
  String get settingsResetEverything;

  /// Settings About row.
  ///
  /// In en, this message translates to:
  /// **'About & data sources'**
  String get settingsAboutDataSources;

  /// Prayer-time method option.
  ///
  /// In en, this message translates to:
  /// **'Auto (based on location)'**
  String get settingsPrayerMethodAuto;

  /// Prayer-time method option.
  ///
  /// In en, this message translates to:
  /// **'Online (AlAdhan calendar)'**
  String get settingsPrayerMethodOnline;

  /// Prayer-time method option.
  ///
  /// In en, this message translates to:
  /// **'Offline (calculated on-device)'**
  String get settingsPrayerMethodOffline;

  /// Settings notification toggle.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get settingsDailyReminder;

  /// Settings reminder-time label.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get settingsReminderTime;

  /// Settings notification toggle.
  ///
  /// In en, this message translates to:
  /// **'Morning adhkar reminder'**
  String get settingsMorningReminder;

  /// Morning adhkar reminder subtitle.
  ///
  /// In en, this message translates to:
  /// **'A silent, ongoing reminder from Fajr until it\'s done'**
  String get settingsMorningReminderDesc;

  /// Settings notification toggle.
  ///
  /// In en, this message translates to:
  /// **'Evening adhkar reminder'**
  String get settingsEveningReminder;

  /// Evening adhkar reminder subtitle.
  ///
  /// In en, this message translates to:
  /// **'A silent, ongoing reminder from Asr until it\'s done'**
  String get settingsEveningReminderDesc;

  /// Settings notification toggle.
  ///
  /// In en, this message translates to:
  /// **'Streak-at-risk reminder'**
  String get settingsStreakReminder;

  /// Settings adhan-tone label.
  ///
  /// In en, this message translates to:
  /// **'Adhan tone'**
  String get settingsAdhanTone;

  /// Adhan tone picker title.
  ///
  /// In en, this message translates to:
  /// **'Choose adhan tone'**
  String get settingsChooseAdhanTone;

  /// Adhan preview button.
  ///
  /// In en, this message translates to:
  /// **'Preview adhan'**
  String get settingsPreviewAdhan;

  /// Adhan per-prayer selector intro.
  ///
  /// In en, this message translates to:
  /// **'Remind me with adhan for (needs a location set above):'**
  String get settingsRemindAdhanFor;

  /// Reset confirm dialog title (first).
  ///
  /// In en, this message translates to:
  /// **'Reset {label} progress?'**
  String settingsResetTitle(Object label);

  /// Reset confirm dialog body (first).
  ///
  /// In en, this message translates to:
  /// **'This erases your {label} memorization progress and starts it over from scratch. A backup of your current data will be exported first.'**
  String settingsResetFirstBody(Object label);

  /// Reset-progress chip per scope.
  ///
  /// In en, this message translates to:
  /// **'Reset {label}'**
  String settingsResetChip(Object label);

  /// Prayer-times source indicator.
  ///
  /// In en, this message translates to:
  /// **'Source: {source}'**
  String settingsSource(Object source);

  /// Streak-at-risk reminder subtitle.
  ///
  /// In en, this message translates to:
  /// **'A heads-up 2 hours before your reminder if today\'s portion isn\'t done yet'**
  String get settingsStreakReminderDesc;

  /// Onboarding offline-disclaimer dialog title.
  ///
  /// In en, this message translates to:
  /// **'Welcome — a quick note'**
  String get obDisclaimerTitle;

  /// Onboarding offline-disclaimer dialog body.
  ///
  /// In en, this message translates to:
  /// **'Wird is fully offline. Your progress lives on this device — you never need an account to use any part of the app.\n\nLater, you can optionally sign in with Al-Manhaj (one time) just to back up your progress to the cloud. That\'s the only thing an account does here.'**
  String get obDisclaimerBody;

  /// Generic acknowledge button.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get commonGotIt;

  /// Generic finish button.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get commonFinish;

  /// Onboarding language step title.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get obLanguageTitle;

  /// Onboarding language step subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred display language for Wird.'**
  String get obLanguageSubtitle;

  /// Onboarding welcome step title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Wird'**
  String get obWelcomeTitle;

  /// Onboarding welcome body.
  ///
  /// In en, this message translates to:
  /// **'Memorize the Quran, the 40 Hadith of an-Nawawi, and daily duas — at your own pace, fully offline.'**
  String get obWelcomeBody;

  /// Onboarding profile step title.
  ///
  /// In en, this message translates to:
  /// **'What\'s your name?'**
  String get obNameTitle;

  /// Onboarding name field label.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get obName;

  /// Onboarding avatar picker label.
  ///
  /// In en, this message translates to:
  /// **'Pick an icon'**
  String get obPickIcon;

  /// Onboarding restore button.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get obRestoreBackup;

  /// Onboarding restore error.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String obRestoreFailed(Object error);

  /// Onboarding finish error.
  ///
  /// In en, this message translates to:
  /// **'Could not finish setup: {error}'**
  String obFinishError(Object error);

  /// Onboarding scope step title.
  ///
  /// In en, this message translates to:
  /// **'What do you want to memorize?'**
  String get obScopeTitle;

  /// Onboarding scope: hadith option.
  ///
  /// In en, this message translates to:
  /// **'40 Hadith of an-Nawawi'**
  String get obScopeHadith;

  /// Onboarding scope: duas option.
  ///
  /// In en, this message translates to:
  /// **'Also start with morning/evening duas'**
  String get obScopeAlsoDuas;

  /// Onboarding duas option subtitle.
  ///
  /// In en, this message translates to:
  /// **'Adds the adhkar set to your memorization queue — you can add or remove individual duas any time from the Duas tab.'**
  String get obScopeAlsoDuasDesc;

  /// Onboarding scope validation.
  ///
  /// In en, this message translates to:
  /// **'Choose at least one of Quran or Hadith.'**
  String get obScopeChooseOne;

  /// Onboarding Quran-selection step title (skip case).
  ///
  /// In en, this message translates to:
  /// **'Quran selection'**
  String get obQuranSelTitle;

  /// Onboarding when Quran not chosen.
  ///
  /// In en, this message translates to:
  /// **'You\'ve chosen to skip Quran memorization.'**
  String get obQuranSkip;

  /// Onboarding Quran-scope step title.
  ///
  /// In en, this message translates to:
  /// **'How much of the Quran?'**
  String get obQuranHowMuch;

  /// Onboarding reversed-order explanation.
  ///
  /// In en, this message translates to:
  /// **'Reversed order follows the traditional \"from the back\" method: juz 30 first, shortest surahs first — great for building momentum early on.'**
  String get obReversedNote;

  /// Onboarding daily-time step title.
  ///
  /// In en, this message translates to:
  /// **'How much time per day?'**
  String get obTimeTitle;

  /// Onboarding pace estimate.
  ///
  /// In en, this message translates to:
  /// **'At this pace, you could finish your Quran selection in {duration}.'**
  String obPaceEstimate(Object duration);

  /// Onboarding notifications step title.
  ///
  /// In en, this message translates to:
  /// **'Stay consistent'**
  String get obConsistentTitle;

  /// Onboarding web-notifications note.
  ///
  /// In en, this message translates to:
  /// **'Notifications aren\'t available in the web app — install the Android app for reminders.'**
  String get obNotifWeb;

  /// Onboarding morning adhkar reminder subtitle.
  ///
  /// In en, this message translates to:
  /// **'30 minutes after Fajr'**
  String get obMorningReminderDesc;

  /// Onboarding evening adhkar reminder subtitle.
  ///
  /// In en, this message translates to:
  /// **'30 minutes after Asr'**
  String get obEveningReminderDesc;

  /// Onboarding adhan toggle.
  ///
  /// In en, this message translates to:
  /// **'Prayer-time adhan'**
  String get obPrayerAdhan;

  /// Onboarding adhan toggle subtitle.
  ///
  /// In en, this message translates to:
  /// **'Play the call to prayer at each of the five prayer times (needs your location; fine-tune per prayer in Settings)'**
  String get obPrayerAdhanDesc;

  /// Onboarding final step title.
  ///
  /// In en, this message translates to:
  /// **'All set'**
  String get obAllSet;

  /// Onboarding final step web note.
  ///
  /// In en, this message translates to:
  /// **'The web app streams recitation audio, so there\'s nothing to download here — install the Android app if you want it fully offline.'**
  String get obWebAudioNote;

  /// Onboarding download step title.
  ///
  /// In en, this message translates to:
  /// **'Download for offline use'**
  String get obDownloadTitle;

  /// Onboarding download step body.
  ///
  /// In en, this message translates to:
  /// **'Download the recitation audio for your plan now, so everything works without an internet connection. You can always do this later from Settings → Downloads.'**
  String get obDownloadDesc;

  /// Onboarding download button.
  ///
  /// In en, this message translates to:
  /// **'Download now'**
  String get obDownloadNow;

  /// Onboarding skip-download button.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get obSkipForNow;

  /// Onboarding extra-translation picker label.
  ///
  /// In en, this message translates to:
  /// **'Additional translation (optional)'**
  String get obAddlTranslation;

  /// Onboarding extra-translation description.
  ///
  /// In en, this message translates to:
  /// **'Choose one more language to download alongside the bundled English translation. You can change this later.'**
  String get obAddlTranslationDesc;

  /// Onboarding translation picker button.
  ///
  /// In en, this message translates to:
  /// **'Select translation… ({label})'**
  String obSelectTranslation(Object label);

  /// Generic Back nav button.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// Generic Next nav button.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// Generic 'None' option.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get commonNone;

  /// Onboarding juz picker trigger, none selected.
  ///
  /// In en, this message translates to:
  /// **'Select juz (para)…'**
  String get obSelectJuz;

  /// Onboarding juz picker trigger, some selected.
  ///
  /// In en, this message translates to:
  /// **'Selected juz ({count}/30) — tap to edit'**
  String obSelectedJuz(Object count);

  /// Onboarding juz picker dialog title.
  ///
  /// In en, this message translates to:
  /// **'Select juz (para)'**
  String get obSelectJuzTitle;

  /// Juz number label.
  ///
  /// In en, this message translates to:
  /// **'Juz {n}'**
  String commonJuzN(Object n);

  /// Surah number label.
  ///
  /// In en, this message translates to:
  /// **'Surah {n}'**
  String commonSurahN(Object n);

  /// Select-all action.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get commonSelectAll;

  /// Clear-all action.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get commonClearAll;

  /// Picker done button with selected count.
  ///
  /// In en, this message translates to:
  /// **'Done ({count})'**
  String obDoneCount(Object count);

  /// Onboarding surah picker trigger, none selected.
  ///
  /// In en, this message translates to:
  /// **'Select surahs…'**
  String get obSelectSurahs;

  /// Onboarding surah picker trigger, some selected.
  ///
  /// In en, this message translates to:
  /// **'Selected surahs ({count}/114) — tap to edit'**
  String obSelectedSurahs(Object count);

  /// Onboarding surah picker dialog title.
  ///
  /// In en, this message translates to:
  /// **'Select surahs'**
  String get obSelectSurahsTitle;

  /// Onboarding surah picker search.
  ///
  /// In en, this message translates to:
  /// **'Search surah name or number…'**
  String get obSearchSurah;

  /// Onboarding surah picker load error.
  ///
  /// In en, this message translates to:
  /// **'Error loading surahs: {error}'**
  String obErrorSurahs(Object error);

  /// Onboarding translation picker dialog title.
  ///
  /// In en, this message translates to:
  /// **'Select translation'**
  String get obSelectTranslationTitle;

  /// Onboarding hadith-collections picker label.
  ///
  /// In en, this message translates to:
  /// **'Hadith collections (optional)'**
  String get obHadithCollections;

  /// Onboarding hadith-collections description.
  ///
  /// In en, this message translates to:
  /// **'The 40 Hadith of an-Nawawi is always included. Download any of these larger collections now, or later from the Hadith tab.'**
  String get obHadithCollectionsDesc;

  /// Onboarding hadith picker trigger.
  ///
  /// In en, this message translates to:
  /// **'Select Hadith collections… ({count})'**
  String obSelectHadith(Object count);

  /// Onboarding hadith picker dialog title.
  ///
  /// In en, this message translates to:
  /// **'Select hadith collections'**
  String get obSelectHadithTitle;

  /// Surah browser search placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search surah name or number'**
  String get quranSearchHint;

  /// Surah metadata: ayah count.
  ///
  /// In en, this message translates to:
  /// **'{count} ayahs'**
  String quranAyahsCount(Object count);

  /// Surah revelation type.
  ///
  /// In en, this message translates to:
  /// **'Meccan'**
  String get quranMeccan;

  /// Surah revelation type.
  ///
  /// In en, this message translates to:
  /// **'Medinan'**
  String get quranMedinan;

  /// About screen intro.
  ///
  /// In en, this message translates to:
  /// **'Wird is an offline-first, ad-free companion for memorizing the Quran, the 40 Hadith of an-Nawawi, and daily duas — at your own pace, with no account required.'**
  String get aboutIntro;

  /// About screen section header.
  ///
  /// In en, this message translates to:
  /// **'Our foundation'**
  String get aboutFoundation;

  /// About screen methodology statement.
  ///
  /// In en, this message translates to:
  /// **'Wird presents content in line with the understanding of Ahlus Sunnah wal Jama\'ah, upon the manhaj (methodology) of the Salaf — free of sectarian bias, drawing only from authentic, attributed sources.'**
  String get aboutFoundationBody;

  /// About screen section header.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get aboutLicense;

  /// About screen license text.
  ///
  /// In en, this message translates to:
  /// **'Wird is free and open-source software, licensed under the GNU General Public License v3 (GPL-3.0).'**
  String get aboutLicenseBody;

  /// About screen link to data sources.
  ///
  /// In en, this message translates to:
  /// **'Data sources & full licenses'**
  String get aboutDataSourcesLink;

  /// About screen credits expander.
  ///
  /// In en, this message translates to:
  /// **'Credits & acknowledgements'**
  String get aboutCredits;

  /// Global search placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search surahs and duas'**
  String get searchHint;

  /// Global search empty prompt.
  ///
  /// In en, this message translates to:
  /// **'Type to search surahs and duas'**
  String get searchTypePrompt;

  /// Global search results header.
  ///
  /// In en, this message translates to:
  /// **'Surahs'**
  String get searchSurahs;

  /// City picker search placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search for a city'**
  String get citySearchHint;

  /// City picker manual-coords option.
  ///
  /// In en, this message translates to:
  /// **'Enter coordinates manually'**
  String get cityCoordManually;

  /// City picker manual-coords dialog title.
  ///
  /// In en, this message translates to:
  /// **'Enter coordinates'**
  String get cityEnterCoords;

  /// City picker label field.
  ///
  /// In en, this message translates to:
  /// **'Label (optional)'**
  String get cityLabelOptional;

  /// City picker latitude field.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get cityLatitude;

  /// City picker longitude field.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get cityLongitude;

  /// City picker default custom label.
  ///
  /// In en, this message translates to:
  /// **'Custom location'**
  String get cityCustomLocation;

  /// City picker confirm button.
  ///
  /// In en, this message translates to:
  /// **'Use these coordinates'**
  String get cityUseCoords;

  /// Location section detect error.
  ///
  /// In en, this message translates to:
  /// **'Could not detect your location.'**
  String get locationCouldNotDetect;

  /// Location section no-city note.
  ///
  /// In en, this message translates to:
  /// **'No city selected — using fixed 06:00/17:00 reminder times.'**
  String get locationNoCity;

  /// Celebration streak count.
  ///
  /// In en, this message translates to:
  /// **'{count}-day streak'**
  String celebrationStreak(Object count);

  /// Zakah category.
  ///
  /// In en, this message translates to:
  /// **'Cash & savings'**
  String get zakahCatMonetary;

  /// Zakah category blurb.
  ///
  /// In en, this message translates to:
  /// **'Cash, bank balances, and money owed to you'**
  String get zakahCatMonetaryBlurb;

  /// Zakah category.
  ///
  /// In en, this message translates to:
  /// **'Gold & silver'**
  String get zakahCatMetals;

  /// Zakah category blurb.
  ///
  /// In en, this message translates to:
  /// **'By weight, valued at your entered price'**
  String get zakahCatMetalsBlurb;

  /// Zakah category.
  ///
  /// In en, this message translates to:
  /// **'Business assets'**
  String get zakahCatBusiness;

  /// Zakah category blurb.
  ///
  /// In en, this message translates to:
  /// **'Trade goods / inventory held for sale'**
  String get zakahCatBusinessBlurb;

  /// Zakah category.
  ///
  /// In en, this message translates to:
  /// **'Investments & shares'**
  String get zakahCatInvestments;

  /// Zakah category blurb.
  ///
  /// In en, this message translates to:
  /// **'Trading or long-term holdings'**
  String get zakahCatInvestmentsBlurb;

  /// Zakah category.
  ///
  /// In en, this message translates to:
  /// **'Agriculture'**
  String get zakahCatAgriculture;

  /// Zakah category blurb.
  ///
  /// In en, this message translates to:
  /// **'Crops & fruits (ushr, in kind)'**
  String get zakahCatAgricultureBlurb;

  /// Zakah category.
  ///
  /// In en, this message translates to:
  /// **'Livestock'**
  String get zakahCatLivestock;

  /// Zakah category blurb.
  ///
  /// In en, this message translates to:
  /// **'Free-grazing camels, cattle, sheep/goats'**
  String get zakahCatLivestockBlurb;

  /// Zakah category.
  ///
  /// In en, this message translates to:
  /// **'Rikaz'**
  String get zakahCatRikaz;

  /// Zakah category blurb.
  ///
  /// In en, this message translates to:
  /// **'Buried treasure / windfall find (20%)'**
  String get zakahCatRikazBlurb;

  /// Zakah setup section header.
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get zakahSetup;

  /// Zakah currency label.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get zakahCurrency;

  /// Zakah nisab basis label.
  ///
  /// In en, this message translates to:
  /// **'Nisab basis'**
  String get zakahNisabBasis;

  /// Zakah nisab basis: silver.
  ///
  /// In en, this message translates to:
  /// **'Silver (595g)'**
  String get zakahSilverBasis;

  /// Zakah nisab basis: gold.
  ///
  /// In en, this message translates to:
  /// **'Gold (85g)'**
  String get zakahGoldBasis;

  /// Zakah gold price field.
  ///
  /// In en, this message translates to:
  /// **'Gold price / gram'**
  String get zakahGoldPrice;

  /// Zakah silver price field.
  ///
  /// In en, this message translates to:
  /// **'Silver price / gram'**
  String get zakahSilverPrice;

  /// Zakah category-toggle section header.
  ///
  /// In en, this message translates to:
  /// **'Which apply to you?'**
  String get zakahWhichApply;

  /// Zakah field.
  ///
  /// In en, this message translates to:
  /// **'Receivables (money owed to you)'**
  String get zakahReceivables;

  /// Zakah field.
  ///
  /// In en, this message translates to:
  /// **'Debts due now (deducted)'**
  String get zakahDebtsDue;

  /// Zakah field.
  ///
  /// In en, this message translates to:
  /// **'Gold owned (grams)'**
  String get zakahGoldGrams;

  /// Zakah field.
  ///
  /// In en, this message translates to:
  /// **'Silver owned (grams)'**
  String get zakahSilverGrams;

  /// Zakah field.
  ///
  /// In en, this message translates to:
  /// **'Trade goods value'**
  String get zakahTradeGoods;

  /// Zakah field.
  ///
  /// In en, this message translates to:
  /// **'Zakatable investment value'**
  String get zakahInvestmentValue;

  /// Zakah agriculture option.
  ///
  /// In en, this message translates to:
  /// **'Rain-fed (10%)'**
  String get zakahRainFed;

  /// Zakah agriculture option.
  ///
  /// In en, this message translates to:
  /// **'Irrigated (5%)'**
  String get zakahIrrigated;

  /// Zakah agriculture field.
  ///
  /// In en, this message translates to:
  /// **'Harvest weight (kg)'**
  String get zakahHarvestWeight;

  /// Zakah livestock field.
  ///
  /// In en, this message translates to:
  /// **'Number of animals'**
  String get zakahNumberAnimals;

  /// Zakah rikaz field.
  ///
  /// In en, this message translates to:
  /// **'Value of the find'**
  String get zakahFindValue;

  /// Zakah livestock type.
  ///
  /// In en, this message translates to:
  /// **'Camels'**
  String get zakahCamels;

  /// Zakah livestock type.
  ///
  /// In en, this message translates to:
  /// **'Cattle'**
  String get zakahCattle;

  /// Zakah livestock type.
  ///
  /// In en, this message translates to:
  /// **'Sheep/goats'**
  String get zakahSheepGoats;

  /// Zakah summary row.
  ///
  /// In en, this message translates to:
  /// **'Zakatable wealth'**
  String get zakahZakatableWealth;

  /// Zakah summary row.
  ///
  /// In en, this message translates to:
  /// **'Nisab threshold'**
  String get zakahNisabThreshold;

  /// Zakah summary row.
  ///
  /// In en, this message translates to:
  /// **'Monetary Zakah (2.5%)'**
  String get zakahMonetaryDue;

  /// Zakah summary: below nisab.
  ///
  /// In en, this message translates to:
  /// **'Below nisab — nothing due'**
  String get zakahBelowNisabNothing;

  /// Zakah summary row.
  ///
  /// In en, this message translates to:
  /// **'Agriculture — below nisab'**
  String get zakahAgricultureBelowNisab;

  /// Zakah summary row.
  ///
  /// In en, this message translates to:
  /// **'Livestock'**
  String get zakahLivestock;

  /// Zakah summary: below nisab (short).
  ///
  /// In en, this message translates to:
  /// **'Below nisab'**
  String get zakahBelowNisab;

  /// Zakah summary row.
  ///
  /// In en, this message translates to:
  /// **'Livestock due'**
  String get zakahLivestockDue;

  /// Zakah summary row.
  ///
  /// In en, this message translates to:
  /// **'Rikaz (20%)'**
  String get zakahRikazDue;

  /// Zakah summary section header.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get zakahSummary;

  /// Zakah summary empty state.
  ///
  /// In en, this message translates to:
  /// **'Select the categories above and enter your values.'**
  String get zakahSelectCategories;

  /// Prayer name.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get prayerFajr;

  /// Prayer name.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get prayerDhuhr;

  /// Prayer name.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayerAsr;

  /// Prayer name.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayerMaghrib;

  /// Prayer name.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayerIsha;

  /// Adhan preview error.
  ///
  /// In en, this message translates to:
  /// **'Could not play preview: {error}'**
  String settingsPreviewError(Object error);

  /// Backup export error.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String settingsExportError(Object error);

  /// Reset confirmation.
  ///
  /// In en, this message translates to:
  /// **'{label} progress reset.'**
  String settingsResetDone(Object label);

  /// Reset error.
  ///
  /// In en, this message translates to:
  /// **'Reset failed: {error}'**
  String settingsResetError(Object error);

  /// Theme mode: follow system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// Theme mode: light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Theme mode: dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Theme mode: AMOLED black.
  ///
  /// In en, this message translates to:
  /// **'AMOLED'**
  String get themeAmoled;

  /// Shown under the Finish button while the plan is being generated.
  ///
  /// In en, this message translates to:
  /// **'Preparing your plan…'**
  String get obPreparingPlan;

  /// Dua circumstance-group title.
  ///
  /// In en, this message translates to:
  /// **'Daily routine'**
  String get duaGroupDailyRoutine;

  /// Dua circumstance-group title.
  ///
  /// In en, this message translates to:
  /// **'Prayer & the mosque'**
  String get duaGroupPrayer;

  /// Dua circumstance-group title.
  ///
  /// In en, this message translates to:
  /// **'Morning, evening & sleep'**
  String get duaGroupMorningEveningSleep;

  /// Dua circumstance-group title.
  ///
  /// In en, this message translates to:
  /// **'Distress & protection'**
  String get duaGroupDistressProtection;

  /// Dua circumstance-group title.
  ///
  /// In en, this message translates to:
  /// **'Food, family & social life'**
  String get duaGroupFoodSocialFamily;

  /// Dua circumstance-group title.
  ///
  /// In en, this message translates to:
  /// **'Illness & bereavement'**
  String get duaGroupIllnessDeath;

  /// Dua circumstance-group title.
  ///
  /// In en, this message translates to:
  /// **'Travel, Hajj & Umrah'**
  String get duaGroupTravelHajj;

  /// Dua circumstance-group title.
  ///
  /// In en, this message translates to:
  /// **'Remembrance & nature'**
  String get duaGroupRemembranceNature;

  /// Count of occasions inside a dua group.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 occasion} other{{count} occasions}}'**
  String duasOccasionCount(int count);

  /// Count of duas inside a category.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 dua} other{{count} duas}}'**
  String duasDuaCount(int count);

  /// Nawawi collection label (gold) in the hadith detail app-bar.
  ///
  /// In en, this message translates to:
  /// **'Nawawi'**
  String get hadithCollectionNawawi;

  /// Hadith detail app-bar, the numbered part.
  ///
  /// In en, this message translates to:
  /// **'Hadith {number}'**
  String hadithNumbered(int number);

  /// Authenticity note for Bukhari/Muslim.
  ///
  /// In en, this message translates to:
  /// **'One of the two most authentic books after the Qur\'an. Its hadith are accepted as authentic (ṣaḥīḥ).'**
  String get hadithNoteSahihayn;

  /// Authenticity note for Malik's Muwatta.
  ///
  /// In en, this message translates to:
  /// **'The Muwaṭṭaʾ of Imām Mālik — one of the earliest collections. Grades shown are from the noted verifier.'**
  String get hadithNoteMuwatta;

  /// Authenticity note for the Sunan collections.
  ///
  /// In en, this message translates to:
  /// **'A Sunan collection containing hadith of varying authenticity. Each hadith shows its grade — verify weak (ḍaʿīf) narrations before relying on them.'**
  String get hadithNoteSunan;

  /// Fallback authenticity note.
  ///
  /// In en, this message translates to:
  /// **'Each hadith shows its authenticity grade where the source provides one.'**
  String get hadithNoteGeneric;

  /// Duration in minutes (time chip).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 min} other{{count} min}}'**
  String durationMin(int count);

  /// Duration in whole hours (time chip).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hr} other{{count} hr}}'**
  String durationHr(int count);

  /// Duration hours + minutes (time chip).
  ///
  /// In en, this message translates to:
  /// **'{hours} hr {minutes} min'**
  String durationHrMin(int hours, int minutes);

  /// Pace estimate, very short.
  ///
  /// In en, this message translates to:
  /// **'less than a day'**
  String get durationLessThanDay;

  /// Pace estimate in days.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String durationDaysValue(int count);

  /// Pace estimate in weeks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 week} other{{count} weeks}}'**
  String durationWeeksValue(int count);

  /// Pace estimate in months.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{about a month} other{about {count} months}}'**
  String durationAboutMonth(int count);

  /// Number of years for a pace estimate.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 year} other{{count} years}}'**
  String durationYearsValue(int count);

  /// Number of months for a pace estimate.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month} other{{count} months}}'**
  String durationMonthsValue(int count);

  /// Pace estimate, single unit (value is a localized duration).
  ///
  /// In en, this message translates to:
  /// **'about {value}'**
  String durationAbout(String value);

  /// Pace estimate, two units (both localized durations).
  ///
  /// In en, this message translates to:
  /// **'about {first}, {second}'**
  String durationAboutTwo(String first, String second);

  /// First-run tour, step 1 title.
  ///
  /// In en, this message translates to:
  /// **'Five tabs, and a sixth'**
  String get tourStep1Title;

  /// First-run tour, step 1 body.
  ///
  /// In en, this message translates to:
  /// **'Home, Quran, Explore, Duas, and More sit on the bar below. Press and swipe the bar sideways to reveal Al-Manhaj just past the edge.'**
  String get tourStep1Body;

  /// First-run tour, step 2 title.
  ///
  /// In en, this message translates to:
  /// **'Keep listening anywhere'**
  String get tourStep2Title;

  /// First-run tour, step 2 body.
  ///
  /// In en, this message translates to:
  /// **'When you play Quran audio, a mini-player docks above the tabs so you can keep listening while you browse Duas, Explore, or anywhere else.'**
  String get tourStep2Body;

  /// First-run tour, step 3 title.
  ///
  /// In en, this message translates to:
  /// **'Explore is your toolbox'**
  String get tourStep3Title;

  /// First-run tour, step 3 body.
  ///
  /// In en, this message translates to:
  /// **'Hadith collections, the Qibla compass, the Zakah calculator, and the Tasbih counter all live in the Explore tab.'**
  String get tourStep3Body;

  /// Bold lead-in before hadith citations.
  ///
  /// In en, this message translates to:
  /// **'Reference: '**
  String get referenceLabel;

  /// Zakah calculator, manual metal-price input label. {code} is the currency code.
  ///
  /// In en, this message translates to:
  /// **'Metal price per gram ({code}), entered manually'**
  String zakahMetalPriceLabel(String code);

  /// Zakah calculator intro/disclaimer banner.
  ///
  /// In en, this message translates to:
  /// **'Zakah is due on wealth held for one lunar year (hawl) that reaches the nisab threshold. Amounts here are estimates to help you plan — consult a trustworthy scholar for your specific situation.'**
  String get zakahGeneralNote;

  /// Memorization exercise prompt.
  ///
  /// In en, this message translates to:
  /// **'Tap the next word'**
  String get sessionTapNextWord;

  /// Memorization exercise prompt.
  ///
  /// In en, this message translates to:
  /// **'Fill in the blank'**
  String get sessionFillBlank;

  /// Memorization exercise prompt.
  ///
  /// In en, this message translates to:
  /// **'Recall the ayah from these first letters'**
  String get sessionRecallFirstLetters;

  /// Memorization exercise action.
  ///
  /// In en, this message translates to:
  /// **'Show full text'**
  String get sessionShowFullText;

  /// Memorization exercise prompt.
  ///
  /// In en, this message translates to:
  /// **'Drag the ayahs into the correct order'**
  String get sessionDragOrder;

  /// Memorization exercise, wrong answer.
  ///
  /// In en, this message translates to:
  /// **'Not quite — try again'**
  String get sessionNotQuite;

  /// Memorization exercise action, verify ordering.
  ///
  /// In en, this message translates to:
  /// **'Check order'**
  String get sessionCheckOrder;

  /// Memorization new-material step progress.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String sessionStepOf(int current, int total);

  /// Review flow, reveal the answer.
  ///
  /// In en, this message translates to:
  /// **'Reveal'**
  String get sessionReveal;

  /// Review flow instruction.
  ///
  /// In en, this message translates to:
  /// **'Recall it from memory, then reveal to check.'**
  String get sessionRecallThenReveal;

  /// SM-2 review grade (hardest).
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get gradeAgain;

  /// SM-2 review grade.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get gradeHard;

  /// SM-2 review grade.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get gradeGood;

  /// SM-2 review grade (easiest).
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get gradeEasy;

  /// Snackbar when achievements unlock after a session.
  ///
  /// In en, this message translates to:
  /// **'Achievement unlocked: {names}'**
  String sessionAchievementUnlocked(String names);

  /// Generic load-error state.
  ///
  /// In en, this message translates to:
  /// **'Failed to load: {error}'**
  String commonFailedToLoad(String error);

  /// Settings row to check for an app update.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get updateCheck;

  /// Progress while checking.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates…'**
  String get updateChecking;

  /// Update dialog/banner title.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailableTitle;

  /// Update banner text.
  ///
  /// In en, this message translates to:
  /// **'Wird {version} is available'**
  String updateAvailableBanner(String version);

  /// Confirm update action.
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get updateNow;

  /// Dismiss update prompt.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateLater;

  /// Shown when no update is available.
  ///
  /// In en, this message translates to:
  /// **'You\'re on the latest version'**
  String get updateUpToDate;

  /// Progress while downloading the APK.
  ///
  /// In en, this message translates to:
  /// **'Downloading update…'**
  String get updateDownloading;

  /// App-bar action/tooltip on a surah to mark the whole surah as already memorized.
  ///
  /// In en, this message translates to:
  /// **'Mark as memorized'**
  String get quranMarkMemorized;

  /// Confirmation dialog body when marking a surah as already memorized.
  ///
  /// In en, this message translates to:
  /// **'Mark this entire surah as already memorized? It will be scheduled for long-term revision instead of shown as new.'**
  String get quranMarkMemorizedBody;

  /// Confirm button that marks the surah memorized.
  ///
  /// In en, this message translates to:
  /// **'Mark memorized'**
  String get quranMarkMemorizedConfirm;

  /// Snackbar shown after marking a surah memorized.
  ///
  /// In en, this message translates to:
  /// **'Added to long-term revision'**
  String get quranMarkedForRevision;

  /// Toggle in plan editing to add/remove the Hadith track.
  ///
  /// In en, this message translates to:
  /// **'Include Hadith'**
  String get planIncludeHadith;

  /// Toggle in plan editing to add/remove the Duas & Adhkar track.
  ///
  /// In en, this message translates to:
  /// **'Include Duas & Adhkar'**
  String get planIncludeDuas;

  /// Toggle: enter the five prayer times by hand instead of computing them from a location.
  ///
  /// In en, this message translates to:
  /// **'Set prayer times manually'**
  String get settingsUseManualTimes;

  /// SnackBar shown while the adhan preview is playing, with a Stop action.
  ///
  /// In en, this message translates to:
  /// **'Playing adhan…'**
  String get settingsPlayingAdhan;

  /// Title on the full-screen adhan player when the prayer name is unknown.
  ///
  /// In en, this message translates to:
  /// **'Time to pray'**
  String get adhanCallTitle;

  /// Title on the adhan player naming the prayer, e.g. "Time for Fajr".
  ///
  /// In en, this message translates to:
  /// **'Time for {salah}'**
  String adhanCallFor(String salah);

  /// Hint on the adhan player telling the user tapping stops the adhan.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere to silence'**
  String get adhanTapToSilence;

  /// App-bar action opening a picker to mark whole juz as already memorized.
  ///
  /// In en, this message translates to:
  /// **'Mark a juz as memorized'**
  String get quranMarkJuzMemorized;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'am',
    'ar',
    'az',
    'bg',
    'bn',
    'bs',
    'ckb',
    'cs',
    'da',
    'de',
    'dv',
    'el',
    'en',
    'es',
    'fa',
    'fi',
    'fil',
    'fr',
    'gu',
    'ha',
    'hi',
    'hu',
    'id',
    'it',
    'ja',
    'kk',
    'km',
    'kn',
    'ko',
    'ku',
    'ky',
    'ml',
    'mr',
    'ms',
    'my',
    'nb',
    'ne',
    'nl',
    'pa',
    'pl',
    'ps',
    'pt',
    'ro',
    'ru',
    'sd',
    'si',
    'so',
    'sq',
    'sr',
    'sv',
    'sw',
    'ta',
    'te',
    'tg',
    'th',
    'tk',
    'tr',
    'ug',
    'uk',
    'ur',
    'uz',
    'vi',
    'yo',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'ar':
      return AppLocalizationsAr();
    case 'az':
      return AppLocalizationsAz();
    case 'bg':
      return AppLocalizationsBg();
    case 'bn':
      return AppLocalizationsBn();
    case 'bs':
      return AppLocalizationsBs();
    case 'ckb':
      return AppLocalizationsCkb();
    case 'cs':
      return AppLocalizationsCs();
    case 'da':
      return AppLocalizationsDa();
    case 'de':
      return AppLocalizationsDe();
    case 'dv':
      return AppLocalizationsDv();
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fa':
      return AppLocalizationsFa();
    case 'fi':
      return AppLocalizationsFi();
    case 'fil':
      return AppLocalizationsFil();
    case 'fr':
      return AppLocalizationsFr();
    case 'gu':
      return AppLocalizationsGu();
    case 'ha':
      return AppLocalizationsHa();
    case 'hi':
      return AppLocalizationsHi();
    case 'hu':
      return AppLocalizationsHu();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'kk':
      return AppLocalizationsKk();
    case 'km':
      return AppLocalizationsKm();
    case 'kn':
      return AppLocalizationsKn();
    case 'ko':
      return AppLocalizationsKo();
    case 'ku':
      return AppLocalizationsKu();
    case 'ky':
      return AppLocalizationsKy();
    case 'ml':
      return AppLocalizationsMl();
    case 'mr':
      return AppLocalizationsMr();
    case 'ms':
      return AppLocalizationsMs();
    case 'my':
      return AppLocalizationsMy();
    case 'nb':
      return AppLocalizationsNb();
    case 'ne':
      return AppLocalizationsNe();
    case 'nl':
      return AppLocalizationsNl();
    case 'pa':
      return AppLocalizationsPa();
    case 'pl':
      return AppLocalizationsPl();
    case 'ps':
      return AppLocalizationsPs();
    case 'pt':
      return AppLocalizationsPt();
    case 'ro':
      return AppLocalizationsRo();
    case 'ru':
      return AppLocalizationsRu();
    case 'sd':
      return AppLocalizationsSd();
    case 'si':
      return AppLocalizationsSi();
    case 'so':
      return AppLocalizationsSo();
    case 'sq':
      return AppLocalizationsSq();
    case 'sr':
      return AppLocalizationsSr();
    case 'sv':
      return AppLocalizationsSv();
    case 'sw':
      return AppLocalizationsSw();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
    case 'tg':
      return AppLocalizationsTg();
    case 'th':
      return AppLocalizationsTh();
    case 'tk':
      return AppLocalizationsTk();
    case 'tr':
      return AppLocalizationsTr();
    case 'ug':
      return AppLocalizationsUg();
    case 'uk':
      return AppLocalizationsUk();
    case 'ur':
      return AppLocalizationsUr();
    case 'uz':
      return AppLocalizationsUz();
    case 'vi':
      return AppLocalizationsVi();
    case 'yo':
      return AppLocalizationsYo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
