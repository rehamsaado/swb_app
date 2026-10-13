import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swb_app/features/home/presentation/pages/home_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/cubit/posts_cubit.dart';
import '../../features/splash/presentation/pages/onboarding_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/splash/presentation/splash/splash_cubit.dart';
import '../constants/user_session.dart';
import '../di/injection_container.dart';

abstract class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';

  static const home = '/home';
}

abstract class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final userSession = sl<UserSession>();
      const publicRoutes = [AppRoutes.splash, AppRoutes.onboarding, AppRoutes.login, AppRoutes.register];

      final isAuthRoute = publicRoutes.contains(state.matchedLocation);
      final currentUserId = userSession.getUserId();

      if (currentUserId == null && !isAuthRoute) {
        return AppRoutes.login;
      }

      if (currentUserId != null && isAuthRoute) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => _fadeSlidePage(
          BlocProvider(
            create: (context) => sl<SplashCubit>(),
            child: const SplashPage(),
          ),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) =>
            _fadeSlidePage(const OnboardingPage(), key: state.pageKey),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) =>
            _fadeSlidePage(const LoginPage(), key: state.pageKey),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (context, state) =>
            _fadeSlidePage(const RegisterPage(), key: state.pageKey),
      ),
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => _fadeSlidePage(
          BlocProvider(
            create: (context) => sl<PostsCubit>(),
            child: const HomePage(),
          ),
          key: state.pageKey,
        ),
      ),


    ],
  );

  static CustomTransitionPage<void> _fadeSlidePage(
      Widget child, {
        LocalKey? key,
      }) {
    return CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 260),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}