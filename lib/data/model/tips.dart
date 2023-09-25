import 'package:jobless/data/model/pagination.dart';
import 'package:jobless/domain/entities/tips_entity.dart';

class TipsModel extends TipsEntity {
  TipsModel.fromJSON(Map<String, dynamic> json)
      : super(
            error: json['error'],
            message: json['message'],
            data: List.from(json['data'])
                .map((e) => ResultTipsModel.fromJSON(e))
                .toList(),
            pagination: PaginationModel.fromJSON(json['pagination']));
}

class ResultTipsModel extends ResultTipsEntity {
  ResultTipsModel.fromJSON(Map<String, dynamic> json)
      : super(
            id: json['id'],
            title: json['title'],
            desc: json['desc'],
            read: json['read'],
            image: json['image'],
            createdAt: json['createdAt'],
            author: json['author']['employeeprofile']['fullname']);
}
