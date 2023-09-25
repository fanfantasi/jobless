class UserEntity {
  final String? error;
  final ResultUserEntity data;
  final String message;
  const UserEntity({this.error, required this.data, required this.message});
}

class ResultUserEntity {
  final String? id;
  final String? email;
  final String? statusprofile;
  final bool? administrator;
  final EmployeeProfileEntity? employeeProfile;
  final EmployersProfileEntity? employersProfile;
  const ResultUserEntity(
      {this.id,
      this.email,
      this.statusprofile,
      this.administrator,
      this.employeeProfile,
      this.employersProfile});
}

class EmployeeProfileEntity {
  final String? id;
  final String? fullname;
  final String? dateofbirth;
  final String? address;
  final String? gender;
  final String? skill;
  final String? photo;
  final List<ResultCategoryIdEntity>? jobcategories;
  const EmployeeProfileEntity(
      {this.id,
      this.fullname,
      this.dateofbirth,
      this.gender,
      this.address,
      this.skill,
      this.photo,
      this.jobcategories});
}

class EmployersProfileEntity {
  final String? id;
  final String? companyname;
  final String? officelocation;
  final String? email;
  final String? address;
  final String? companysize;
  final String? website;
  final String? desc;
  final String? industrytypeid;
  final IndustrialTypeEntity? industrialType;
  final String? photo;
  const EmployersProfileEntity(
      {this.id,
      this.companyname,
      this.officelocation,
      this.email,
      this.address,
      this.companysize,
      this.website,
      this.desc,
      this.industrytypeid,
      this.industrialType,
      this.photo});
}

class ResultCategoryIdEntity {
  final String? id;
  final String? employeeprofileId;
  final String? categoryId;
  const ResultCategoryIdEntity(
      {this.id, this.employeeprofileId, this.categoryId});
}

class IndustrialTypeEntity {
  final String? id;
  final IndustrialEntity? industry;
  const IndustrialTypeEntity({this.id, this.industry});
}

class IndustrialEntity {
  final String? id;
  final String? industry;
  const IndustrialEntity({this.id, this.industry});
}
