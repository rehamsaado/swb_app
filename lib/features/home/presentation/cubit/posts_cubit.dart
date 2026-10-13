import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/usecases/get_posts_usecase.dart';

part 'posts_state.dart';

class PostsCubit extends Cubit<PostsState> {
  final GetPostsUseCase getPostsUseCase;


  final int _limit = 10;
  int _currentPage = 1;

  PostsCubit(this.getPostsUseCase) : super(PostsInitial());

  Future<void> fetchInitialPosts() async {
    emit(PostsLoading());
    _currentPage = 1;

    final result = await getPostsUseCase(page: _currentPage, limit: _limit);

    result.fold(
          (failure) => emit(PostsError(failure.message)),
          (posts) {
        emit(PostsLoaded(
          posts: posts,
          hasReachedMax: posts.length < _limit,
          isLoadingMore: false,
          currentPage: _currentPage,
        ));
      },
    );
  }

  Future<void> fetchMorePosts() async {
    if (state is PostsLoaded) {
      final currentState = state as PostsLoaded;


      if (currentState.hasReachedMax || currentState.isLoadingMore) return;


      emit(currentState.copyWith(isLoadingMore: true));

      _currentPage++;
      final result = await getPostsUseCase(page: _currentPage, limit: _limit);

      result.fold(
            (failure) {

          _currentPage--;
          emit(currentState.copyWith(isLoadingMore: false));
        },
            (morePosts) {
          emit(PostsLoaded(
            posts: currentState.posts + morePosts,
            hasReachedMax: morePosts.isEmpty || morePosts.length < _limit,
            isLoadingMore: false,
            currentPage: _currentPage,
          ));
        },
      );
    }
  }
}