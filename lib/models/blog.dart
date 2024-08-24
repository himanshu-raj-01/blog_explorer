class Blog {
  final String id;
  final String imageUrl;
  final String title;
  final String description;

  Blog({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      id: json['id'] ?? '',
      imageUrl: json['image_url'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
