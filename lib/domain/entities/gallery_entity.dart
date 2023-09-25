class GalleryEntity {
  final String? error;
  final List<ResultGalleryEntity> data;
  final String message;
  const GalleryEntity({this.error, required this.data, required this.message});
}

class ResultGalleryEntity {
  final String? id;
  final String? image;
  const ResultGalleryEntity({this.id, this.image});
}
