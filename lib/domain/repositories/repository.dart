import 'dart:io';

import 'package:jobless/data/model/applicants.dart';
import 'package:jobless/data/model/auth.dart';
import 'package:jobless/data/model/categories.dart';
import 'package:jobless/data/model/gallery.dart';
import 'package:jobless/data/model/industries.dart';
import 'package:jobless/data/model/location.dart';
import 'package:jobless/data/model/notification.dart';
import 'package:jobless/data/model/result.dart';
import 'package:jobless/data/model/schedule.dart';
import 'package:jobless/data/model/tips.dart';
import 'package:jobless/data/model/typevacancy.dart';
import 'package:jobless/data/model/user.dart';
import 'package:jobless/data/model/vacancies.dart';

abstract class Repository {
  Future<AuthModel> authUser(String email, String password);
  Future<AuthModel> signOut(String email, String password);
  Future<UserModel> isSignIn(String token);
  //Profile
  Future<ResultModel> patchEmployeeProfile(
      {String? token,
      Object? jobcategories,
      String? fullname,
      String? dateofbirth,
      String? address,
      String? skill,
      String? gender,
      File? photo,
      String? oldPhoto});
  //Profile Company
  Future<ResultModel> pathEmployerProfile(
      {String? token,
      String? email,
      String? companyname,
      String? address,
      String? officelocation,
      String? industryId,
      String? industrytypeId,
      String? companySize,
      String? website,
      String? desc,
      File? file,
      String? oldFile});
  Future<ResultModel> updatePhotoProfileEmployers(
      {String? token, File? file, String? oldFile});
  Future<ResultModel> uploadGalleryEmployers(
      {String? token, String? employersId, File? file, String? oldFile});
  Future<GalleryModel> galleryEmployers({String? token, String? id});
  Future<ResultModel> deletegalleryEmployers({String? token, String? id});

  Future<CategoriesModel> categories(
      String token, int page, int limit, String params);
  Future<ResultModel> postcategories(
      {String? token, String? id, String? category});
  Future<ResultModel> deletecategories({String? token, String? id});

  Future<IndustriesModel> industries(String token, int page, int limit);
  Future<TypeVacancyModel> typevacancy(
      String token, int page, int limit, String params);
  Future<LocationModel> locaton(
      String token, int page, int limit, String params);
  Future<TipsModel> tips(String token, int page, String params);
  Future<VacanciesModel> vacancies(String token, int page, String params);
  Future<ResultModel> inactiveVacancy({String? token, String? id});
  Future<ResultModel> patchvancancy(
      {String? token,
      String? id,
      String? title,
      String? categoriId,
      String? salary,
      String? locationId,
      String? typevacancyId,
      String? desc,
      Object? requirements,
      String? linkexternal,
      File? file,
      String? oldFile,
      String? status});
  //My Applicant My Vacancy
  Future<ApplicantsModel> getApplicantsByMyVacancies(
      {String? token, int? page, String? params});
  //Applicants
  Future<ApplicantsModel> getApplicants(
      {String? token, int? page, String? params});
  Future<ResultApplicantsModel> getApplicationFindOne(
      {String? token, String? params});
  Future<ResultModel> patchApplicants(
      {String? token,
      String? id,
      String? applicantId,
      String? vacancyId,
      String? desc,
      String? status,
      String? interviewdate,
      String? interviewtime,
      String? message,
      File? file,
      String? oldFile});
  Future<ResultModel> joinInterview({String? token, String? id, bool? join});
  Future<NotificationModel> getNotification(
      String token, int page, String params);
  Future<ResultModel> updateReadNotification(String token, String params);
  Future<ScheduleModel> getSchedule({String? token, String? params});
}
