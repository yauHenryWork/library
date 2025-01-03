import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BookProvider with ChangeNotifier {
  List<dynamic> _books = [];
  bool _isLoading = false;

  List<dynamic> get books => _books;
  bool get isLoading => _isLoading;

  // Fetch all books
  Future<void> fetchBooks() async {
    _isLoading = true;
    // Schedule the state update after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      _books = await ApiService.fetchBooks();
    } catch (e) {
      print(e);
    }

    _isLoading = false;
    // Make sure the listeners are notified after the current build cycle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Search books
  Future<void> searchBooks(String criteria, String keyword) async {
    _isLoading = true;
    notifyListeners();
      print(criteria);
    try {
      _books = await ApiService.searchBooks(criteria, keyword);
    } catch (e) {
      print(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add a book
  Future<void> addBook(Map<String, dynamic> book) async {
    try {
      await ApiService.addBook(book);
      await fetchBooks(); // Refresh list after adding
    } catch (e) {
      print(e);
    }
  }

  // Delete a book
  Future<void> deleteBook(String bookId) async {
    try {
      await ApiService.deleteBook(bookId);
      await fetchBooks(); // Refresh list after deleting
    } catch (e) {
      print(e);
    }
  }
}
