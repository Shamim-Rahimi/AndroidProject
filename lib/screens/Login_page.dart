import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


import 'home_page_screen.dart';
import 'signup_page.dart';
import 'user_info_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoginMode = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<bool> login(String username, String password) async {
    final url = Uri.parse('http://10.0.2.2:5176/api/UsersApi/login');

    final response = await http.post(
      url,
      headers: {
        'accept': '*/*',
        'Content-Type': 'application/json-patch+json',
      },
      body: jsonEncode({
        'userName': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      final token = body['token'];
      final user = body['user'];
      final role = body['role'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_id', user['id']);
      await prefs.setString('user_name', user['name']);
      await prefs.setString('user_last_name', user['lastName']);
      await prefs.setString('user_username', user['userName']);
      await prefs.setString('user_role', role);

      return true;
    } else {
      print('Login failed: ${response.body}');
      return false;
    }
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
              color: Color.fromARGB(255, 6, 27, 102),
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
            const Icon(
              Icons.supervised_user_circle,
              size: 80,
              color: Color.fromARGB(255, 6, 27, 102),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 34, 53, 199),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpCompletionPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "ثبت نام",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isLoginMode = true;
                      });
                    },
                    child: Text(
                      "ورود",
                      style: TextStyle(
                        color: _isLoginMode
                            ? Colors.white
                            : const Color.fromARGB(255, 180, 180, 180),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color.fromARGB(255, 34, 53, 199)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _emailController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  hintText: 'ایمیل یا شماره موبایل',
                  hintStyle: TextStyle(color: Color.fromARGB(255, 34, 53, 199)),
                  hintTextDirection: TextDirection.rtl,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: Color.fromARGB(255, 34, 53, 199),
                  ),
                ),
              ),
            ),
            if (_isLoginMode) ...[
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Color.fromARGB(255, 34, 53, 199)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _passwordController,
                  textAlign: TextAlign.right,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'رمز عبور',
                    hintStyle: TextStyle(
                      color: Color.fromARGB(255, 34, 53, 199),
                    ),
                    hintTextDirection: TextDirection.rtl,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Color.fromARGB(255, 34, 53, 199),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_isLoginMode) {
                  final email = _emailController.text.trim();
                  final password = _passwordController.text;

                  final success = await login(email, password);
                  if (success) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("ورود ناموفق بود. لطفاً دوباره تلاش کنید."),
                      ),
                    );
                  }
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpCompletionPage(),
                    ),
                  );
                }
              },
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
}
