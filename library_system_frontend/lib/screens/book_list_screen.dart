import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import 'book_detail_screen.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchCriteria = 'title'; // Default search by title

  @override
  void initState() {
    super.initState();
    Provider.of<BookProvider>(context, listen: false).fetchBooks();
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library App'),
        actions: [
          // Dropdown for selecting search criteria
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              child: DropdownButton<String>(
                value: _searchCriteria,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                onChanged: (String? newValue) {
                  setState(() {
                    _searchCriteria = newValue!;
                  });
                },
                items: <String>['title', 'author']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: Colors.black)),
                  );
                }).toList(),
                underline: SizedBox(), // Hide the default underline
              ),
            ),
          ),

          // Search button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () async {
                final criteria = _searchCriteria; // Get selected criteria
                final keyword = _searchController.text;

                // Log the search input and criteria
                debugPrint(
                    'Search triggered with criteria: $criteria and keyword: $keyword');

                if (keyword.isNotEmpty) {
                  // Log before calling searchBooks
                  debugPrint('Initiating search request...');
                  try {
                    // Call the searchBooks function
                    await bookProvider.searchBooks(criteria, keyword);
                    debugPrint(
                        'Search completed. Number of books found: ${bookProvider.books.length}');
                  } catch (e) {
                    // Log any errors
                    debugPrint('Error during search: $e');
                  }
                } else {
                   Provider.of<BookProvider>(context, listen: false)
                                .fetchBooks(); // Refresh list after update
                }
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Keyword',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: bookProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: bookProvider.books.length,
                    itemBuilder: (context, index) {
                      final book = bookProvider.books[index];
                      return ListTile(
                        title: Text(book['title']),
                        subtitle: Text(book['author']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await bookProvider.deleteBook(book['_id']);
                              },
                            ),
                          ],
                        ),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookDetailPage(book: book),
                            ),
                          );

                          if (result == true) {
                            Provider.of<BookProvider>(context, listen: false)
                                .fetchBooks(); // Refresh list after update
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showAddBookDialog(context, (newBook) async {
            await Provider.of<BookProvider>(context, listen: false)
                .addBook(newBook);
          });
        },
      ),
    );
  }
}

Future<void> showAddBookDialog(
    BuildContext context, Function(Map<String, dynamic>) onAdd) async {
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final quantityController = TextEditingController();

  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add New Book'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newBook = {
                "title": titleController.text,
                "author": authorController.text,
                "quantity": int.parse(quantityController.text),
              };
              onAdd(newBook);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}
