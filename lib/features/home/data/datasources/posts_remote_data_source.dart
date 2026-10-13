import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_service.dart';
import '../models/post_model.dart';

abstract class PostsRemoteDataSource {
  Future<List<PostModel>> getPosts({required int page, required int limit});
}

class PostsRemoteDataSourceImpl implements PostsRemoteDataSource {
  final ApiService apiService;

  PostsRemoteDataSourceImpl(this.apiService);

  @override
  Future<List<PostModel>> getPosts({required int page, required int limit}) async {
    final response = await apiService.get(
      path: ApiConstants.posts,
      queryParameters: {
        '_page': page,
        '_limit': limit,
      },
    );

    final List data = response as List;
    return data.map((json) => PostModel.fromJson(json)).toList();
  }
}