import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jobless/core/utils/constants.dart';
import 'package:jobless/core/widgets/crop_image.dart';
import 'package:jobless/core/widgets/pdfviewer.dart';
import 'package:jobless/presentation/pages/applicants/applicants_page.dart';
import 'package:jobless/presentation/pages/auth/forgot_page.dart';
import 'package:jobless/presentation/pages/auth/signin_page.dart';
import 'package:jobless/presentation/pages/auth/signup_page.dart';
import 'package:jobless/presentation/pages/bookmarks/bookmarks_page.dart';
import 'package:jobless/presentation/pages/home/navbar_page.dart';
import 'package:jobless/presentation/pages/locations/location_page.dart';
import 'package:jobless/presentation/pages/notification/employee/notification_page.dart';
import 'package:jobless/presentation/pages/notification/employers/notification_employers_page.dart';
import 'package:jobless/presentation/pages/schedule/schedule_page.dart';
import 'package:jobless/presentation/pages/settings/settings_page.dart';
import 'package:jobless/presentation/pages/tips/tips_page.dart';
import 'package:jobless/presentation/pages/user/employersprofile_page.dart';
import 'package:jobless/presentation/pages/vacansies/vacancies_page.dart';
import 'package:lottie/lottie.dart';

import '../../app.dart';
import '../../core/widgets/texteditordesc.dart';
import '../pages/applications/employee/detail_applicant_page.dart';
import '../pages/categories/categories_page.dart';
import '../pages/home/widgets/employee/widget_send_vacancy.dart';
import '../pages/home/widgets/employers/widget_detail_applicant.dart';
import '../pages/profile/employers/form_profile_employers.dart';
import '../pages/settings/categories/category_page.dart';
import '../pages/user/categoriesjob_page.dart';
import '../pages/user/empolyeeprofile_page.dart';
import '../pages/user/profile_page.dart';
import '../pages/vacansies/detail/widget_vacancy.dart';
import '../pages/welcome.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.root:
        return MaterialPageRoute(
            builder: (_) => const AppPage(), settings: settings);
      case Routes.welcomePage:
        return MaterialPageRoute(
            builder: (_) => const WelcomePage(), settings: settings);

      //Auth Page
      case Routes.signInPage:
        return CupertinoPageRoute(
            builder: (_) => const SignInPage(), settings: settings);
      case Routes.signOutPage:
        return CupertinoPageRoute(
            builder: (_) => const SignUpPage(), settings: settings);
      case Routes.forgotPage:
        return CupertinoPageRoute(
            builder: (_) => const ForgotPage(), settings: settings);

      //Settings Profile
      case Routes.userprofilePage:
        return CupertinoPageRoute(
            builder: (_) => const UserPage(), settings: settings);
      case Routes.categoryPage:
        return CupertinoPageRoute(
            builder: (_) => const CategoriesJobPage(), settings: settings);
      case Routes.employeePage:
        return CupertinoPageRoute(
            builder: (_) => const EmployeeProfilePage(), settings: settings);
      case Routes.employersPage:
        return CupertinoPageRoute(
            builder: (_) => const EmployersProfilePage(), settings: settings);

      //Dashboard
      case Routes.navbarPage:
        return MaterialPageRoute(
            builder: (_) => const NavbarPage(), settings: settings);

      case Routes.vacanciesPage:
        return CupertinoPageRoute(
            builder: (_) => const VacanciesPage(), settings: settings);

      case Routes.vacancyPage:
        return CupertinoPageRoute(
            builder: (_) => const WidgetVacancy(), settings: settings);
      case Routes.applyvacancyPage:
        return CupertinoPageRoute(
            builder: (_) => const WidgetSendVacancy(), settings: settings);

      case Routes.pdfViewPage:
        return CupertinoPageRoute(
            builder: (_) => const WidgetPDFViewer(), settings: settings);

      case Routes.applicationEmployeeDetailPage:
        return CupertinoPageRoute(
            builder: (_) => const WidgetDetailApplicantEmployee(),
            settings: settings);

      case Routes.applicationEmployersDetailPage:
        return CupertinoPageRoute(
            builder: (_) => const WidgetDetailApplicantEmployers(),
            settings: settings);

      case Routes.applicantsPage:
        return CupertinoPageRoute(
            builder: (_) => const ApplicantsPage(), settings: settings);

      case Routes.texteditorPage:
        return CupertinoPageRoute(
            builder: (_) => const TextEditDesc(), settings: settings);

      case Routes.locationPage:
        return CupertinoPageRoute(
            builder: (_) => const LocationPage(), settings: settings);
      case Routes.categoriesPage:
        return CupertinoPageRoute(
            builder: (_) => const CategoriesPage(), settings: settings);

      case Routes.notificationEmployeePage:
        return CupertinoPageRoute(
            builder: (_) => const NotificationPage(), settings: settings);
      case Routes.notificationEmployersPage:
        return CupertinoPageRoute(
            builder: (_) => const NotificationEmployersPage(),
            settings: settings);

      case Routes.tipsPage:
        return CupertinoPageRoute(
            builder: (_) => const TipsPage(), settings: settings);
      case Routes.bookmarksPage:
        return CupertinoPageRoute(
            builder: (_) => const BookmaksPage(), settings: settings);

      case Routes.schedulePage:
        return CupertinoPageRoute(
            builder: (_) => const SchedulePage(), settings: settings);

      case Routes.cropImagePage:
        return CupertinoPageRoute(
            builder: (_) => const CropImage(), settings: settings);
      case Routes.formProfileEmployersPage:
        return CupertinoPageRoute(
            builder: (_) => const FormProfileEmployers(), settings: settings);

      //settings
      case Routes.settingsPage:
        return CupertinoPageRoute(
            builder: (_) => const SettingsPage(), settings: settings);
      case Routes.categoriesSettingsPage:
        return CupertinoPageRoute(
            builder: (_) => const CategoriesSettingPage(), settings: settings);
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (context) {
      return Scaffold(
        appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor.withOpacity(.1),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Theme.of(context).primaryColor,
                    )),
              ),
            ),
            title: Text("page not found".tr())),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset('assets/lottie/notfound.json',
                alignment: Alignment.center, fit: BoxFit.cover, height: 120),
            Text('page not found'.tr()),
          ],
        )),
      );
    });
  }
}
