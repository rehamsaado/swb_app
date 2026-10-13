import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String username,
    required String password,
  });

  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
    required String firstName,
    required String lastName,
  });

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabaseClient;

  AuthRemoteDataSourceImpl({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: username,
        password: password,
      );

      if (response.user == null) {
        throw const UnauthorizedException();
      }

      return UserModel(
        id: response.user!.id,
        email: response.user!.email ?? '',
        username: response.user!.userMetadata?['username'] ?? username,
        token: response.session?.accessToken,
        firstName: response.user!.userMetadata?['first_name'] ?? '',
        lastName: response.user!.userMetadata?['last_name'] ?? '',
      );
    } on AuthException {
      throw const UnauthorizedException();
    } catch (_) {
      throw const ServerException();
    }
  }

  @override
  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'first_name': firstName,
          'last_name': lastName,
        },
      );

      if (response.user == null) {
        throw const ServerException();
      }

      return {
        'id': response.user!.id,
        'email': email,
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
      };
    } on AuthException {
      throw const ServerException();
    } catch (_) {
      throw const ServerException();
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (_) {
      throw const ServerException();
    }
  }
}