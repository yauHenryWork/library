import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // static const String baseUrl = 'http://10.0.2.2:3000/books';
  static const String baseUrl = 'http://172.30.126.30:3000/books';
  // Fetch all books
static Future<List<dynamic>> fetchBooks() async {
  print('Fetching books from API: $baseUrl');
  final response = await http.get(Uri.parse(baseUrl));
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    print('Error fetching books: ${response.statusCode}');
    throw Exception('Failed to load books');
  }
}


  // Search books
static Future<List<dynamic>> searchBooks(String criteria, String keyword) async {
  // Encode the keyword to handle spaces and special characters
  final encodedKeyword = Uri.encodeComponent(keyword);

  final url = '$baseUrl/search?criteria=$criteria&keyword=$encodedKeyword';
  print(url);
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to search books');
    }
  } catch (e) {
    rethrow; // Re-throw the exception to propagate it further if needed
  }
}


  // Get book details
  static Future<Map<String, dynamic>> getBookDetails(String bookId) async {
    final response = await http.get(Uri.parse('$baseUrl/$bookId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Book not found');
    }
  }

  // Add a book
  static Future<void> addBook(Map<String, dynamic> book) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(book),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add book');
    }
  }

  // Update a book
  static Future<void> updateBook(String bookId, Map<String, dynamic> book) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$bookId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(book),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update book');
    }
  }

  // Delete a book
  static Future<void> deleteBook(String bookId) async {
    final response = await http.delete(Uri.parse('$baseUrl/$bookId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete book');
    }
  }
}