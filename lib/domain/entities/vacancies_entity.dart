import 'package:jobless/domain/entities/pagination_entity.dart';

class VacanciesEntity {
  final String? error;
  final List<ResultVacanciesEntity> data;
  final String message;
  final PaginationEntity? pagination;
  const VacanciesEntity(
      {this.error, required this.data, required this.message, this.pagination});
}

class ResultVacanciesEntity {
  final String? id;
  final String? title;
  final String? category;
  final String? salary;
  final String? location;
  final String? typevacancy;
  final String? status;
  final String? desc;
  final String? image;
  final List<ResultRequirementsEntity>? requirement;
  final ResultUserCompanyEntity? userCompany;
  final String? createdAt;
  final int? application;
  final bool? bookmarks;
  final bool? verify;
  const ResultVacanciesEntity(
      {this.id,
      this.title,
      this.category,
      this.salary,
      this.location,
      this.status,
      this.typevacancy,
      this.desc,
      this.requirement,
      this.image,
      this.userCompany,
      this.createdAt,
      this.bookmarks,
      this.application,
      this.verify});
}

class ResultRequirementsEntity {
  final String? requirement;
  const ResultRequirementsEntity({this.requirement});
}

class ResultUserCompanyEntity {
  final String? companyname;
  final String? industry;
  final String? photo;
  final String? officelocation;
  const ResultUserCompanyEntity(
      {this.companyname, this.industry, this.photo, this.officelocation});
}
