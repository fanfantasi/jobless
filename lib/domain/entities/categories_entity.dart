import 'package:jobless/domain/entities/pagination_entity.dart';

class CategoriesEntity {
  final String? error;
  final List<ResultCategoriesEntity> data;
  final String message;
  final PaginationEntity? pagination;
  const CategoriesEntity(
      {this.error, required this.data, required this.message, this.pagination});
}

class ResultCategoriesEntity {
  final String? id;
  final String? category;
  final int? countVacancy;
  final bool? checked;
  const ResultCategoriesEntity(
      {this.id, this.category, this.countVacancy, this.checked});
}
