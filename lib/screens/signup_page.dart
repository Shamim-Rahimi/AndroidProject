import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'verification_page.dart';

class SignUpCompletionPage extends StatefulWidget {
  const SignUpCompletionPage({super.key});

  @override
  _SignUpCompletionPageState createState() => _SignUpCompletionPageState();
}

class _SignUpCompletionPageState extends State<SignUpCompletionPage> {
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _submit() async {
    String username = _usernameController.text.trim();
    String name = _nameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (password.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        password == confirmPassword) {
      try {
        final response = await ApiService.registerUser(
          username: username,
          name: name,
          lastName: lastName,
          password: password,
        );

        // بدنه‌ی جواب رو decode می‌کنیم
        final data = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ثبت‌نام با موفقیت انجام شد')),
        );


        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationPage(email: username),
          ),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطا در ثبت‌نام: $error")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رمزها باید یکسان و پر باشند!')),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
            Icon(
              Icons.menu_book_outlined,
              color: Color.fromARGB(255, 41, 26, 174),
            ),
            SizedBox(width: 8),
            Text(
              "UNIVERSBOOK",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color.fromARGB(255, 6, 27, 102),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.arrow_forward_ios,
              color: Color.fromARGB(255, 41, 26, 174),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              ' ثبت‌نام',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 6, 27, 102),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildTextField("نام کاربری (ایمیل)", _usernameController, Icons.email),
            const SizedBox(height: 16),
            _buildTextField("نام", _nameController, Icons.person),
            const SizedBox(height: 16),
            _buildTextField("نام خانوادگی", _lastNameController, Icons.person_outline),
            const SizedBox(height: 16),
            _buildTextField("رمز عبور", _passwordController, Icons.lock, isPassword: true),
            const SizedBox(height: 16),
            _buildTextField("تأیید رمز عبور", _confirmPasswordController, Icons.lock, isPassword: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 34, 53, 199),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
              ),
              child: const Text(
                "ادامه",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, TextEditingController controller, IconData icon, {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 34, 53, 199)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color.fromARGB(255, 34, 53, 199)),
          hintTextDirection: TextDirection.rtl,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color.fromARGB(255, 34, 53, 199),
          ),
        ),
      ),
    );
  }
}
