import 'package:jobless/domain/entities/pagination_entity.dart';

class IndustriesEntity {
  final String? error;
  final List<ResultIndustriesEntity> data;
  final String message;
  final PaginationEntity? pagination;
  const IndustriesEntity(
      {this.error, required this.data, required this.message, this.pagination});
}

class ResultIndustriesEntity {
  final String? id;
  final String? industry;
  final bool? checked;
  const ResultIndustriesEntity({this.id, this.industry, this.checked});
}
