import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'add_book_screen.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _telegramController = TextEditingController();
  final TextEditingController _whatsAppController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('توکن یافت نشد. لطفاً دوباره وارد شوید.')),
      );
      return;
    }

    final url = Uri.parse('http://10.0.2.2:5176/api/UsersApi/get-profile');

    final response = await http.get(
      url,
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        _nameController.text = data['name'] ?? '';
        _lastNameController.text = data['lastName'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phoneNumber'] ?? '';
        _addressController.text = data['address'] ?? '';
        _telegramController.text = data['telegram'] ?? '';
        _whatsAppController.text = data['whatsApp'] ?? '';
        _notesController.text = data['notes'] ?? '';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در دریافت اطلاعات: ${response.body}')),
      );
    }
  }

  Future<void> updateProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('توکن یافت نشد. لطفاً دوباره وارد شوید.')),
      );
      return;
    }

    final url = Uri.parse('http://10.0.2.2:5176/api/UsersApi/update-profile');

    final response = await http.put(
      url,
      headers: {
        'accept': '*/*',
        'Content-Type': 'application/json-patch+json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "name": _nameController.text,
        "lastName": _lastNameController.text,
        "email": _emailController.text,
        "phoneNumber": _phoneController.text,
        "address": _addressController.text,
        "telegram": _telegramController.text,
        "whatsApp": _whatsAppController.text,
        "notes": _notesController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اطلاعات با موفقیت ذخیره شد.')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddBookScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در ذخیره اطلاعات: ${response.body}')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _telegramController.dispose();
    _whatsAppController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Widget buildInput({
    required String hintText,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(255, 41, 26, 174)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color.fromARGB(255, 41, 26, 174)),
          hintTextDirection: TextDirection.rtl,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          prefixIcon: Icon(icon, color: const Color.fromARGB(255, 41, 26, 174)),
        ),
      ),
    );
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
            Text("UNIVERSBOOK",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color.fromARGB(255, 6, 27, 102),
                )),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'تکمیل اطلاعات حساب',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 6, 27, 102),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            buildInput(hintText: 'نام', icon: Icons.person_outline, controller: _nameController),
            buildInput(hintText: 'نام خانوادگی', icon: Icons.person_outline, controller: _lastNameController),
            buildInput(hintText: 'ایمیل', icon: Icons.email_outlined, controller: _emailController),
            buildInput(hintText: 'تلفن', icon: Icons.phone_outlined, controller: _phoneController),
            buildInput(hintText: 'آدرس', icon: Icons.location_on_outlined, controller: _addressController),
            buildInput(hintText: 'تلگرام', icon: Icons.message_outlined, controller: _telegramController),
            buildInput(hintText: 'واتس‌اپ', icon: Icons.message_outlined, controller: _whatsAppController),
            buildInput(hintText: 'یادداشت (اختیاری)', icon: Icons.note_outlined, controller: _notesController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 41, 26, 174),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text("ذخیره تغییرات", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
