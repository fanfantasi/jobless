import 'package:jobless/domain/entities/gallery_entity.dart';

class GalleryModel extends GalleryEntity {
  GalleryModel.fromJSON(Map<String, dynamic> json)
      : super(
          error: json['error'],
          message: json['message'],
          data: List.from(json['data'])
              .map((e) => ResultGalleryModel.fromJSON(e))
              .toList(),
        );
}

class ResultGalleryModel extends ResultGalleryEntity {
  ResultGalleryModel.fromJSON(Map<String, dynamic> json)
      : super(
          id: json['id'],
          image: json['image'],
        );
  Map<String, dynamic> toJson() => {'id': id, 'image': image};
}
