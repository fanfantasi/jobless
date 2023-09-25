import 'package:jobless/domain/entities/pagination_entity.dart';

class TipsEntity {
  final String? error;
  final List<ResultTipsEntity> data;
  final String message;
  final PaginationEntity? pagination;
  const TipsEntity(
      {this.error, required this.data, required this.message, this.pagination});
}

class ResultTipsEntity {
  final String? id;
  final String? title;
  final String? desc;
  final int? read;
  final String? image;
  final String? createdAt;
  final String? author;
  const ResultTipsEntity(
      {this.id,
      this.title,
      this.desc,
      this.read,
      this.image,
      this.createdAt,
      this.author});
}
