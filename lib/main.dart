import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobless/core/navigationservice.dart';
import 'package:jobless/core/theme.dart';
import 'package:jobless/data/service/firebaseapi.dart';
import 'package:jobless/presentation/bloc/applicants/applicants_cubit.dart';
import 'package:jobless/presentation/bloc/auth/auth_cubit.dart';
import 'package:jobless/presentation/bloc/bookmarks/bookmarks_cubit.dart';
import 'package:jobless/presentation/bloc/categories/categories_cubit.dart';
import 'package:jobless/presentation/bloc/gallery/gallery_cubit.dart';
import 'package:jobless/presentation/bloc/hidenavbar/hidenavbar_cubit.dart';
import 'package:jobless/presentation/bloc/industries/industries_cubit.dart';
import 'package:jobless/presentation/bloc/location/location_cubit.dart';
import 'package:jobless/presentation/bloc/navigation/navigation_cubit.dart';
import 'package:jobless/presentation/bloc/notifications/notification_cubit.dart';
import 'package:jobless/presentation/bloc/postdata/postdata_cubit.dart';
import 'package:jobless/presentation/bloc/profile/profile_cubit.dart';
import 'package:jobless/presentation/bloc/recommendations/recommendation_cubit.dart';
import 'package:jobless/presentation/bloc/schedule/schedule_cubit.dart';
import 'package:jobless/presentation/bloc/theme/theme_cubit.dart';
import 'package:jobless/presentation/bloc/tips/tips_cubit.dart';
import 'package:jobless/presentation/bloc/typevacancy/typevacancy_cubit.dart';
import 'package:jobless/presentation/bloc/user/user_cubit.dart';
import 'package:jobless/presentation/bloc/vacancies/vacancies_cubit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'injection_container.dart' as di;
import 'package:timeago/timeago.dart' as timeago;

import 'presentation/routers/app_routes.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseApi();
  await Permission.notification.request();
  await EasyLocalization.ensureInitialized();
  await di.init();
  timeago.setLocaleMessages('id', timeago.IdShortMessages());
  runApp(EasyLocalization(
    supportedLocales: const [Locale('en'), Locale('id')],
    path: 'assets/translations',
    fallbackLocale: const Locale('id'),
    startLocale: const Locale('id'),
    useOnlyLangCode: true,
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.getIt<NavigationCubit>()),
        BlocProvider(create: (_) => di.getIt<ThemeCubit>()..initialAppTheme()),
        BlocProvider(
            create: (_) => di.getIt<BookmarksCubit>()..bookmaksVacancies()),
        BlocProvider(create: (_) => di.getIt<UserCubit>()),
        BlocProvider(create: (_) => di.getIt<HideNavBarCubit>()),
        BlocProvider<AuthCubit>(create: (_) => di.getIt<AuthCubit>()),
        BlocProvider<CategoriesCubit>(
            create: (_) => di.getIt<CategoriesCubit>()),
        BlocProvider<EmployeeProfileCubit>(
            create: (_) => di.getIt<EmployeeProfileCubit>()),
        BlocProvider<TipsCubit>(create: (_) => di.getIt<TipsCubit>()),
        BlocProvider<VacanciesCubit>(create: (_) => di.getIt<VacanciesCubit>()),
        BlocProvider<RecommendationCubit>(
            create: (_) => di.getIt<RecommendationCubit>()),
        BlocProvider<IndustriesCubit>(
            create: (_) => di.getIt<IndustriesCubit>()),
        BlocProvider<TypeVacancyCubit>(
            create: (_) => di.getIt<TypeVacancyCubit>()),
        BlocProvider<LocationCubit>(create: (_) => di.getIt<LocationCubit>()),
        BlocProvider<PostDataCubit>(create: (_) => di.getIt<PostDataCubit>()),
        BlocProvider<ScheduleCubit>(create: (_) => di.getIt<ScheduleCubit>()),
        BlocProvider<ApplicantsCubit>(
            create: (_) => di.getIt<ApplicantsCubit>()),
        BlocProvider<NotificationCubit>(
            create: (_) => di.getIt<NotificationCubit>()),
        BlocProvider<GalleryCubit>(create: (_) => di.getIt<GalleryCubit>())
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Jobless',
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            locale: context.locale,
            theme: ThemeModel().lightTheme,
            darkTheme: ThemeModel().darkTheme,
            themeMode: context
                .select((ThemeCubit themeCubit) => themeCubit.state.themeMode),
            // home: const AppPage(),
            navigatorKey: di.getIt<NavigationService>().navigatorKey,
            onGenerateRoute: RouteGenerator.generateRoute,
          );
        },
      ),
    );
  }
}
