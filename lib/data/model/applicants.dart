import 'package:jobless/data/model/pagination.dart';
import 'package:jobless/domain/entities/applicants_entity.dart';

class ApplicantsModel extends ApplicantsEntity {
  ApplicantsModel.fromJSON(Map<String, dynamic> json)
      : super(
            error: json['error'],
            message: json['message'],
            data: List.from(json['data'])
                .map((e) => ResultApplicantsModel.fromJSON(e))
                .toList(),
            pagination: PaginationModel.fromJSON(json['pagination']));
}

class ResultApplicantsModel extends ResultApplicantsEntity {
  ResultApplicantsModel.fromJSON(Map<String, dynamic> json)
      : super(
            id: json['id'],
            applicant: ResultApplicantModel.fromJSON(json['applicant']),
            vacancy: ResultVacancyModel.fromJSON(json['vacancies']),
            cv: json['cv'],
            desc: json['desc'],
            date: json['date'],
            status: json['status'],
            interviewdate: json['interviewdate'],
            interviewtime: json['interviewtime'],
            message: json['message'],
            joininterview: json['joininterview'],
            createdAt: json['createdAt'],
            updatedAt: json['updatedAt']);
  Map<String, dynamic> toJson() => {
        'id': id,
        'applicant': applicant,
        'vacancy': vacancy,
        'cv': cv,
        'desc': desc,
        'status': status,
        'joininterview': joininterview,
        'createdAt': createdAt,
        'updatedAt': updatedAt
      };
}

class ResultApplicantModel extends ResultApplicantEntity {
  ResultApplicantModel.fromJSON(Map<String, dynamic> json)
      : super(
            id: json['id'],
            email: json['email'],
            fullname: json['employeeprofile']['fullname'],
            gender: json['employeeprofile']['gender'],
            skill: json['employeeprofile']['skill'],
            address: json['employeeprofile']['address'],
            dateofbirth: json['employeeprofile']['dateofbirth'],
            photo: json['employeeprofile']['photo']);
  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'fullname': fullname,
        'gender': gender,
        'skill': skill,
        'address': address,
        'dateofbirth': dateofbirth,
        'photo': photo
      };
}

class ResultVacancyModel extends ResultVacancyEntity {
  ResultVacancyModel.fromJSON(Map<String, dynamic> json)
      : super(
            id: json['id'],
            title: json['title'],
            category: json['category']['category'],
            location: json['location']['location'],
            salary: json['salary'],
            typevacancy: json['typevacancy']['type'],
            desc: json['desc'],
            requirements: List.from(json['vacancyrequirements'])
                .map((e) => ResultRequeModel.fromJSON(e))
                .toList(),
            image: json['image'],
            userId: json['useid'],
            companyName: json['user']['employersprofile']['companyname'],
            photoCompany: json['user']['employersprofile']['photo']);
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'location': location,
        'salary': salary,
        'typevacancy': typevacancy,
        'desc': desc,
        'image': image,
        'userId': userId,
        'requirements': requirements,
        'companyname': companyName,
        'photoCompany': photoCompany
      };
}

class ResultRequeModel extends ResultRequeEntity {
  ResultRequeModel.fromJSON(Map<String, dynamic> json)
      : super(requirement: json['requirement']);
}
