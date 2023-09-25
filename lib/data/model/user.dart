import 'package:jobless/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel.fromJSON(Map<String, dynamic> json)
      : super(
          error: json['error'],
          message: json['message'],
          data: ResultUserModel.fromJSON(json['data']),
        );
}

class ResultUserModel extends ResultUserEntity {
  ResultUserModel.fromJSON(Map<String, dynamic> json)
      : super(
            id: json['id'],
            email: json['email'],
            statusprofile: json['statusprofile'],
            administrator: json['administrator'],
            employeeProfile: json['employeeprofile'] != null
                ? ResultEmployeeProfileModel.fromJSON(json['employeeprofile'])
                : null,
            employersProfile: json['employersprofile'] != null
                ? ResultEmployersProfileModel.fromJSON(json['employersprofile'])
                : null);

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'administrator': administrator,
        'statusprofile': statusprofile,
        'employeeprofile': employeeProfile,
        'employersprofile': employersProfile
      };
}

class ResultEmployeeProfileModel extends EmployeeProfileEntity {
  ResultEmployeeProfileModel.fromJSON(Map<String, dynamic> json)
      : super(
          id: json['id'],
          fullname: json['fullname'],
          dateofbirth: json['dateofbirth'],
          address: json['address'],
          gender: json['gender'],
          skill: json['skill'],
          photo: json['photo'],
          jobcategories: json['jobcategories'] != null
              ? List.from(json['jobcategories'])
                  .map((e) => ResultCategoryEmployee.fromJSON(e))
                  .toList()
              : null,
        );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullname': fullname,
        'dateofbirth': dateofbirth,
        'address': address,
        'gender': gender,
        'skill': skill,
        'photo': photo,
        'jobcategories': jobcategories
      };
}

class ResultEmployersProfileModel extends EmployersProfileEntity {
  ResultEmployersProfileModel.fromJSON(Map<String, dynamic> json)
      : super(
          id: json['id'],
          companyname: json['companyname'],
          officelocation: json['officelocation'],
          email: json['email'],
          address: json['address'],
          companysize: json['companysize'] ?? '',
          website: json['website'] ?? '',
          desc: json['desc'] ?? '',
          industrialType: IndustrialType.fromJSON(json['industrialtype']),
          photo: json['photo'],
        );
  Map<String, dynamic> toJson() => {
        'id': id,
        'companyname': companyname,
        'officelocation': officelocation,
        'email': email,
        'address': address,
        'companysize': companysize,
        'website': website,
        'desc': desc,
        'industrialtype': industrialType,
        'photo': photo
      };
}

class ResultCategoryEmployee extends ResultCategoryIdEntity {
  ResultCategoryEmployee.fromJSON(Map<String, dynamic> json)
      : super(
          id: json['id'],
          employeeprofileId: json['employeeprofileId'],
          categoryId: json['categoryId'],
        );
  Map<String, dynamic> toJson() => {
        'id': id,
        'employeeprofileId': employeeprofileId,
        'categoryId': categoryId
      };
}

class IndustrialType extends IndustrialTypeEntity {
  IndustrialType.fromJSON(Map<String, dynamic> json)
      : super(id: json['id'], industry: Industrial.fromJSON(json['industry']));
  Map<String, dynamic> toJson() => {'id': id, 'industry': industry};
}

class Industrial extends IndustrialEntity {
  Industrial.fromJSON(Map<String, dynamic> json)
      : super(id: json['id'], industry: json['industry']);
  Map<String, dynamic> toJson() => {'id': id, 'industry': industry};
}
