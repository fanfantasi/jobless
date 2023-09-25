import 'package:jobless/domain/entities/schedule_entity.dart';

class ScheduleModel extends ScheduleEntity {
  ScheduleModel.fromJSON(Map<String, dynamic> json)
      : super(
          error: json['error'],
          message: json['message'],
          interview: List.from(json['interview']),
          dates: List.from(json['dates']),
        );
}
