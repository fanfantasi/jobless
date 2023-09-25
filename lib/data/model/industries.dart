import 'package:jobless/data/model/pagination.dart';
import 'package:jobless/domain/entities/industries_entity.dart';

class IndustriesModel extends IndustriesEntity {
  IndustriesModel.fromJSON(Map<String, dynamic> json)
      : super(
            error: json['error'],
            message: json['message'],
            data: List.from(json['data'])
                .map((e) => ResultIndustriesModel.fromJSON(e))
                .toList(),
            pagination: PaginationModel.fromJSON(json['pagination']));
}

class ResultIndustriesModel extends ResultIndustriesEntity {
  ResultIndustriesModel.fromJSON(Map<String, dynamic> json)
      : super(
            id: json['id'],
            industry: json['industry'],
            checked: json['checked'] ?? false);
  Map<String, dynamic> toJson() =>
      {'id': id, 'industry': industry, 'checked': checked};
}
