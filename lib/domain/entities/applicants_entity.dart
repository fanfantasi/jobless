import 'package:jobless/domain/entities/pagination_entity.dart';

class ApplicantsEntity {
  final String? error;
  final List<ResultApplicantsEntity> data;
  final String message;
  final PaginationEntity? pagination;
  const ApplicantsEntity(
      {this.error, required this.data, required this.message, this.pagination});
}

class ResultApplicantsEntity {
  final String? id;
  final ResultApplicantEntity? applicant;
  final ResultVacancyEntity? vacancy;
  final String? cv;
  final String? desc;
  final String? date;
  final String? status;
  final String? interviewdate;
  final String? interviewtime;
  final String? message;
  final bool? joininterview;
  final String? createdAt;
  final String? updatedAt;
  const ResultApplicantsEntity(
      {this.id,
      this.applicant,
      this.vacancy,
      this.cv,
      this.desc,
      this.date,
      this.status,
      this.interviewdate,
      this.interviewtime,
      this.joininterview,
      this.message,
      this.createdAt,
      this.updatedAt});
}

class ResultApplicantEntity {
  final String? id;
  final String? email;
  final String? fullname;
  final String? gender;
  final String? skill;
  final String? address;
  final String? dateofbirth;
  final String? photo;
  const ResultApplicantEntity(
      {this.id,
      this.email,
      this.fullname,
      this.gender,
      this.skill,
      this.address,
      this.dateofbirth,
      this.photo});
}

class ResultVacancyEntity {
  final String? id;
  final String? title;
  final String? category;
  final String? location;
  final String? salary;
  final String? typevacancy;
  final String? desc;
  final List<ResultRequeEntity>? requirements;
  final String? image;
  final String? userId;
  final String? companyName;
  final String? photoCompany;
  const ResultVacancyEntity(
      {this.id,
      this.title,
      this.category,
      this.location,
      this.salary,
      this.typevacancy,
      this.desc,
      this.requirements,
      this.image,
      this.userId,
      this.companyName,
      this.photoCompany});
}

class ResultRequeEntity {
  final String? requirement;
  const ResultRequeEntity({this.requirement});
}
