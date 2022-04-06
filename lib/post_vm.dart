import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loadmore_riverpod/post_state.dart';

import 'api.dart';

final postVM = StateNotifierProvider.autoDispose<PostVM, PostState>(
  (ref) => PostVM(),
);

class PostVM extends StateNotifier<PostState> {
  PostVM() : super(PostState.initial()) {
    _initPosts();
  }
  _initPosts([int? initPage]) async {
    final page = initPage ?? state.page;
    final posts = await getPosts(page);

    if (posts.isEmpty) {
      state = state.copyWith(page: page, isLoading: false);
      return;
    }
    print('get post is ${posts.length}');
    state = state.copyWith(page: page, isLoading: false, posts: posts);
  }

  loadMorePost() async {
    StringBuffer bf = StringBuffer();

    bf.write('try to request loading ${state.isLoading} at ${state.page + 1}');
    if (state.isLoading!) {
      bf.write(' fail');
      return;
    }
    bf.write(' success');
    state = state.copyWith(
        isLoading: true, isLoadMoreDone: false, isLoadMoreError: false);

    final posts = await getPosts(state.page + 1);

    if (posts.isEmpty) {
      // error
      state = state.copyWith(isLoadMoreError: true, isLoading: false);
      return;
    }

    print('load more ${posts.length} posts at page ${state.page + 1}');
    if (posts.isNotEmpty) {
      state = state.copyWith(
        page: state.page + 1,
        isLoading: false,
        isLoadMoreDone: posts.isEmpty,
        posts: [...state.posts, ...posts],
      );
    } else {
      // not increment page
      state = state.copyWith(
        isLoading: false,
        isLoadMoreDone: posts.isEmpty,
      );
    }
  }

  Future<void> refresh() async {
    _initPosts(1);
  }

  void reset() {
    state = PostState.initial();
  }
}
