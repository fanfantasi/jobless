import 'dart:io';

import 'package:jobless/data/datasource/datasource.dart';
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
import 'package:jobless/domain/repositories/repository.dart';

class RepositoryImpl implements Repository {
  final DataSource dataSource;

  RepositoryImpl({required this.dataSource});

  @override
  Future<AuthModel> signOut(String email, String password) async {
    return await dataSource.signOut(email: email, password: password);
  }

  @override
  Future<AuthModel> authUser(String email, String password) async {
    return await dataSource.signIn(email: email, password: password);
  }

  @override
  Future<UserModel> isSignIn(String token) async {
    return await dataSource.isSignIn(token: token);
  }

  @override
  Future<CategoriesModel> categories(
      String token, page, limit, String params) async {
    return await dataSource.categories(
        token: token, page: page, limit: limit, params: params);
  }

  @override
  Future<ResultModel> postcategories(
          {String? token, String? id, String? category}) async =>
      await dataSource.postcategories(token: token, id: id, category: category);
  @override
  Future<ResultModel> deletecategories({String? token, String? id}) async =>
      await dataSource.deletecategories(token: token, id: id);

  @override
  Future<ResultModel> patchEmployeeProfile(
      {String? token,
      Object? jobcategories,
      String? fullname,
      String? dateofbirth,
      String? address,
      String? skill,
      String? gender,
      File? photo,
      String? oldPhoto}) async {
    return await dataSource.patchEmployeeProfile(
        token: token,
        jobcategories: jobcategories,
        fullname: fullname,
        dateofbirth: dateofbirth,
        address: address,
        skill: skill,
        photo: photo,
        oldPhoto: oldPhoto);
  }

  @override
  Future<TipsModel> tips(String token, int page, String params) async {
    return await dataSource.tips(token: token, page: page, params: params);
  }

  @override
  Future<VacanciesModel> vacancies(
      String token, int page, String params) async {
    return await dataSource.vacancies(token: token, page: page, params: params);
  }

  @override
  Future<ResultModel> inactiveVacancy({String? token, String? id}) async =>
      await dataSource.inactiveVacancy(token: token, id: id);

  @override
  Future<IndustriesModel> industries(String token, int page, int limit) async {
    return await dataSource.industries(token: token, page: page, limit: limit);
  }

  @override
  Future<LocationModel> locaton(
    String token,
    int page,
    int limit,
    String params,
  ) async {
    return await dataSource.location(
        token: token, page: page, limit: limit, params: params);
  }

  @override
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
      String? oldFile}) async {
    return await dataSource.pathEmployerProfile(
        token: token,
        email: email,
        companyname: companyname,
        address: address,
        officelocation: officelocation,
        industryId: industryId,
        industrytypeId: industrytypeId,
        companySize: companySize,
        website: website,
        desc: desc,
        file: file,
        oldFile: oldFile);
  }

  @override
  Future<ResultModel> updatePhotoProfileEmployers(
          {String? token, File? file, String? oldFile}) async =>
      await dataSource.updatePhotoProfileEmployers(
          token: token, file: file, oldFile: oldFile);
  @override
  Future<ResultModel> uploadGalleryEmployers(
          {String? token,
          String? employersId,
          File? file,
          String? oldFile}) async =>
      await dataSource.uploadGalleryEmployers(
          token: token, employersId: employersId, file: file, oldFile: oldFile);
  @override
  Future<GalleryModel> galleryEmployers({String? token, String? id}) async =>
      await dataSource.galleryEmployers(token: token, id: id);
  @override
  Future<ResultModel> deletegalleryEmployers(
          {String? token, String? id}) async =>
      await dataSource.deletegalleryEmployers(token: token, id: id);

  @override
  Future<TypeVacancyModel> typevacancy(
      String token, int page, int limit, String params) async {
    return await dataSource.typevacancy(
        token: token, page: page, limit: limit, params: params);
  }

  @override
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
      String? status}) async {
    return await dataSource.patchvancancy(
        token: token,
        id: id,
        title: title,
        categoriId: categoriId,
        salary: salary,
        locationId: locationId,
        typevacancyId: typevacancyId,
        desc: desc,
        requirements: requirements,
        linkexternal: linkexternal,
        file: file,
        oldFile: oldFile,
        status: status);
  }

  @override
  Future<ApplicantsModel> getApplicants(
      {String? token, int? page, String? params}) async {
    return await dataSource.getApplicants(
        token: token, page: page, params: params);
  }

  @override
  Future<ResultApplicantsModel> getApplicationFindOne(
      {String? token, String? params}) async {
    return await dataSource.getApplicationFindOne(token: token, params: params);
  }

  @override
  Future<ApplicantsModel> getApplicantsByMyVacancies(
      {String? token, int? page, String? params}) async {
    return await dataSource.getApplicantsByMyVacancies(
        token: token, page: page, params: params);
  }

  @override
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
      String? oldFile}) async {
    return await dataSource.patchApplicants(
        token: token,
        id: id,
        applicantId: applicantId,
        vacancyId: vacancyId,
        desc: desc,
        status: status,
        interviewdate: interviewdate,
        interviewtime: interviewtime,
        message: message,
        file: file,
        oldFile: oldFile);
  }

  @override
  Future<ResultModel> joinInterview(
      {String? token, String? id, bool? join}) async {
    return await dataSource.joinInterview(token: token, id: id, join: join);
  }

  @override
  Future<NotificationModel> getNotification(
      String? token, int? page, String? params) async {
    return await dataSource.notification(
        token: token, page: page, params: params);
  }

  @override
  Future<ResultModel> updateReadNotification(
      String token, String params) async {
    return await dataSource.updateReadNotification(
        token: token, params: params);
  }

  @override
  Future<ScheduleModel> getSchedule({String? token, String? params}) async =>
      await dataSource.getSchedule(token: token, params: params);
}
