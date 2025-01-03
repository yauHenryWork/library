import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BookDetailPage extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookDetailPage({super.key, required this.book});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late TextEditingController titleController;
  late TextEditingController authorController;
  late TextEditingController quantityController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.book['title']);
    authorController = TextEditingController(text: widget.book['author']);
    quantityController = TextEditingController(text: widget.book['quantity'].toString());
  }

  Future<void> updateBook() async {
    final updatedBook = {
      "title": titleController.text,
      "author": authorController.text,
      "quantity": int.parse(quantityController.text),
    };

    try {
      await ApiService.updateBook(widget.book['_id'], updatedBook);
      Navigator.pop(context, true); // Pass true to indicate success
    } catch (e) {
      print('Error updating book: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: authorController,
              decoration: const InputDecoration(labelText: 'Author'),
            ),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateBook,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
