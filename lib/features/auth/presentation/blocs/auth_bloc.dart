import 'package:bloc/bloc.dart';
import '../../../../core/constants/user_session.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final UserSession userSession;

  AuthBloc({required this.authRepository, required this.userSession})
      : super(AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<CheckAuthStatusRequested>(_onCheckAuthStatusRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginSubmitted(
      LoginSubmitted event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    final result = await authRepository.login(
      username: event.username.trim(),
      password: event.password,
    );

    await result.fold(
          (failure) async => emit(AuthFailure(_mapFailureToMessage(failure))),
          (userEntity) async {
        await userSession.saveUserId(userEntity.id);
        emit(AuthSuccess(userEntity));
      },
    );
  }

  Future<void> _onRegisterSubmitted(
      RegisterSubmitted event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    final result = await authRepository.register(
      email: event.email.trim(),
      username: event.username.trim(),
      password: event.password,
      firstName: event.firstName.trim(),
      lastName: event.lastName.trim(),
    );

    await result.fold(
          (failure) async => emit(AuthFailure(_mapFailureToMessage(failure))),
          (userEntity) async {
        await userSession.saveUserId(userEntity.id);
        emit(AuthSuccess(userEntity));
      },
    );
  }

  Future<void> _onCheckAuthStatusRequested(
      CheckAuthStatusRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    final result = await authRepository.getSavedUser();

    result.fold(
          (_) => emit(Unauthenticated()),
          (userEntity) {
        if (userEntity != null) {
          emit(AuthSuccess(userEntity));
        } else {
          emit(Unauthenticated());
        }
      },
    );
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    final result = await authRepository.logout();

    await result.fold(
          (failure) async => emit(AuthFailure(_mapFailureToMessage(failure))),
          (_) async {
        await userSession.clearSession();
        emit(Unauthenticated());
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is NetworkFailure) return failure.message;
    if (failure is UnauthorizedFailure) return failure.message;
    if (failure is ServerFailure) return failure.message;
    if (failure is CacheFailure) return failure.message;
    if (failure is ValidationFailure) return failure.message;
    return failure.message.isNotEmpty ? failure.message : 'حدث خطأ غير متوقع';
  }
}