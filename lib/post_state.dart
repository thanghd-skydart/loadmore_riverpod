import 'package:equatable/equatable.dart';

import 'post_model.dart';

class PostState extends Equatable {
  final int page;
  List<Post> posts;
  final bool? isLoading;
  final bool? isLoadMoreError;
  final bool? isLoadMoreDone;
  PostState(
      {required this.page,
      required this.posts,
      this.isLoading,
      this.isLoadMoreDone,
      this.isLoadMoreError});

  factory PostState.initial() {
    return PostState(
        page: 1,
        posts: [],
        isLoading: true,
        isLoadMoreDone: false,
        isLoadMoreError: false);
  }
  @override
  List<Object> get props => [
        page,
        posts,
      ];

  PostState copyWith(
      {int? page,
      List<Post>? posts,
      bool? isLoading,
      bool? isLoadMoreError,
      bool? isLoadMoreDone}) {
    return PostState(
      page: page ?? this.page,
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadMoreError: isLoadMoreError ?? this.isLoadMoreError,
      isLoadMoreDone: isLoadMoreDone ?? this.isLoadMoreDone,
    );
  }
}
