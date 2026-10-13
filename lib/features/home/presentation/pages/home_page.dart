import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/posts_cubit.dart';
import '../widgets/post_card_item.dart';
import '../widgets/posts_states_widgets.dart';
import '../widgets/app_tab_bar_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<PostsCubit>()..fetchInitialPosts(),
      child: const PostsView(),
    );
  }
}

class PostsView extends StatefulWidget {
  const PostsView({super.key});

  @override
  State<PostsView> createState() => _PostsViewState();
}

class _PostsViewState extends State<PostsView> {
  final ScrollController _scrollController = ScrollController();


  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<PostsCubit>().fetchMorePosts();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          context.tr('posts_title'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [Colors.black.withOpacity(0.6), Colors.transparent]
                  : [AppColors.primary.withOpacity(0.05), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [

            AppTabBarWidget(
              selectedIndex: _selectedTabIndex,
              isBottomIndicator: true,
              onTap: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });

              },
              items: const [
                AppTabBarItem(iconData: Icons.article_rounded, text: 'All'),
                AppTabBarItem(iconData: Icons.bookmark_rounded, text: 'Favorites'),
                AppTabBarItem(iconData: Icons.trending_up_rounded, text: 'Trending'),
              ],
            ),
            const SizedBox(height: 8),


            Expanded(
              child: BlocConsumer<PostsCubit, PostsState>(
                listener: (context, state) {
                  if (state is PostsError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is PostsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  if (state is PostsError) {
                    return PostsErrorView(
                      message: state.message,
                      onRetry: () => context.read<PostsCubit>().fetchInitialPosts(),
                    );
                  }

                  if (state is PostsLoaded) {
                    if (state.posts.isEmpty) {
                      return EmptyPostsView(isDarkMode: isDarkMode);
                    }

                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () => context.read<PostsCubit>().fetchInitialPosts(),
                      child: ListView.separated(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                        itemCount: state.hasReachedMax
                            ? state.posts.length
                            : state.posts.length + 1,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          if (index >= state.posts.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.0),
                              child: Center(
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              ),
                            );
                          }

                          final post = state.posts[index];
                          return PostCardItem(
                            post: post,
                            isDarkMode: isDarkMode,
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}