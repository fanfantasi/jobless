part of 'postdata_cubit.dart';

abstract class PostDataState extends Equatable {
  const PostDataState();
}

class PostDataInitial extends PostDataState {
  @override
  List<Object> get props => [];
}

class PostDataLoading extends PostDataState {
  @override
  List<Object> get props => [];
}

class PostDataLoaded extends PostDataState {
  final ResultEntity result;

  const PostDataLoaded(this.result);
  @override
  List<Object> get props => [result];
}

class PostDataFailure extends PostDataState {
  @override
  List<Object> get props => [];
}
