import 'package:jobless/data/model/pagination.dart';
import 'package:jobless/domain/entities/categories_entity.dart';

class CategoriesModel extends CategoriesEntity {
  CategoriesModel.fromJSON(Map<String, dynamic> json)
      : super(
            error: json['error'],
            message: json['message'],
            data: List.from(json['data'])
                .map((e) => ResultCategoriesModel.fromJSON(e))
                .toList(),
            pagination: PaginationModel.fromJSON(json['pagination']));
}

class ResultCategoriesModel extends ResultCategoriesEntity {
  ResultCategoriesModel.fromJSON(Map<String, dynamic> json)
      : super(
            id: json['id'],
            category: json['category'],
            checked: json['checked'] ?? false);
  Map<String, dynamic> toJson() =>
      {'id': id, 'category': category, 'checked': checked};
}
