import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loadmore_riverpod/post_model.dart';
import 'package:loadmore_riverpod/post_vm.dart';

final keyProvider = StateProvider<String>((ref) {
  return '';
});

final postSearchProvider = StateProvider.autoDispose<List<Post>>((ref) {
  final postState = ref.watch(postVM);
  final key = ref.watch(keyProvider);

  return postState.posts
      .where((element) =>
          element.body.contains(key) || element.title.contains(key))
      .toList();
});

class HomePage extends HookConsumerWidget {
  final ScrollController _controller = ScrollController();
  int oldLength = 0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      _controller.addListener(() async {
        if (_controller.position.pixels >
            _controller.position.maxScrollExtent -
                MediaQuery.of(context).size.height) {
          if (oldLength == ref.read(postVM).posts.length) {
            ref.read(postVM.notifier).loadMorePost();
          }
        }
      });
      return () => {_controller};
    }, ["controller"]);
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          decoration: const InputDecoration(
              hintText: 'Enter to search!',
              hintStyle: TextStyle(color: Colors.yellow)),
          onChanged: (newValue) {
            ref.read(keyProvider.notifier).state = newValue;
          },
        ),
      ),
      body: Consumer(
        builder: (ctx, watch, child) {
          final isLoadMoreError = ref.watch(postVM).isLoadMoreError;
          final isLoadMoreDone = ref.watch(postVM).isLoadMoreDone;
          final isLoading = ref.watch(postVM).isLoading;
          final posts = ref.watch(postSearchProvider.notifier).state;

          // sync oldLength with post.length to make sure ListView has newest
          // data, so loadMore will work correctly
          oldLength = posts.length;
          // init data or error
          if (posts.isEmpty) {
            // error case
            if (isLoading == false) {
              return const Center(
                child: Text('error'),
              );
            }
            return const _Loading();
          }
          return RefreshIndicator(
            onRefresh: () {
              return ref.read(postVM.notifier).refresh();
            },
            child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 20),
                controller: _controller,
                itemCount: posts.length + 1,
                itemBuilder: (ctx, index) {
                  // last element (progress bar, error or 'Done!' if reached to the last element)
                  if (index == posts.length) {
                    // load more and get error
                    if (isLoadMoreError!) {
                      return const Center(
                        child: Text('Error'),
                      );
                    }
                    // load more but reached to the last element
                    if (isLoadMoreDone!) {
                      return const Center(
                        child: Text(
                          'Done!',
                          style: TextStyle(color: Colors.green, fontSize: 20),
                        ),
                      );
                    }
                    return const LinearProgressIndicator();
                  }
                  return ListTile(
                    title: Text(posts[index].title),
                    subtitle: Text(posts[index].body),
                    trailing: Text(posts[index].id.toString()),
                  );
                }),
          );
        },
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
