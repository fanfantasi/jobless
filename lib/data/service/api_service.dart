import 'dart:io';

import 'package:dio/dio.dart';
import 'package:jobless/core/config.dart';
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
import 'package:jobless/data/service/logging_interceptors.dart';

class ApiService {
  Dio get dio => _dio();
  Dio _dio() {
    final options = BaseOptions(
      baseUrl: "${Config.baseUrl}/api/",
      connectTimeout: const Duration(milliseconds: 5000),
      receiveTimeout: const Duration(milliseconds: 3000),
      contentType: "application/json;charset=utf-8",
      validateStatus: (_) => true,
    );

    var dio = Dio(options);

    dio.interceptors.add(LoggingInterceptors());
    return dio;
  }

  Future<AuthModel> signOut({String? email, String? password}) async {
    try {
      Response response = await dio
          .post("users/register", data: {'email': email, 'password': password});
      return AuthModel.fromJSON(response.data);
    } catch (error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  Future<AuthModel> signIn({String? email, String? password}) async {
    try {
      Response response = await dio
          .post("users/login", data: {'email': email, 'password': password});
      return AuthModel.fromJSON(response.data);
    } catch (error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  Future<UserModel> isSignIn({String? token}) async {
    try {
      Response response = await dio.get("users/user",
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return UserModel.fromJSON(response.data);
    } catch (error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  Future<ResultModel> employeeprofile(
      {String? token,
      Object? jobcategories,
      String? fullname,
      String? dateofbirth,
      String? address,
      String? skill,
      String? gender,
      File? photo,
      String? oldPhoto}) async {
    try {
      FormData data = FormData.fromMap({
        'jobcategories': jobcategories,
        'fullname': fullname,
        'dateofbirth': dateofbirth,
        'address': address,
        'skill': skill,
        'gender': gender,
        'photo': photo == null
            ? null
            : await MultipartFile.fromFile(
                photo.path,
                filename: photo.path.split('/').last,
              ),
        'oldPhoto': oldPhoto
      });

      Response response = await dio.patch("users/employee",
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return ResultModel.fromJSON(response.data);
    } catch (error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  Future<ResultModel> employersprofile(
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
    try {
      FormData data = FormData.fromMap({
        'email': email,
        'companyname': companyname,
        'address': address,
        'officelocation': officelocation,
        'industryId': industryId,
        'industrytypeId': industrytypeId,
        'companysize': companySize,
        'website': website,
        'desc': desc,
        'file': file == null
            ? null
            : await MultipartFile.fromFile(
                file.path,
                filename: file.path.split('/').last,
              ),
        'oldFile': oldFile
      });

      Response response = await dio.patch("users/employers",
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return ResultModel.fromJSON(response.data);
    } catch (error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  Future<ResultModel> updatePhotoProfileEmployers(
      {String? token, File? file, String? oldFile}) async {
    try {
      FormData data = FormData.fromMap({
        'file': file == null
            ? null
            : await MultipartFile.fromFile(
                file.path,
                filename: file.path.split('/').last,
              ),
        'oldFile': oldFile
      });

      Response response = await dio.patch("users/employers/photo",
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return ResultModel.fromJSON(response.data);
    } catch (error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  Future<ResultModel> uploadGalleryEmployers(
      {String? token, String? employersId, File? file, String? oldFile}) async {
    try {
      FormData data = FormData.fromMap({
        'employeeprofileId': employersId,
        'file': file == null
            ? null
            : await MultipartFile.fromFile(
                file.path,
                filename: file.path.split('/').last,
              ),
        'oldFile': oldFile
      });

      Response response = await dio.patch("user/gallery",
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return ResultModel.fromJSON(response.data);
    } catch (error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  Future<GalleryModel> galleryEmployers({String? token, String? id}) async {
    try {
      Response response = await dio.get("user/gallery/$id",
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return GalleryModel.fromJSON(response.data);
    } catch (error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  Future<ResultModel> deletegalleryEmployers(
      {String? token, String? id}) async {
    try {
      Response response = await dio.delete("user/gallery",
          data: {'id': id},
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return ResultModel.fromJSON(response.data);
    } catch (error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  Future<CategoriesModel> categories(
      {String? token, int? page, int? limit, String? params}) async {
    try {
      Response response = await dio.get(
          "categories?page=$page&limit=$limit$params",
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return CategoriesModel.fromJSON(response.data);
    } catch (error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  Future<ResultModel> postcategories(
      {String? token, String? id, String? category}) async {
    try {
      Response response = await dio.post("categories",
          data: {'id': id, 'category': category},
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return ResultModel.fromJSON(response.data);
    } catch (error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  Future<ResultModel> deletecategories({String? token, String? id}) async {
    try {
      Response response = await dio.delete("categories",
          data: {'id': id},
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return ResultModel.fromJSON(response.data);
    } catch (error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  Future<TypeVacancyModel> typevacancy(
      {String? token, int? page, int? limit, String? params}) async {
    try {
      Response response = await dio.get(
          "typevacancy?page=$page&limit=$limit$params",
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return TypeVacancyModel.fromJSON(response.data);
    } catch (error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  Future<TipsModel> tips({String? token, int? page, String? params}) async {
    try {
      Response response = await dio.get("tips?page=$page$params",
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return TipsModel.fromJSON(response.data);
    } catch (error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  Future<VacanciesModel> vacancies(
      {String? token, int? page, String? params}) async {
    try {
      Response response = await dio.get("vacancies?page=$page$params",
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return VacanciesModel.fromJSON(response.data);
    } catch (error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  Future<ResultModel> inactiveVacancy({String? token, String? id}) async {
    try {
      Response response = await dio.post("vacancies/inactive",
          data: {'id': id},
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return ResultModel.fromJSON(response.data);
    } catch (error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

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
    try {
      FormData data = FormData.fromMap({
        'id': id,
        'title': title,
        'categoryId': categoriId,
        'salary': salary,
        'locationId': locationId,
        'typevacancyId': typevacancyId,
        'desc': desc,
        'requirements': requirements,
        'linkexternal': linkexternal,
        'file': file == null
            ? null
            : await MultipartFile.fromFile(
                file.path,
                filename: file.path.split('/').last,
              ),
        'oldFile': oldFile,
        'status': status ?? 'active'
      });

      Response response = await dio.patch("vacancies",
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return ResultModel.fromJSON(response.data);
    } catch (error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  Future<IndustriesModel> industries(
      {String? token, int? page, int? limit}) async {
    try {
      Response response = await dio.get("industries?page=$page&limit=$limit",
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return IndustriesModel.fromJSON(response.data);
    } catch (error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  Future<LocationModel> location(
      {String? token, int? page, int? limit, String? params}) async {
    try {
      Response response = await dio.get(
          "location?page=$page&limit=$limit$params",
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return LocationModel.fromJSON(response.data);
    } catch (error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  Future<ApplicantsModel> getApplicantsByMyVacancy(
      {String? token, int? page, String? params}) async {
    try {
      Response response = await dio.get(
          "applicants/myvacancy?page=$page$params",
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return ApplicantsModel.fromJSON(response.data);
    } catch (error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  Future<ApplicantsModel> getApplicants(
      {String? token, int? page, String? params}) async {
    try {
      Response response = await dio.get("applicants?page=$page$params",
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return ApplicantsModel.fromJSON(response.data);
    } catch (error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  Future<ResultApplicantsModel> getApplicantFindOne(
      {String? token, String? params}) async {
    try {
      Response response = await dio.get("applicants/$params",
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return ResultApplicantsModel.fromJSON(response.data['data']);
    } catch (error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

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
      String? oldFile}) async {
    try {
      FormData data = FormData.fromMap({
        'id': id,
        'applicantId': applicantId,
        'vacancyId': vacancyId,
        'desc': desc,
        'status': status ?? 'pending',
        'interviewdate': interviewdate,
        'interviewtime': interviewtime,
        'message': message,
        'file': file == null
            ? null
            : await MultipartFile.fromFile(
                file.path,
                filename: file.path.split('/').last,
              ),
        'oldFile': oldFile,
      });
      Response response = await dio.patch("applicants",
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return ResultModel.fromJSON(response.data);
    } catch (error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  Future<ResultModel> joinInterview(
      {String? token, String? id, bool? join}) async {
    try {
      Response response = await dio.post("applicants/joininterview",
          data: {'id': id, 'joinInterview': join},
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return ResultModel.fromJSON(response.data);
    } catch (error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  Future<NotificationModel> getNotification(
      {String? token, int? page, String? params}) async {
    try {
      Response response = await dio.get("notifications?page=$page$params",
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return NotificationModel.fromJSON(response.data);
    } catch (error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  Future<ResultModel> updateReadNotification(
      {String? token, String? params}) async {
    try {
      Response response = await dio.post("notifications/read",
          data: {'id': params},
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return ResultModel.fromJSON(response.data);
    } catch (error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  Future<ScheduleModel> getSchedule({String? token, String? params}) async {
    try {
      Response response = await dio.get("applicants/date$params",
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return ScheduleModel.fromJSON(response.data);
    } catch (error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }
}
