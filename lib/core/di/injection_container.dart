// =================== Core / Network ===================

import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/user_session.dart';
import '../local/app_preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// =================== Splash ===================
import '../../features/splash/data/datasources/splash_local_data_source.dart';
import '../../features/splash/data/repositories/splash_repository_impl.dart';
import '../../features/splash/domain/repositories/splash_repository.dart';
import '../../features/splash/domain/usecases/check_app_start_status_usecase.dart';
import '../../features/splash/presentation/splash/splash_cubit.dart';

// =================== Auth ===================
import '../../features/auth/data/data_source/auth_local_data_source.dart';
import '../../features/auth/data/data_source/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/blocs/auth_bloc.dart';
import '../../features/auth/domain/usecases/get_saved_user_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';

//==========================posts=====================
import '../../features/home/data/datasources/posts_remote_data_source.dart';
import '../../features/home/data/repositories/posts_repository_impl.dart';
import '../../features/home/domain/repositories/posts_repository.dart';
import '../../features/home/domain/usecases/get_posts_usecase.dart';
import '../../features/home/presentation/cubit/posts_cubit.dart';
import '../network/api_interceptors.dart';
import '../network/api_service.dart';
import '../network/network_info.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // =========================================================================
  //                      1. Core & External
  // =========================================================================
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<UserSession>(() => UserSession(sl()));
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  sl.registerLazySingleton<ApiInterceptor>(
        () => ApiInterceptor(sl()),
  );
  sl.registerLazySingleton<InternetConnectionChecker>(
        () => InternetConnectionChecker(),
  );

  sl.registerLazySingleton<NetworkInfo>(
        () => NetworkInfoImpl(sl()),
  );

  sl.registerLazySingleton<ApiService>(
        () => ApiService(sl()),
  );

  sl.registerLazySingleton<AppPreferences>(
    () => AppPreferences(sl<SharedPreferences>()),
  );

  // =========================================================================
  //                    2. Splash Feature
  // =========================================================================
  sl.registerFactory<SplashCubit>(
    () => SplashCubit(
      checkAppStartStatusUseCase: sl<CheckAppStartStatusUseCase>(),
    ),
  );

  sl.registerLazySingleton<CheckAppStartStatusUseCase>(
    () => CheckAppStartStatusUseCase(sl<SplashRepository>()),
  );

  sl.registerLazySingleton<SplashRepository>(
    () => SplashRepositoryImpl(localDataSource: sl<SplashLocalDataSource>()),
  );

  sl.registerLazySingleton<SplashLocalDataSource>(
    () => SplashLocalDataSourceImpl(appPreferences: sl<AppPreferences>()),
  );

  // =========================================================================
  //                        3. Auth Feature
  // =========================================================================
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: sl<AuthRepository>(), userSession: sl()),
  );

  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<GetSavedUserUseCase>(
    () => GetSavedUserUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      localDataSource: sl<AuthLocalDataSource>(),
      remoteDataSource: sl<AuthRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(appPreferences: sl<AppPreferences>()),
  );
  //==================posts========================
  // ------------------ Cubits ------------------

  sl.registerFactory<PostsCubit>(() => PostsCubit(sl()));

  // ------------------ Use Cases ------------------
  sl.registerLazySingleton<GetPostsUseCase>(() => GetPostsUseCase(sl()));

  // ------------------ Repositories ------------------
  sl.registerLazySingleton<PostsRepository>(
    () => PostsRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // ------------------ Data Sources ------------------
  sl.registerLazySingleton<PostsRemoteDataSource>(
    () => PostsRemoteDataSourceImpl(sl()),
  );
}
