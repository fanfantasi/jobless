import 'package:get_it/get_it.dart';
import 'package:jobless/data/datasource/datasource.dart';
import 'package:jobless/data/datasource/datasource_impl.dart';
import 'package:jobless/data/repositories/repository_impl.dart';
import 'package:jobless/data/service/api_service.dart';
import 'package:jobless/domain/repositories/repository.dart';
import 'package:jobless/domain/usecases/get_applicants_usecase.dart';
import 'package:jobless/domain/usecases/get_applicantsbymyvacancy_usecase.dart';
import 'package:jobless/domain/usecases/get_applicationfindone_usecase.dart';
import 'package:jobless/domain/usecases/categories/get_categories_usecase.dart';
import 'package:jobless/domain/usecases/get_industries_usecase.dart';
import 'package:jobless/domain/usecases/get_location_usecase.dart';
import 'package:jobless/domain/usecases/get_notification_usecase.dart';
import 'package:jobless/domain/usecases/get_schedule.dart';
import 'package:jobless/domain/usecases/get_tips_usecase.dart';
import 'package:jobless/domain/usecases/user/delete_galleryemployers_usecase.dart';
import 'package:jobless/domain/usecases/user/get_galleryemployers_usecase.dart';
import 'package:jobless/domain/usecases/user/patch_galleryemployers_usecase.dart';
import 'package:jobless/domain/usecases/user/patch_photoprofile_usecase.dart';
import 'package:jobless/domain/usecases/vacancy/get_typevacancy_usecase.dart';
import 'package:jobless/domain/usecases/get_user_usecase.dart';
import 'package:jobless/domain/usecases/user/auth_usecase.dart';
import 'package:jobless/domain/usecases/get_theme.dart';
import 'package:jobless/domain/usecases/vacancy/get_vancancies_usecase.dart';
import 'package:jobless/domain/usecases/patch_applicants_usecase.dart';
import 'package:jobless/domain/usecases/vacancy/patch_vacancy_usecase.dart';
import 'package:jobless/domain/usecases/post_joinInterview_usecase.dart';
import 'package:jobless/domain/usecases/post_theme.dart';
import 'package:jobless/domain/usecases/put_updatereadnotification_usecase.dart';
import 'package:jobless/domain/usecases/vacancy/post_inactive_usecase.dart';
import 'package:jobless/presentation/bloc/applicants/applicants_cubit.dart';
import 'package:jobless/presentation/bloc/auth/auth_cubit.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

