import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back,'**
  String get welcomeBack;

  /// No description provided for @stefaniWong.
  ///
  /// In en, this message translates to:
  /// **'Stefani Wong'**
  String get stefaniWong;

  /// No description provided for @todayTarget.
  ///
  /// In en, this message translates to:
  /// **'Today Target'**
  String get todayTarget;

  /// No description provided for @check.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get check;

  /// No description provided for @activityStatus.
  ///
  /// In en, this message translates to:
  /// **'Activity Status'**
  String get activityStatus;

  /// No description provided for @heartRate.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate'**
  String get heartRate;

  /// No description provided for @bmi.
  ///
  /// In en, this message translates to:
  /// **'BMI (Body Mass Index)'**
  String get bmi;

  /// No description provided for @youHaveNormalWeight.
  ///
  /// In en, this message translates to:
  /// **'You have a normal weight'**
  String get youHaveNormalWeight;

  /// No description provided for @viewMore.
  ///
  /// In en, this message translates to:
  /// **'View More'**
  String get viewMore;

  /// No description provided for @minsAgo.
  ///
  /// In en, this message translates to:
  /// **'mins ago'**
  String get minsAgo;

  /// No description provided for @bpm.
  ///
  /// In en, this message translates to:
  /// **'BPM'**
  String get bpm;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @loseAFatProgram.
  ///
  /// In en, this message translates to:
  /// **'Lose a Fat Program'**
  String get loseAFatProgram;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @personalData.
  ///
  /// In en, this message translates to:
  /// **'Personal Data'**
  String get personalData;

  /// No description provided for @achievement.
  ///
  /// In en, this message translates to:
  /// **'Achievement'**
  String get achievement;

  /// No description provided for @activityHistory.
  ///
  /// In en, this message translates to:
  /// **'Activity History'**
  String get activityHistory;

  /// No description provided for @workoutProgress.
  ///
  /// In en, this message translates to:
  /// **'Workout Progress'**
  String get workoutProgress;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @popUpNotification.
  ///
  /// In en, this message translates to:
  /// **'Pop-up Notification'**
  String get popUpNotification;

  /// No description provided for @workoutTracker.
  ///
  /// In en, this message translates to:
  /// **'Workout Tracker'**
  String get workoutTracker;

  /// No description provided for @dailyWorkoutSchedule.
  ///
  /// In en, this message translates to:
  /// **'Daily Workout Schedule'**
  String get dailyWorkoutSchedule;

  /// No description provided for @upcomingWorkout.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Workout'**
  String get upcomingWorkout;

  /// No description provided for @whatDoYouWantToTrain.
  ///
  /// In en, this message translates to:
  /// **'What Do You Want to Train'**
  String get whatDoYouWantToTrain;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @mealPlanner.
  ///
  /// In en, this message translates to:
  /// **'Meal Planner'**
  String get mealPlanner;

  /// No description provided for @sleepTracker.
  ///
  /// In en, this message translates to:
  /// **'Sleep Tracker'**
  String get sleepTracker;

  /// No description provided for @fullBodyWorkout.
  ///
  /// In en, this message translates to:
  /// **'Full Body Workout'**
  String get fullBodyWorkout;

  /// No description provided for @lowerBodyWorkout.
  ///
  /// In en, this message translates to:
  /// **'Lower Body Workout'**
  String get lowerBodyWorkout;

  /// No description provided for @abWorkout.
  ///
  /// In en, this message translates to:
  /// **'Ab Workout'**
  String get abWorkout;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get vietnamese;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed successfully'**
  String get languageChanged;

  /// No description provided for @addAlarm.
  ///
  /// In en, this message translates to:
  /// **'Add Alarm'**
  String get addAlarm;

  /// No description provided for @bedtime.
  ///
  /// In en, this message translates to:
  /// **'Bedtime'**
  String get bedtime;

  /// No description provided for @hoursOfSleep.
  ///
  /// In en, this message translates to:
  /// **'Hours of sleep'**
  String get hoursOfSleep;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @vibrateWhenAlarmSound.
  ///
  /// In en, this message translates to:
  /// **'Vibrate When Alarm Sound'**
  String get vibrateWhenAlarmSound;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @workoutSchedule.
  ///
  /// In en, this message translates to:
  /// **'Workout Schedule'**
  String get workoutSchedule;

  /// No description provided for @markDone.
  ///
  /// In en, this message translates to:
  /// **'Mark Done'**
  String get markDone;

  /// No description provided for @mealSchedule.
  ///
  /// In en, this message translates to:
  /// **'Meal Schedule'**
  String get mealSchedule;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @snacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get snacks;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @todayMealNutritions.
  ///
  /// In en, this message translates to:
  /// **'Today Meal Nutritions'**
  String get todayMealNutritions;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @caloriesUnit.
  ///
  /// In en, this message translates to:
  /// **'calories'**
  String get caloriesUnit;

  /// No description provided for @mealNutritions.
  ///
  /// In en, this message translates to:
  /// **'Meal Nutritions'**
  String get mealNutritions;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @dailyMealSchedule.
  ///
  /// In en, this message translates to:
  /// **'Daily Meal Schedule'**
  String get dailyMealSchedule;

  /// No description provided for @todayMeals.
  ///
  /// In en, this message translates to:
  /// **'Today Meals'**
  String get todayMeals;

  /// No description provided for @snack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snack;

  /// No description provided for @dessert.
  ///
  /// In en, this message translates to:
  /// **'Dessert'**
  String get dessert;

  /// No description provided for @findSomethingToEat.
  ///
  /// In en, this message translates to:
  /// **'Find Something to Eat'**
  String get findSomethingToEat;

  /// No description provided for @foods.
  ///
  /// In en, this message translates to:
  /// **'Foods'**
  String get foods;

  /// No description provided for @searchPancake.
  ///
  /// In en, this message translates to:
  /// **'Search Pancake'**
  String get searchPancake;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @recommendationForDiet.
  ///
  /// In en, this message translates to:
  /// **'Recommendation\nfor Diet'**
  String get recommendationForDiet;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @sleepSchedule.
  ///
  /// In en, this message translates to:
  /// **'Sleep Schedule'**
  String get sleepSchedule;

  /// No description provided for @idealHoursForSleep.
  ///
  /// In en, this message translates to:
  /// **'Ideal Hours for Sleep'**
  String get idealHoursForSleep;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get learnMore;

  /// No description provided for @yourSchedule.
  ///
  /// In en, this message translates to:
  /// **'Your Schedule'**
  String get yourSchedule;

  /// No description provided for @waterIntake.
  ///
  /// In en, this message translates to:
  /// **'Water Intake'**
  String get waterIntake;

  /// No description provided for @realTimeUpdates.
  ///
  /// In en, this message translates to:
  /// **'Real time updates'**
  String get realTimeUpdates;

  /// No description provided for @sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @kCalLeft.
  ///
  /// In en, this message translates to:
  /// **'kCal\nleft'**
  String get kCalLeft;

  /// No description provided for @latestWorkout.
  ///
  /// In en, this message translates to:
  /// **'Latest Workout'**
  String get latestWorkout;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See More'**
  String get seeMore;

  /// No description provided for @caloriesBurn.
  ///
  /// In en, this message translates to:
  /// **'Calories Burn'**
  String get caloriesBurn;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @fullbodyWorkout.
  ///
  /// In en, this message translates to:
  /// **'Fullbody Workout'**
  String get fullbodyWorkout;

  /// No description provided for @upperbodyWorkout.
  ///
  /// In en, this message translates to:
  /// **'Upperbody Workout'**
  String get upperbodyWorkout;

  /// No description provided for @lowerbodyWorkout.
  ///
  /// In en, this message translates to:
  /// **'Lowerbody Workout'**
  String get lowerbodyWorkout;

  /// No description provided for @exercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercises;

  /// No description provided for @congratulationsFinishedWorkout.
  ///
  /// In en, this message translates to:
  /// **'Congratulations, You Have Finished Your Workout'**
  String get congratulationsFinishedWorkout;

  /// No description provided for @exercisesKingNutritionQueen.
  ///
  /// In en, this message translates to:
  /// **'Exercises is king and nutrition is queen. Combine the two and you will have a kingdom'**
  String get exercisesKingNutritionQueen;

  /// No description provided for @jackLalanne.
  ///
  /// In en, this message translates to:
  /// **'-Jack Lalanne'**
  String get jackLalanne;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back To Home'**
  String get backToHome;

  /// No description provided for @progressPhoto.
  ///
  /// In en, this message translates to:
  /// **'Progress Photo'**
  String get progressPhoto;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder!'**
  String get reminder;

  /// No description provided for @nextPhotosFallOn.
  ///
  /// In en, this message translates to:
  /// **'Next Photos Fall On July 08'**
  String get nextPhotosFallOn;

  /// No description provided for @trackYourProgress.
  ///
  /// In en, this message translates to:
  /// **'Track Your Progress Each\nMonth With Photo'**
  String get trackYourProgress;

  /// No description provided for @compareMyPhoto.
  ///
  /// In en, this message translates to:
  /// **'Compare my Photo'**
  String get compareMyPhoto;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @comparison.
  ///
  /// In en, this message translates to:
  /// **'Comparison'**
  String get comparison;

  /// No description provided for @reminderReset.
  ///
  /// In en, this message translates to:
  /// **'Reminder reset!'**
  String get reminderReset;

  /// No description provided for @testUserData.
  ///
  /// In en, this message translates to:
  /// **'Test User Data'**
  String get testUserData;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get confirmLogout;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @logoutError.
  ///
  /// In en, this message translates to:
  /// **'Logout error'**
  String get logoutError;

  /// No description provided for @setYourGoal.
  ///
  /// In en, this message translates to:
  /// **'Set your goal'**
  String get setYourGoal;

  /// No description provided for @editBMI.
  ///
  /// In en, this message translates to:
  /// **'Edit BMI'**
  String get editBMI;

  /// No description provided for @editBMIInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit BMI Information'**
  String get editBMIInfo;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKg;

  /// No description provided for @heightCm.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get heightCm;

  /// No description provided for @currentBMI.
  ///
  /// In en, this message translates to:
  /// **'Current BMI'**
  String get currentBMI;

  /// No description provided for @pleaseEnterWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter weight'**
  String get pleaseEnterWeight;

  /// No description provided for @pleaseEnterHeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter height'**
  String get pleaseEnterHeight;

  /// No description provided for @invalidWeight.
  ///
  /// In en, this message translates to:
  /// **'Invalid weight (1-500 kg)'**
  String get invalidWeight;

  /// No description provided for @invalidHeight.
  ///
  /// In en, this message translates to:
  /// **'Invalid height (1-300 cm)'**
  String get invalidHeight;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @bmiUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'BMI information updated successfully!'**
  String get bmiUpdateSuccess;

  /// No description provided for @bmiUpdateError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while updating information!'**
  String get bmiUpdateError;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @underweight.
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get underweight;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @overweight.
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get overweight;

  /// No description provided for @obese.
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get obese;

  /// No description provided for @youAreUnderweight.
  ///
  /// In en, this message translates to:
  /// **'You are underweight'**
  String get youAreUnderweight;

  /// No description provided for @youAreOverweight.
  ///
  /// In en, this message translates to:
  /// **'You are overweight'**
  String get youAreOverweight;

  /// No description provided for @youAreObese.
  ///
  /// In en, this message translates to:
  /// **'You are obese'**
  String get youAreObese;

  /// No description provided for @noBMIData.
  ///
  /// In en, this message translates to:
  /// **'No BMI data available'**
  String get noBMIData;
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
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
