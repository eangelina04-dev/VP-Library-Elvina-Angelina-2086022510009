import '../models/book.dart';

class BookTitleGroup {
  final String title;
  final String author;
  final List<Book> copies;

  const BookTitleGroup({
    required this.title,
    required this.author,
    required this.copies,
  });
}