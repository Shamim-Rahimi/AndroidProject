import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'my_books_page.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedExchangeType;
  String? _selectedCategory;
  List<dynamic> _categories = [];
  bool _isLoadingCategories = true;

  final List<String> _exchangeTypes = ['فروش', 'معاوضه', 'اهداء'];

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    const url = 'http://10.0.2.2:5176/api/BookApi/majors';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _categories = json.decode(response.body);
          _isLoadingCategories = false;
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در دریافت دسته‌بندی‌ها: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitBook() async {
    if (_titleController.text.isEmpty ||
        _authorController.text.isEmpty ||
        _selectedExchangeType == null ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفا همه فیلدهای الزامی را پر کنید')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('توکن یافت نشد! لطفا دوباره وارد شوید.')),
      );
      return;
    }

    var uri = Uri.parse('http://10.0.2.2:5176/api/BookApi');
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['accept'] = '*/*';

    if (_imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('ImageFile', _imageFile!.path));
    }

    request.fields['Title'] = _titleController.text;
    request.fields['Author'] = _authorController.text;
    request.fields['ExchangeType'] = _selectedExchangeType!;
    request.fields['Description'] = _descriptionController.text;
    request.fields['MajorName'] = _selectedCategory!;



    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('کتاب با موفقیت افزوده شد')),
        );
        Navigator.push(context,MaterialPageRoute(builder: (context)=> const MyBooksPage()),);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در افزودن کتاب: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در ارسال درخواست: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        title: const Text(
          "افزودن کتاب",
          style: TextStyle(color: Color.fromARGB(255, 6, 27, 102)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Color.fromARGB(255, 41, 26, 174)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color.fromARGB(255, 41, 26, 174)),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey[200],
                ),
                child: _imageFile == null
                    ? const Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(_imageFile!, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(_titleController, "عنوان کتاب"),
            const SizedBox(height: 16),
            _buildTextField(_authorController, "نویسنده کتاب"),
            const SizedBox(height: 16),
            _buildDropdown(_exchangeTypes, "نوع تبادل", (value) {
              setState(() {
                _selectedExchangeType = value;
              });
            }),
            const SizedBox(height: 16),
            _isLoadingCategories
                ? const CircularProgressIndicator()
                : _buildCategoryDropdown(),
            const SizedBox(height: 16),
            _buildTextField(_descriptionController, "توضیحات (اختیاری)", maxLines: 3),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitBook,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 41, 26, 174),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text("ذخیره کتاب", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 41, 26, 174)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String hint, ValueChanged<String?> onChanged) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 41, 26, 174)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonFormField<String>(
        value: items.contains(_selectedExchangeType) ? _selectedExchangeType : null,
        hint: Text(hint),
        onChanged: onChanged,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, textAlign: TextAlign.right),
          );
        }).toList(),
        decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16)),
        isExpanded: true,
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 41, 26, 174)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        hint: const Text("دسته‌بندی"),
        onChanged: (value) {
          setState(() {
            _selectedCategory = value;
          });
        },
        items: _categories.map<DropdownMenuItem<String>>((category) {
          return DropdownMenuItem<String>(
            value: category['majorName'],
            child: Text(category['majorName'], textAlign: TextAlign.right),
          );
        }).toList(),

        decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16)),
        isExpanded: true,
      ),
    );
  }
}
