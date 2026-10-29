enum BookStatus { available, borrowed, missing }

class Book {
  final String id;
  final String title;
  final String author;
  final int replacementPrice;
  final BookStatus status;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.replacementPrice,
    this.status = BookStatus.available,
  });

  Book copyWith({
    String? id,
    String? title,
    String? author,
    int? replacementPrice,
    BookStatus? status,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      replacementPrice: replacementPrice ?? this.replacementPrice,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'author': author,
    'replacementPrice': replacementPrice,
    'status': status.name,
  };

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json['id'] as String,
    title: json['title'] as String,
    author: json['author'] as String,
    replacementPrice: json['replacementPrice'] as int,
    status: json['status'] == null
        ? BookStatus.available
        : BookStatus.values.byName(json['status'] as String),
  );
}