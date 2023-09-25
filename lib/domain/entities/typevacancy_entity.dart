import 'package:jobless/domain/entities/pagination_entity.dart';

class TypeVacancyEntity {
  final String? error;
  final List<ResultTypeVacancyEntity> data;
  final String message;
  final PaginationEntity? pagination;
  const TypeVacancyEntity(
      {this.error, required this.data, required this.message, this.pagination});
}

class ResultTypeVacancyEntity {
  final String? id;
  final String? type;
  final bool? checked;
  const ResultTypeVacancyEntity({this.id, this.type, this.checked});
}
