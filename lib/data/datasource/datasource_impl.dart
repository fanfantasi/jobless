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
import 'package:jobless/data/service/api_service.dart';

class DataSourceImpl implements DataSource {
  final ApiService api;
  DataSourceImpl({required this.api});

  @override
  Future<AuthModel> signIn({String? email, String? password}) async =>
      await api.signIn(email: email, password: password);

  @override
  Future<AuthModel> signOut({String? email, String? password}) async =>
      await api.signOut(email: email, password: password);

  @override
  Future<UserModel> isSignIn({String? token}) async =>
      await api.isSignIn(token: token);

  @override
  Future<CategoriesModel> categories(
          {String? token, int? page, int? limit, String? params}) async =>
      await api.categories(
          token: token, page: page, limit: limit, params: params);
  @override
  Future<ResultModel> postcategories(
          {String? token, String? id, String? category}) async =>
      await api.postcategories(token: token, id: id, category: category);
  @override
  Future<ResultModel> deletecategories({String? token, String? id}) async =>
      await api.deletecategories(token: token, id: id);

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
          String? oldPhoto}) async =>
      await api.employeeprofile(
          token: token,
          fullname: fullname,
          dateofbirth: dateofbirth,
          address: address,
          skill: skill,
          gender: gender,
          jobcategories: jobcategories,
          photo: photo,
          oldPhoto: oldPhoto);
  @override
  Future<ResultModel> updatePhotoProfileEmployers(
          {String? token, File? file, String? oldFile}) async =>
      await api.updatePhotoProfileEmployers(
          token: token, file: file, oldFile: oldFile);
  @override
  Future<ResultModel> uploadGalleryEmployers(
          {String? token,
          String? employersId,
          File? file,
          String? oldFile}) async =>
      await api.uploadGalleryEmployers(
          token: token, employersId: employersId, file: file, oldFile: oldFile);
  @override
  Future<GalleryModel> galleryEmployers({String? token, String? id}) async =>
      await api.galleryEmployers(token: token, id: id);
  @override
  Future<ResultModel> deletegalleryEmployers(
          {String? token, String? id}) async =>
      await api.deletegalleryEmployers(token: token, id: id);

  @override
  Future<TipsModel> tips({String? token, int? page, String? params}) async =>
      await api.tips(token: token, page: page, params: params);

  @override
  Future<VacanciesModel> vacancies(
          {String? token, int? page, String? params}) async =>
      await api.vacancies(token: token, page: page, params: params);
  @override
  Future<ResultModel> inactiveVacancy({String? token, String? id}) async =>
      await api.inactiveVacancy(token: token, id: id);

  @override
  Future<IndustriesModel> industries(
          {String? token, int? page, int? limit}) async =>
      await api.industries(token: token, page: page, limit: limit);

  @override
  Future<LocationModel> location(
          {String? token, int? page, int? limit, String? params}) async =>
      await api.location(
          token: token, page: page, limit: limit, params: params);

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
          String? oldFile}) async =>
      await api.employersprofile(
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

  @override
  Future<TypeVacancyModel> typevacancy(
          {String? token, int? page, int? limit, String? params}) async =>
      await api.typevacancy(
          token: token, page: page, limit: limit, params: params);

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
          String? status}) async =>
      await api.patchvancancy(
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

  @override
  Future<ApplicantsModel> getApplicants(
          {String? token, int? page, String? params}) async =>
      await api.getApplicants(token: token, page: page, params: params);
  @override
  Future<ResultApplicantsModel> getApplicationFindOne(
          {String? token, String? params}) async =>
      await api.getApplicantFindOne(token: token, params: params);

  @override
  Future<ApplicantsModel> getApplicantsByMyVacancies(
          {String? token, int? page, String? params}) async =>
      await api.getApplicantsByMyVacancy(
          token: token, page: page, params: params);

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
          Object? message,
          File? file,
          String? oldFile}) async =>
      await api.patchApplicants(
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

  @override
  Future<ResultModel> joinInterview(
          {String? token, String? id, bool? join}) async =>
      await api.joinInterview(token: token, id: id, join: join);

  @override
  Future<NotificationModel> notification(
          {String? token, int? page, String? params}) async =>
      await api.getNotification(token: token, page: page, params: params);

  @override
  Future<ResultModel> updateReadNotification(
          {String? token, String? params}) async =>
      await api.updateReadNotification(token: token, params: params);

  @override
  Future<ScheduleModel> getSchedule({String? token, String? params}) async =>
      await api.getSchedule(token: token, params: params);
}
