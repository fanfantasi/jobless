import 'package:jobless/data/model/pagination.dart';
import 'package:jobless/domain/entities/location_entity.dart';

class LocationModel extends LocationEntity {
  LocationModel.fromJSON(Map<String, dynamic> json)
      : super(
            error: json['error'],
            message: json['message'],
            data: List.from(json['data'])
                .map((e) => ResultLocationModel.fromJSON(e))
                .toList(),
            pagination: PaginationModel.fromJSON(json['pagination']));
}

class ResultLocationModel extends ResultLocationEntity {
  ResultLocationModel.fromJSON(Map<String, dynamic> json)
      : super(
            id: json['id'],
            location: json['location'],
            checked: json['checked'] ?? false);
  Map<String, dynamic> toJson() =>
      {'id': id, 'location': location, 'checked': checked};
}