import 'core/navigationservice.dart';
import 'domain/usecases/categories/delete_category_usecase.dart';
import 'domain/usecases/categories/post_category_usecase.dart';
import 'domain/usecases/user/patch_employeeprofile_usecase.dart';
import 'domain/usecases/user/patch_employerprofile_usecase.dart';
import 'domain/usecases/user/signout_usecase.dart';
import 'presentation/bloc/bell/bell_cubit.dart';
import 'presentation/bloc/bookmarks/bookmarks_cubit.dart';
import 'presentation/bloc/slider/slider_cubit.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // bloc
  getIt.registerFactory<NavigationCubit>(() => NavigationCubit());
  getIt.registerFactory<BellCubit>(() => BellCubit());
  getIt.registerFactory<BookmarksCubit>(() => BookmarksCubit());
  getIt.registerFactory<ThemeCubit>(() => ThemeCubit());
  getIt.registerFactory<UserCubit>(() => UserCubit());
  getIt.registerFactory<HideNavBarCubit>(() => HideNavBarCubit());

  getIt.registerFactory<AuthCubit>(() => AuthCubit(
      authUseCase: getIt.call(),
      userUseCase: getIt.call(),
      signOutUseCase: getIt.call()));

  getIt.registerFactory<CategoriesCubit>(() => CategoriesCubit(
      categoriesUseCase: getIt.call(),
      postCategoriesUseCase: getIt.call(),
      deleteCategoriesUseCase: getIt.call()));

  getIt.registerFactory<IndustriesCubit>(
      () => IndustriesCubit(industriesUseCase: getIt.call()));

  getIt.registerFactory<LocationCubit>(
      () => LocationCubit(locationUseCase: getIt.call()));

  getIt.registerFactory<TypeVacancyCubit>(
      () => TypeVacancyCubit(typeVacancyUseCase: getIt.call()));

  getIt.registerFactory<EmployeeProfileCubit>(() => EmployeeProfileCubit(
      employeeProfileUseCase: getIt.call(),
      photoProfileEmployersUseCase: getIt.call(),
      galleryEmployersUseCase: getIt.call(),
      employersProfileUseCase: getIt.call()));
  getIt.registerFactory<GalleryCubit>(() => GalleryCubit(
      getgalleryEmployersUseCase: getIt.call(),
      deleteGalleryEmployersUseCase: getIt.call()));

  getIt.registerFactory<SliderCubit>(
      () => SliderCubit(tipsUseCase: getIt.call()));
  getIt.registerFactory<TipsCubit>(() => TipsCubit(tipsUseCase: getIt.call()));

  getIt.registerFactory<VacanciesCubit>(
      () => VacanciesCubit(vacanciesUseCase: getIt.call()));
  getIt.registerFactory<RecommendationCubit>(
      () => RecommendationCubit(vacanciesUseCase: getIt.call()));

  getIt.registerFactory<PostDataCubit>(() => PostDataCubit(
      patchVacancyUseCase: getIt.call(),
      inactiveUseCase: getIt.call(),
      patchApplicantsUseCase: getIt.call(),
      joinInterviewUseCase: getIt.call()));

  getIt.registerFactory<ApplicantsCubit>(() => ApplicantsCubit(
      applicantsUseCase: getIt.call(),
      applicantsByMyVacancyUseCase: getIt.call(),
      applicationFindOneUseCase: getIt.call()));

  getIt.registerFactory<NotificationCubit>(() => NotificationCubit(
      notificationUseCase: getIt.call(),
      updateReadNotificationUseCase: getIt.call()));

  getIt.registerFactory<ScheduleCubit>(() => ScheduleCubit(
      scheduleUseCase: getIt.call(), applicantsUseCase: getIt.call()));

  // useCase
  getIt.registerLazySingleton<GetThemeUseCase>(
      () => GetThemeUseCase(pref: getIt.call()));
  getIt.registerLazySingleton<PostThemeUseCase>(
      () => PostThemeUseCase(pref: getIt.call()));

  getIt.registerLazySingleton<AuthUseCase>(
      () => AuthUseCase(repository: getIt.call()));
  getIt.registerLazySingleton<SignOutUseCase>(
      () => SignOutUseCase(repository: getIt.call()));
  getIt.registerLazySingleton<UserUseCase>(
      () => UserUseCase(repository: getIt.call()));

  getIt.registerLazySingleton<CategoriesUseCase>(
      () => CategoriesUseCase(repository: getIt.call()));
  getIt.registerLazySingleton<PostCategoriesUseCase>(
      () => PostCategoriesUseCase(repository: getIt.call()));
  getIt.registerLazySingleton<DeleteCategoriesUseCase>(
      () => DeleteCategoriesUseCase(repository: getIt.call()));

  getIt.registerLazySingleton<TypeVacancyUseCase>(
      () => TypeVacancyUseCase(repository: getIt.call()));

  getIt.registerLazySingleton<IndustriesUseCase>(
      () => IndustriesUseCase(repository: getIt.call()));

  getIt.registerLazySingleton<LocationUseCase>(
      () => LocationUseCase(repository: getIt.call()));

  getIt.registerLazySingleton<EmployeeProfileUseCase>(
      () => EmployeeProfileUseCase(repository: getIt.call()));
  getIt.registerLazySingleton<EmployersProfileUseCase>(
      () => EmployersProfileUseCase(repository: getIt.call()));
  getIt.registerLazySingleton<PhotoProfileEmployersUseCase>(
      () => PhotoProfileEmployersUseCase(repository: getIt.call()));
  getIt.registerLazySingleton<GalleryEmployersUseCase>(
      () => GalleryEmployersUseCase(repository: getIt.call()));
  getIt.registerLazySingleton<GetGalleryEmployersUseCase>(
      () => GetGalleryEmployersUseCase(repository: getIt.call()));
  getIt.registerLazySingleton<DeleteGalleryEmployersUseCase>(
      () => DeleteGalleryEmployersUseCase(repository: getIt.call()));

  getIt.registerLazySingleton<TipsUseCase>(
      () => TipsUseCase(repository: getIt.call()));

  getIt.registerLazySingleton<VacanciesUseCase>(
      () => VacanciesUseCase(repository: getIt.call()));
  getIt.registerLazySingleton<InactiveUseCase>(
      () => InactiveUseCase(repository: getIt.call()));

  getIt.registerLazySingleton<PatchVacancyUseCase>(
      () => PatchVacancyUseCase(repository: getIt.call()));

  getIt.registerLazySingleton<ApplicantsUseCase>(
      () => ApplicantsUseCase(repository: getIt.call()));
  getIt.registerLazySingleton<ApplicantsByMyVacancyUseCase>(
      () => ApplicantsByMyVacancyUseCase(repository: getIt.call()));
  getIt.registerLazySingleton<ApplicationFindOneUseCase>(
      () => ApplicationFindOneUseCase(repository: getIt.call()));

  getIt.registerLazySingleton<PatchApplicantsUseCase>(
      () => PatchApplicantsUseCase(repository: getIt.call()));
  getIt.registerLazySingleton<JoinInterviewUseCase>(
      () => JoinInterviewUseCase(repository: getIt.call()));

  getIt.registerLazySingleton<NotificationUseCase>(
      () => NotificationUseCase(repository: getIt.call()));
  getIt.registerLazySingleton<UpdateReadNotificationUseCase>(
      () => UpdateReadNotificationUseCase(repository: getIt.call()));

  getIt.registerLazySingleton<ScheduleUseCase>(
      () => ScheduleUseCase(repository: getIt.call()));
  //repository
  getIt.registerLazySingleton<Repository>(
      () => RepositoryImpl(dataSource: getIt.call()));

  //remote data
  getIt.registerLazySingleton<DataSource>(
      () => DataSourceImpl(api: getIt.call()));

  // External
  getIt.registerLazySingleton<ApiService>(() => ApiService());
  final prefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => prefs);

  getIt.registerLazySingleton(() => NavigationService());
}
