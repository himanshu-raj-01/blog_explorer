import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/blog.dart';

// Blog Event
abstract class BlogEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchBlogsEvent extends BlogEvent {}

// Blog State
abstract class BlogState extends Equatable {
  @override
  List<Object> get props => [];
}

class BlogLoadingState extends BlogState {}

class BlogLoadedState extends BlogState {
  final List<Blog> blogs;

  BlogLoadedState(this.blogs);

  @override
  List<Object> get props => [blogs];
}

class BlogErrorState extends BlogState {
  final String message;

  BlogErrorState(this.message);

  @override
  List<Object> get props => [message];
}

// Blog Bloc
class BlogBloc extends Bloc<BlogEvent, BlogState> {
  BlogBloc() : super(BlogLoadingState()) {
    on<FetchBlogsEvent>(_onFetchBlogs);
  }

  void _onFetchBlogs(FetchBlogsEvent event, Emitter<BlogState> emit) async {
    emit(BlogLoadingState());
    try {
      final blogs = await _fetchBlogs();
      emit(BlogLoadedState(blogs));
    } catch (e) {
      emit(BlogErrorState('Failed to fetch blogs: $e'));
    }
  }

  Future<List<Blog>> _fetchBlogs() async {
    const String url = 'https://intent-kit-16.hasura.app/api/rest/blogs';
    const String adminSecret =
        '32qR4KmXOIpsGPQKMqEJHGJS27G5s7HdSKO3gdtQd2kv5e852SiYwWNfxkZOBuQ6';

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'x-hasura-admin-secret': adminSecret,
      });

      // Log the response
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> data =
            jsonData['blogs'] ?? []; // Handle null values

        return data.map((json) => Blog.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load blogs: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching blogs: $e');
      rethrow; // rethrow the exception to be handled in the Bloc
    }
  }
}
