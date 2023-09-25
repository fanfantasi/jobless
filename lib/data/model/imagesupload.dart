class ImageUploadModel {
  String? id;
  bool? isUploaded;
  bool? uploading;
  String? imageFile;
  String? imageUrl;

  ImageUploadModel(
      {this.id,
      this.isUploaded,
      this.uploading,
      this.imageFile,
      this.imageUrl});
}
