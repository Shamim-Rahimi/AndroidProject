import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'add_book_screen.dart';
import 'my_books_page.dart';
import 'user_info_page.dart';
import 'books_detail_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedField;
  String? _selectedCourse;
  String? _selectedAuthor;
  String _searchQuery = '';

  List<String> _fields = ['هیچ کدام'];
  List<String> _courses = ['هیچ کدام'];
  List<String> _authors = ['هیچ کدام'];
  List<Map<String, dynamic>> allBooks = [];
  bool isLoading = true;

  bool isLoggedIn = false;
  String? username;
  String? token;


  @override
  void initState() {
    super.initState();
    loadLoginStatus();

    fetchMajors();
    fetchBookTitles();
    fetchAuthors();
    fetchBooks();
  }
  Future<void> loadLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('auth_token');       // ✅ درست شد
      username = prefs.getString('user_name');     // ✅ درست شد

      isLoggedIn = token != null && token!.isNotEmpty;
    });
  }
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    // پاک کردن کلیدهای مرتبط با وضعیت ورود
    await prefs.remove('auth_token');
    await prefs.remove('user_name');
    await prefs.remove('user_last_name');
    await prefs.remove('user_username');
    await prefs.remove('user_role');
    await prefs.remove('user_id');

    setState(() {
      isLoggedIn = false;
      token = null;
      username = null;
    });

    // هدایت به صفحه ورود و پاک کردن مسیرهای قبلی
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
    );


    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('با موفقیت خارج شدید')),
    );
  }



  Future<void> fetchMajors() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:5176/api/BookApi/majors'));
    if (response.statusCode == 200) {
      final List<dynamic> majorsJson = json.decode(response.body);
      setState(() {
        _fields = ['هیچ کدام', ...majorsJson.map((e) => e['majorName'] as String)];
      });
    }
  }

  Future<void> fetchBookTitles() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:5176/api/BookApi/book-names'));
    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final List<dynamic> data = jsonBody['data'];
      setState(() {
        _courses = ['هیچ کدام', ...data.map((e) => e['title'] as String)];
      });
    }
  }

  Future<void> fetchAuthors() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:5176/api/BookApi/book-authors'));
    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final List<dynamic> data = jsonBody['data'];
      setState(() {
        _authors = ['هیچ کدام', ...data.map((e) => e['author'] as String)];
      });
    }
  }

  Future<void> fetchBooks() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:5176/api/BookApi/all-books'));
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

  List<Map<String, dynamic>> get filteredBooks {
    return allBooks.where((book) {
      final fieldMatch =
          _selectedField == null || _selectedField == 'هیچ کدام' || book['majorName'] == _selectedField;
      final courseMatch =
          _selectedCourse == null || _selectedCourse == 'هیچ کدام' || book['title'] == _selectedCourse;
      final authorMatch =
          _selectedAuthor == null || _selectedAuthor == 'هیچ کدام' || book['author'] == _selectedAuthor;
      final searchMatch = _searchQuery.isEmpty ||
          book['title'].toLowerCase().contains(_searchQuery.toLowerCase());
      return fieldMatch && courseMatch && authorMatch && searchMatch;
    }).toList();
  }

  final Color cardColor = const Color.fromARGB(255, 34, 53, 199);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      endDrawer: Drawer(
        child: Container(
          color: const Color.fromARGB(255, 255, 255, 255),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.menu_book_outlined,
                      color: Color.fromARGB(255, 41, 26, 174),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "UNIVERSBOOK",
                      style: TextStyle(
                        color: Color.fromARGB(255, 6, 27, 102),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // وضعیت ورود یا نمایش نام کاربر و خروج
              isLoggedIn
                  ? Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.account_circle,
                      size: 40,
                      color: Color.fromARGB(255, 41, 26, 174),
                    ),
                    title: Text(
                      username ?? 'کاربر',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 100, 93, 170),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'خروج از حساب',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(context); // بستن دراور
                      await logout(); // اجرای خروج کامل
                    },
                  ),
                ],
              )
                  : ListTile(
                leading: const Icon(
                  Icons.login,
                  color: Color.fromARGB(255, 41, 26, 174),
                ),
                title: const Text(
                  'ورود به حساب کاربری',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 100, 93, 170),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  ).then((_) => loadLoginStatus());
                },
              ),

              // آیتم‌های دیگر منو
              ListTile(
                leading: const Icon(
                  Icons.bookmark_border,
                  color: Color.fromARGB(255, 41, 26, 174),
                ),
                title: const Text(
                  "افزودن کتاب جدید",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 100, 93, 170),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddBookScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.book,
                  color: Color.fromARGB(255, 41, 26, 174),
                ),
                title: const Text(
                  'لیست کتاب‌های من',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 100, 93, 170),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyBooksPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.person_add,
                  color: Color.fromARGB(255, 41, 26, 174),
                ),
                title: const Text(
                  'تکمیل اطلاعات حساب',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 100, 93, 170),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UserInfoPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.info,
                  color: Color.fromARGB(255, 41, 26, 174),
                ),
                title: const Text(
                  'درباره ما',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 100, 93, 170),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: const Color.fromARGB(255, 255, 255, 255),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  const Icon(
                    Icons.menu_book_outlined,
                    color: Color.fromARGB(255, 41, 26, 174),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "UNIVERSBOOK",
                    style: TextStyle(
                      color: Color.fromARGB(255, 6, 27, 102),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(
                        Icons.menu,
                        color: Color.fromARGB(255, 41, 26, 174),
                      ),
                      onPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.right,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'جست‌وجو',
                  hintStyle: TextStyle(color: Colors.white70),
                  hintTextDirection: TextDirection.rtl,
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Color.fromARGB(255, 41, 26, 174)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedField,
                        hint: const Text(
                          'نام رشته',
                          style: TextStyle(
                            color: Color.fromARGB(255, 41, 26, 174),
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedField =
                            newValue == 'هیچ کدام' ? null : newValue;
                          });
                        },
                        items: _fields.map((String field) {
                          return DropdownMenuItem<String>(
                            value: field,
                            child: Text(
                              field,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 41, 26, 174),
                              ),
                            ),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        isExpanded: true,
                        alignment: Alignment.centerRight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Color.fromARGB(255, 41, 26, 174)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedCourse,
                        hint: const Text(
                          'نام درس',
                          style: TextStyle(
                            color: Color.fromARGB(255, 41, 26, 174),
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedCourse =
                            newValue == 'هیچ کدام' ? null : newValue;
                          });
                        },
                        items: _courses.map((String course) {
                          return DropdownMenuItem<String>(
                            value: course,
                            child: Text(
                              course,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 41, 26, 174),
                              ),
                            ),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        isExpanded: true,
                        alignment: Alignment.centerRight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Color.fromARGB(255, 41, 26, 174)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedAuthor,
                        hint: const Text(
                          'نام نویسنده',
                          style: TextStyle(
                            color: Color.fromARGB(255, 41, 26, 174),
                            fontSize: 15,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedAuthor =
                            newValue == 'هیچ کدام' ? null : newValue;
                          });
                        },
                        items: _authors.map((String author) {
                          return DropdownMenuItem<String>(
                            value: author,
                            child: Text(
                              author,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 41, 26, 174),
                              ),
                            ),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        isExpanded: true,
                        alignment: Alignment.centerRight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Image.asset("assets/book.jpg", fit: BoxFit.cover),
            const SizedBox(height: 8),
            const Text(
              'از کتابخانه شخصی خودتان\nکلاس درس بسازید',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color.fromARGB(255, 20, 14, 80),
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'نمایش کتاب‌ها',
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
                  return GestureDetector (
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BooksDetailPage(bookId: book['bookID']),
                        ),
                      );
                    },
                    child: Stack(
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
                    
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedField = null;
                  _selectedCourse = null;
                  _selectedAuthor = null;
                  _searchQuery = '';
                });
              },
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              label: const Text(
                "مشاهده همه",
                style: TextStyle(color: Color.fromARGB(255, 20, 14, 80)),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              color: cardColor,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'کتاب‌های دانشگاهی رو راحت‌تر از همیشه پیدا کن با',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'UNIVERSBOOK',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Icon(Icons.telegram, color: Colors.white),
                      Icon(Icons.facebook, color: Colors.white),
                      Icon(Icons.email, color: Colors.white),
                      Icon(Icons.phone, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
