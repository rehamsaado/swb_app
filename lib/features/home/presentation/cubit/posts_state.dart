part of 'posts_cubit.dart';

abstract class PostsState {}

class PostsInitial extends PostsState {}

class PostsLoading extends PostsState {}

class PostsLoaded extends PostsState {
  final List<PostEntity> posts;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final int currentPage;

  PostsLoaded({
    required this.posts,
    required this.hasReachedMax,
    required this.isLoadingMore,
    required this.currentPage,
  });

  PostsLoaded copyWith({
    List<PostEntity>? posts,
    bool? hasReachedMax,
    bool? isLoadingMore,
    int? currentPage,
  }) {
    return PostsLoaded(
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class PostsError extends PostsState {
  final String message;
  PostsError(this.message);
}