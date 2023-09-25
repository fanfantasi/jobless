import 'package:jobless/domain/entities/pagination_entity.dart';

class PaginationModel extends PaginationEntity {
  PaginationModel.fromJSON(Map<String, dynamic> json)
      : super(
          page: json['page'],
          limit: json['limit'],
          totalPage: json['totalPage'],
        );
}
