part of 'gallery_cubit.dart';

abstract class GalleryState extends Equatable {
  const GalleryState();
}

class GalleryInitial extends GalleryState {
  @override
  List<Object> get props => [];
}

class GalleryLoading extends GalleryState {
  @override
  List<Object> get props => [];
}

class GalleryLoaded extends GalleryState {
  final GalleryEntity gallery;

  const GalleryLoaded(this.gallery);
  @override
  List<Object> get props => [gallery];
}

class GalleryFailure extends GalleryState {
  @override
  List<Object> get props => [];
}
