import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';


class BooksDetailPage extends StatefulWidget {
  final int bookId;

  const BooksDetailPage({super.key, required this.bookId});

  @override
  State<BooksDetailPage> createState() => _BooksDetailPageState();
}

class _BooksDetailPageState extends State<BooksDetailPage> {
  Map<String, dynamic>? book;
  bool isLoading = true;

  Future<void> fetchBookDetail() async {
    try {
      final url = Uri.parse(
          'http://10.0.2.2:5176/api/BookApi/book-detail/${widget.bookId}');

      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          book = json.decode(utf8.decode(response.bodyBytes));
          isLoading = false;
        });
      } else {
        throw Exception('خطا در دریافت اطلاعات');
      }
    } catch (e) {
      print('خطا: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBookDetail();
  }

  @override
  Widget build(BuildContext context) {
    const Color cardColor = Color.fromARGB(255, 19, 191, 30);
    const Color backgroundColor = Color.fromARGB(255, 34, 53, 199);
    const Color textColor = Color.fromARGB(255, 255, 255, 255);
    const Color secondaryTextColor = Color.fromARGB(255, 251, 251, 251);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Center(
          child: Text(
            "UNIVERSBOOK",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: textColor,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: textColor),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : book == null
          ? const Center(
        child: Text(
          'خطا در بارگیری اطلاعات',
          style: TextStyle(color: Colors.white),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150,
                  height: 200,
                  margin: const EdgeInsets.only(left: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      base64Decode(book!['imageBase64']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildInfoCard(book!['title'], textColor,
                          cardColor, true),
                      _buildInfoCard(
                          'نویسنده: ${book!['author']}',
                          secondaryTextColor,
                          cardColor,
                          false),
                      _buildInfoCard(
                          book!['majorName'] ?? '',
                          secondaryTextColor,
                          cardColor,
                          false),
                      _buildInfoCard(
                          'نوع تبادل: ${book!['exchangeType']}',
                          secondaryTextColor,
                          cardColor,
                          false),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'توضیحات',
              content: book!['description'] ?? 'بدون توضیحات',
              textColor: textColor,
              backgroundColor: cardColor,
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'اضافه‌کننده',
              content:
              '${book!['name']} : نام\n${book!['lastName']} : نام خانوادگی',
              textColor: textColor,
              backgroundColor: cardColor,
            ),
            // بعد از _buildSection(title: 'اضافه‌کننده', ...) این قسمت رو جایگزین کن:

            const SizedBox(height: 8),
            _buildSection(
              title: 'ایمیل',
              content: book!['email'] ?? 'ندارد',
              textColor: textColor,
              backgroundColor: cardColor,
            ),
            const SizedBox(height: 8),
            _buildSection(
              title: 'تلگرام',
              content:  book!['telegram'] ?? 'ندارد',
              textColor: textColor,
              backgroundColor: cardColor,
            ),
            const SizedBox(height: 8),
            _buildSection(
              title: 'واتس اپ',
              content: book!['whatsApp'] ?? 'ندارد',
              textColor: textColor,
              backgroundColor: cardColor,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final phone = book!['whatsApp'];
                final Uri phoneUri = Uri(scheme: 'tel', path: phone);
                if (await canLaunchUrl(phoneUri)) {
                  await launchUrl(phoneUri);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('قادر به تماس نیست.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: cardColor,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text(
                'تماس',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),

          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String text, Color color, Color bg, bool bold) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: bold ? 18 : 14,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: color,
        ),
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required Color textColor,
    required Color backgroundColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(31, 0, 0, 0),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(fontSize: 14, color: textColor),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}
