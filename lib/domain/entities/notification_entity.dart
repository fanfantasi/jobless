class NotificationEntity {
  final String? error;
  final List<ResultNotificationEntity> data;
  final String message;
  const NotificationEntity(
      {this.error, required this.data, required this.message});
}

class ResultNotificationEntity {
  final String? id;
  final String? title;
  final String? body;
  final String? link;
  final bool? read;
  final ResultSenderEntity? sender;
  final ResultReceiverEntity? receiver;
  final String? status;
  final String? createdAt;
  const ResultNotificationEntity(
      {this.id,
      this.title,
      this.body,
      this.link,
      this.read,
      this.sender,
      this.receiver,
      this.status,
      this.createdAt});
}

class ResultSenderEntity {
  final String? status;
  final EmployeeProfileEntity? employee;
  final EmployersProfileEntity? employers;
  const ResultSenderEntity({this.status, this.employee, this.employers});
}

class ResultReceiverEntity {
  final String? status;
  final EmployeeProfileEntity? employee;
  final EmployersProfileEntity? employers;
  const ResultReceiverEntity({this.status, this.employee, this.employers});
}

class EmployeeProfileEntity {
  final String? id;
  final String? fullname;
  final String? dateofbirth;
  final String? address;
  final String? gender;
  final String? skill;
  final String? photo;
  const EmployeeProfileEntity(
      {this.id,
      this.fullname,
      this.dateofbirth,
      this.gender,
      this.address,
      this.skill,
      this.photo});
}

class EmployersProfileEntity {
  final String? id;
  final String? companyname;
  final String? officelocation;
  final String? email;
  final String? address;
  final String? photo;
  const EmployersProfileEntity(
      {this.id,
      this.companyname,
      this.officelocation,
      this.email,
      this.address,
      this.photo});
}
