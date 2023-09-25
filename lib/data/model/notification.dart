import 'package:jobless/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  NotificationModel.fromJSON(Map<String, dynamic> json)
      : super(
          error: json['error'],
          message: json['message'],
          data: List.from(json['data'])
              .map((e) => ResultNotificationModel.fromJSON(e))
              .toList(),
        );
}

class ResultNotificationModel extends ResultNotificationEntity {
  ResultNotificationModel.fromJSON(Map<String, dynamic> json)
      : super(
            id: json['id'],
            title: json['title'],
            body: json['body'],
            link: json['link'],
            read: json['read'],
            sender: json['sender'] != null
                ? ResultSenderModel.fromJSON(json['sender'])
                : null,
            receiver: json['receiver'] != null
                ? ResultReceiverModel.fromJSON(json['receiver'])
                : null,
            status: json['stats'],
            createdAt: json['createdAt']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'link': link,
        'read': read,
        'sender': sender,
        'receiver': receiver,
        'status': status,
        'createdAt': createdAt
      };
}

class ResultSenderModel extends ResultSenderEntity {
  ResultSenderModel.fromJSON(Map<String, dynamic> json)
      : super(
          status: json['statusprofile'],
          employee: json['employeeprofile'] != null
              ? ResultEmployeeProfileModel.fromJSON(json['employeeprofile'])
              : null,
          employers: json['employersprofile'] != null
              ? ResultEmployersProfileModel.fromJSON(json['employersprofile'])
              : null,
        );

  Map<String, dynamic> toJson() =>
      {'status': status, 'employee': employee, 'employers': employers};
}

class ResultReceiverModel extends ResultReceiverEntity {
  ResultReceiverModel.fromJSON(Map<String, dynamic> json)
      : super(
          status: json['statusprofile'],
          employee: json['employeeprofile'] != null
              ? ResultEmployeeProfileModel.fromJSON(json['employeeprofile'])
              : null,
          employers: json['employersprofile'] != null
              ? ResultEmployersProfileModel.fromJSON(json['employersprofile'])
              : null,
        );

  Map<String, dynamic> toJson() =>
      {'status': status, 'employee': employee, 'employers': employers};
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
        );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullname': fullname,
        'dateofbirth': dateofbirth,
        'address': address,
        'gender': gender,
        'skill': skill,
        'photo': photo,
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
          photo: json['photo'],
        );
  Map<String, dynamic> toJson() => {
        'id': id,
        'companyname': companyname,
        'officelocation': officelocation,
        'email': email,
        'address': address,
        'photo': photo
      };
}
