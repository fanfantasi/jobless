import 'package:jobless/domain/entities/result_entity.dart';

class ResultModel extends ResultEntity {
  ResultModel.fromJSON(Map<String, dynamic> json)
      : super(
            error: json['error'],
            message: json['message'],
            data: json['data'] ?? '');
}
