import 'package:jobless/data/model/pagination.dart';
import 'package:jobless/domain/entities/typevacancy_entity.dart';

class TypeVacancyModel extends TypeVacancyEntity {
  TypeVacancyModel.fromJSON(Map<String, dynamic> json)
      : super(
            error: json['error'],
            message: json['message'],
            data: List.from(json['data'])
                .map((e) => ResultTypeVacancyModel.fromJSON(e))
                .toList(),
            pagination: PaginationModel.fromJSON(json['pagination']));
}

class ResultTypeVacancyModel extends ResultTypeVacancyEntity {
  ResultTypeVacancyModel.fromJSON(Map<String, dynamic> json)
      : super(
            id: json['id'],
            type: json['type'],
            checked: json['checked'] ?? false);
  Map<String, dynamic> toJson() => {'id': id, 'type': type, 'checked': checked};
}
