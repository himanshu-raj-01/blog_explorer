import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/blog_bloc.dart';
import '../models/blog.dart';

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({super.key});

  @override
  _BlogListScreenState createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    setState(() {});
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _tabController.index != 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  _tabController.animateTo(0);
                },
              )
            : null,
        title: const Row(
          children: [
            Spacer(),
            Text(
              'Blog Explorer',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Spacer(),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: BlogSearchDelegate(
                  blogs: context.read<BlogBloc>().state is BlogLoadedState
                      ? (context.read<BlogBloc>().state as BlogLoadedState).blogs
                      : [],
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'ALL'),
            Tab(text: 'MERCHANTS'),
            Tab(text: 'BUSINESS'),
            Tab(text: 'TUTORIAL'),
          ],
          labelStyle: const TextStyle(fontSize: 16.0),
          isScrollable: true,
        ),
      ),
      body: BlocBuilder<BlogBloc, BlogState>(
        builder: (context, state) {
          if (state is BlogLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BlogLoadedState) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildBlogList(state.blogs),
                _buildBlogList(state.blogs.where((blog) => blog.title.toLowerCase().contains('merchant')).toList()),
                _buildBlogList(state.blogs.where((blog) => blog.title.toLowerCase().contains('business')).toList()),
                _buildBlogList(state.blogs.where((blog) => blog.title.toLowerCase().contains('tutorial')).toList()),
              ],
            );
          } else if (state is BlogErrorState) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }

  Widget _buildBlogList(List<Blog> blogs) {
    final filteredBlogs = blogs.where((blog) {
      return blog.title.toLowerCase().contains(_searchQuery) ||
             blog.description.toLowerCase().contains(_searchQuery);
    }).toList();

    return ListView.builder(
      itemCount: filteredBlogs.length,
      itemBuilder: (context, index) {
        final blog = filteredBlogs[index];
        return _buildBlogItem(context, blog);
      },
    );
  }

  Widget _buildBlogItem(BuildContext context, Blog blog) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlogDetailScreen(blog: blog),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                blog.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 8),
              Text(
                blog.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                blog.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BlogDetailScreen extends StatelessWidget {
  final Blog blog;

  const BlogDetailScreen({super.key, required this.blog});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(blog.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(blog.imageUrl),
            const SizedBox(height: 20),
            Text(
              blog.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              blog.description,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class BlogSearchDelegate extends SearchDelegate {
  final List<Blog> blogs;

  BlogSearchDelegate({required this.blogs});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Please enter a search term'));
    }

    final results = blogs.where((blog) {
      return blog.title.toLowerCase().contains(query.toLowerCase()) ||
             blog.description.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final blog = results[index];
        return ListTile(
          title: Text(blog.title),
          subtitle: Text(blog.description),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlogDetailScreen(blog: blog),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Please enter your search term!'));
    }

    final suggestions = blogs.where((blog) {
      return blog.title.toLowerCase().contains(query.toLowerCase()) ||
             blog.description.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final blog = suggestions[index];
        return ListTile(
          title: Text(blog.title),
          subtitle: Text(blog.description),
          onTap: () {
            query = blog.title;
            showResults(context);
          },
        );
      },
    );
  }
}
