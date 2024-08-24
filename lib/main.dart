import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'bloc/blog_bloc.dart';
import 'screens/blog_list_screen.dart';

void main() async {
  await Hive.initFlutter();
  runApp(const BlogExplorerApp());
}

class BlogExplorerApp extends StatelessWidget {
  const BlogExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blog Explorer',
      home: BlocProvider(
        create: (context) => BlogBloc()..add(FetchBlogsEvent()),
        child: const BlogListScreen(),
      ),
    );
  }
}
