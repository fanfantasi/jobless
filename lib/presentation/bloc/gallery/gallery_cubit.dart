import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobless/domain/entities/gallery_entity.dart';
import 'package:jobless/domain/usecases/user/delete_galleryemployers_usecase.dart';
import 'package:jobless/domain/usecases/user/get_galleryemployers_usecase.dart';

part 'gallery_state.dart';

class GalleryCubit extends Cubit<GalleryState> {
  final GetGalleryEmployersUseCase getgalleryEmployersUseCase;
  final DeleteGalleryEmployersUseCase deleteGalleryEmployersUseCase;
  GalleryCubit(
      {required this.getgalleryEmployersUseCase,
      required this.deleteGalleryEmployersUseCase})
      : super(GalleryInitial());

  Future<void> getGallery(String id) async {
    emit(GalleryLoading());
    try {
      final galleryStream = await getgalleryEmployersUseCase.call(id);
      emit(GalleryLoaded(galleryStream));
    } on SocketException catch (_) {
      emit(GalleryFailure());
    } catch (_) {
      emit(GalleryFailure());
    }
  }

  Future<bool> deleteGallery({
    String? id,
  }) async {
    try {
      final streamDate = await deleteGalleryEmployersUseCase.call(id!);
      if (streamDate.error == null) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }
}
