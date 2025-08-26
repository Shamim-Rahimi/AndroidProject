import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MyBooksPage extends StatefulWidget {
  const MyBooksPage({super.key});

  @override
  _MyBooksPageState createState() => _MyBooksPageState();
}

class _MyBooksPageState extends State<MyBooksPage> {
  String _searchQuery = '';
  List<Map<String, dynamic>> allBooks = [];
  bool isLoading = true;

  final Color cardColor = const Color.fromARGB(255, 34, 53, 199);

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('توکن یافت نشد! لطفا دوباره وارد شوید.')),
      );
      return;
    }

    final uri = Uri.parse('http://10.0.2.2:5176/api/BookApi/user-books');
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'accept': '*/*',
    });

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        allBooks = List<Map<String, dynamic>>.from(jsonData['data']);
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('دریافت اطلاعات کتاب‌ها ناموفق بود.')),
      );
    }
  }

  Future<void> deleteBook(int bookID) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('توکن یافت نشد! لطفا دوباره وارد شوید.')),
      );
      return;
    }

    final uri = Uri.parse('http://10.0.2.2:5176/api/BookApi/delete-book/$bookID');
    final response = await http.delete(uri, headers: {
      'Authorization': 'Bearer $token',
      'accept': '*/*',
    });

    if (response.statusCode == 200) {
      setState(() {
        allBooks.removeWhere((book) => book['bookID'] == bookID);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('کتاب با موفقیت حذف شد.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حذف کتاب ناموفق بود.')),
      );
    }
  }

  List<Map<String, dynamic>> get filteredBooks {
    return allBooks.where((book) {
      return _searchQuery.isEmpty ||
          book['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.menu_book_outlined, color: Color.fromARGB(255, 41, 26, 174)),
            SizedBox(width: 8),
            Text(
              "UNIVERSBOOK",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color.fromARGB(255, 6, 27, 102)),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Color.fromARGB(255, 41, 26, 174)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            // Search
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.right,
                        onChanged: (value) => setState(() => _searchQuery = value),
                        decoration: const InputDecoration(
                          hintText: 'جست‌وجو',
                          hintStyle: TextStyle(color: Colors.white70),
                          hintTextDirection: TextDirection.rtl,
                          border: InputBorder.none,
                          suffixIcon: Icon(Icons.search, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'نمایش کتاب‌های من',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 20, 14, 80),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.65,
                ),
                itemCount: filteredBooks.length,
                itemBuilder: (context, index) {
                  final book = filteredBooks[index];
                  Uint8List imageBytes = base64Decode(book['imageBase64']);
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                child: Image.memory(imageBytes, fit: BoxFit.cover, width: double.infinity),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    book['title'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'نویسنده: ${book['author'] ?? ''}',
                                    style: const TextStyle(fontSize: 12, color: Colors.white),
                                    textAlign: TextAlign.right,
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.category, size: 14, color: Colors.white),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'دسته بندی: ${book['majorName'] ?? ''}',
                                          style: const TextStyle(fontSize: 12, color: Colors.white),
                                          textAlign: TextAlign.right,
                                          textDirection: TextDirection.rtl,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          onPressed: () => deleteBook(book['bookID']),
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => setState(() => _searchQuery = ''),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              label: const Text(
                "مشاهده همه",
                style: TextStyle(color: Color.fromARGB(255, 20, 14, 80)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
