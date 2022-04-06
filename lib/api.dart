import 'dart:convert';

import 'package:loadmore_riverpod/post_model.dart';
import 'package:dio/dio.dart';

Future<List<Post>> getPosts(int page) async {
  print('httpClient loading page $page');
  try {
    final response = await Dio().get(
        'https://jsonplaceholder.typicode.com/posts?_page=$page&_limit=10');
    final List<Post> posts =
        (response.data as List).map((e) => Post.fromJsonMap(e)).toList();
    return posts;
  } catch (ex, st) {
    print(ex);
    print(st);
    return [];
  }
}
