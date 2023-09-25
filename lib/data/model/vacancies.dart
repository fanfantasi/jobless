import 'package:jobless/data/model/pagination.dart';
import 'package:jobless/domain/entities/vacancies_entity.dart';

class VacanciesModel extends VacanciesEntity {
  VacanciesModel.fromJSON(Map<String, dynamic> json)
      : super(
            error: json['error'],
            message: json['message'],
            data: List.from(json['data'])
                .map((e) => ResultVacanciesModel.fromJSON(e))
                .toList(),
            pagination: PaginationModel.fromJSON(json['pagination']));
}

class ResultVacanciesModel extends ResultVacanciesEntity {
  ResultVacanciesModel.fromJSON(Map<String, dynamic> json)
      : super(
            id: json['id'],
            title: json['title'],
            category: json['category']['category'],
            salary: json['salary'],
            location: json['location']['location'],
            typevacancy: json['typevacancy']['type'],
            status: json['status'],
            desc: json['desc'],
            image: json['image'],
            requirement: List.from(json['vacancyrequirements'])
                .map((e) => ResultRequirementsModel.fromJSON(e))
                .toList(),
            userCompany: ResultUserCompanyModel.fromJSON(json['user']),
            createdAt: json['createdAt'],
            bookmarks: false,
            application: json['_count']['applicants'],
            verify: json['verify']);
}

class ResultRequirementsModel extends ResultRequirementsEntity {
  ResultRequirementsModel.fromJSON(Map<String, dynamic> json)
      : super(requirement: json['requirement']);
  Map<String, dynamic> toJson() => {'requirement': requirement};
}

class ResultUserCompanyModel extends ResultUserCompanyEntity {
  ResultUserCompanyModel.fromJSON(Map<String, dynamic> json)
      : super(
            companyname: json['employersprofile']['companyname'],
            industry: json['employersprofile']['industrialtype']['industry']
                ['industry'],
            officelocation: json['employersprofile']['officelocation'],
            photo: json['employersprofile']['photo']);
}
