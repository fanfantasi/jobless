import 'package:jobless/domain/entities/pagination_entity.dart';

class LocationEntity {
  final String? error;
  final List<ResultLocationEntity> data;
  final String message;
  final PaginationEntity? pagination;
  const LocationEntity(
      {this.error, required this.data, required this.message, this.pagination});
}

class ResultLocationEntity {
  final String? id;
  final String? location;
  final bool? checked;
  const ResultLocationEntity({this.id, this.location, this.checked});
}
