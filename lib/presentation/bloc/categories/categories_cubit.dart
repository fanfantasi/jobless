import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobless/domain/entities/categories_entity.dart';
import 'package:jobless/domain/entities/result_entity.dart';
import 'package:jobless/domain/usecases/categories/delete_category_usecase.dart';
import 'package:jobless/domain/usecases/categories/get_categories_usecase.dart';
import 'package:jobless/domain/usecases/categories/post_category_usecase.dart';

part 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final CategoriesUseCase categoriesUseCase;
  final PostCategoriesUseCase postCategoriesUseCase;
  final DeleteCategoriesUseCase deleteCategoriesUseCase;
  CategoriesCubit(
      {required this.categoriesUseCase,
      required this.postCategoriesUseCase,
      required this.deleteCategoriesUseCase})
      : super(CategoriesInitial());

  Future<void> getcategories(int page, int limit, String params) async {
    emit(CategoriesLoading());
    try {
      final categoriesStreamData =
          await categoriesUseCase.call(page, limit, params);
      emit(CategoriesLoaded(categoriesStreamData));
    } on SocketException catch (_) {
      emit(CategoriesFailure());
    } catch (_) {
      emit(CategoriesFailure());
    }
  }

  Future<ResultEntity> postcategories({String? id, String? category}) async {
    ResultEntity? data;
    try {
      final streamData =
          await postCategoriesUseCase.call(id: id, category: category);

      return streamData;
    } on SocketException catch (_) {
      return data!;
    } catch (_) {
      return data!;
    }
  }

  Future<bool> deletecategories({String? id}) async {
    try {
      final streamData = await deleteCategoriesUseCase.call(id: id);
      if (streamData.error == null) {
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
