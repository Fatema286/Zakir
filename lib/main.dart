import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const SmartRepairApp());
}

class SmartRepairApp extends StatelessWidget {
  const SmartRepairApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'স্মার্ট মোবাইল রিপেয়ার',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainDashboard(),
    );
  }
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AiChatScreen(),
    const PartsListScreen(),
    const CallSupportScreen(),
    const StoreLocationScreen(),
    const OwnerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('জাকির মোবাইল সার্ভিসিং পয়েন্ট', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade800,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.smart_toy), label: 'এআই এজেন্ট'),
          NavigationDestination(icon: Icon(Icons.phone_android), label: 'পার্টস'),
          NavigationDestination(icon: Icon(Icons.support_agent), label: 'কল সাপোর্ট'),
          NavigationDestination(icon: Icon(Icons.store), label: 'লোকেশন'),
          NavigationDestination(icon: Icon(Icons.person), label: 'প্রোফাইল'),
        ],
      ),
    );
  }
}

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List> _messages = [
    {"sender": "AI", "text": "আসসালামু আলাইকুম! জাকির মোবাইল সার্ভিসিং পয়েন্টে আপনাকে স্বাগতম। মোবাইল সমস্যা বা পার্টস সম্পর্কে বলুন।"}
  ];
  bool _isLoading = false;

  final String apiKey = "YOUR_GEMINI_API_KEY_HERE";

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"sender": "User", "text": text});
      _isLoading = true;
    });
    _controller.clear();

    try {
      final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": "তুমি একজন অভিজ্ঞ মোবাইল সার্ভিসিং টেকনিশিয়ান। সহজ বাংলায় উত্তর দাও: $text"}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['candidates'][0]['content']['parts'][0]['text'];
        setState(() => _messages.add({"sender": "AI", "text": reply}));
      } else {
        setState(() => _messages.add({"sender": "AI", "text": "এপিআই কি-তে সমস্যা হয়েছে, দয়া করে কি-টি চেক করুন।"}));
      }
    } catch (e) {
      setState(() => _messages.add({"sender": "AI", "text": "ইন্টারনেট সংযোগ বা সার্ভারে ত্রুটি হয়েছে।"}));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isUser = msg["sender"] == "User";
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.blue.shade700 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    msg["text"]!,
                    style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 15),
                  ),
                ),
              );
            },
          ),
        ),
        if (_isLoading) const LinearProgressIndicator(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'সমস্যা বা মডেলের নাম লিখুন...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.blue.shade800,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class PartsListScreen extends StatefulWidget {
  const PartsListScreen({super.key});

  @override
  State<PartsListScreen> createState() => _PartsListScreenState();
}

class _PartsListScreenState extends State<PartsListScreen> {
  String _searchQuery = "";

  final List> _partsData = [
    {"type": "ডিসপ্লে", "models": "Oppo A5s, A7, A12, A11k / Realme 3, 3i", "price": "১,১০০ - ১,৩৫০ টাকা"},
    {"type": "ডিসপ্লে", "models": "Oppo A15, A15s, A16e / Realme C11, C12, C15, C20, C21", "price": "১,২০০ - ১,৭০০ টাকা"},
    {"type": "ডিসপ্লে", "models": "Vivo Y11, Y12, Y15, Y17, Y12i, U10", "price": "১,১০০ - ১,৪৫০ টাকা"},
    {"type": "ডিসপ্লে", "models": "Vivo Y20, Y20s, Y12s, Y21 / Realme C21Y, C25Y", "price": "৮৫০ - ১,৩০০ টাকা"},
    {"type": "ডিসপ্লে", "models": "Samsung A12, M12, A02, A02s, A03, A03s", "price": "১,১৫০ - ১,৫৫০ টাকা"},
    {"type": "ডিসপ্লে", "models": "Samsung A30, A50, A50s, A30s", "price": "১,৬০০ - ৩,৮০০ টাকা"},
    {"type": "ব্যাটারি", "models": "BLP673 (Oppo A3s, A5, A7, A5s, A12)", "price": "৬৫০ - ৮৫০ টাকা"},
    {"type": "ব্যাটারি", "models": "B-G7 / B-K3 (Vivo Y11, Y12, Y15, Y17, Y20)", "price": "৭০০ - ৯০০ টাকা"},
    {"type": "ব্যাটারি", "models": "EB-BA217ABY (Samsung A12, A21s, M12)", "price": "৭৫০ - ৯৫০ টাকা"},
  ];

  @override
  Widget build(BuildContext context) {
    final filteredList = _partsData.where((item) {
      return item["models"]!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             item["type"]!.contains(_searchQuery);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'মডেল সার্চ করুন (যেমন: A12, Y20, Samsung)...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final item = filteredList[index];
              final isDisplay = item["type"] == "ডিসপ্লে";
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isDisplay ? Colors.blue.shade100 : Colors.green.shade100,
                    child: Icon(
                      isDisplay ? Icons.smartphone : Icons.battery_charging_full,
                      color: isDisplay ? Colors.blue.shade800 : Colors.green.shade800,
                    ),
                  ),
                  title: Text(item["models"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("ক্যাটাগরি: ${item["type"]}"),
                  trailing: Text(
                    item["price"]!,
                    style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class CallSupportScreen extends StatelessWidget {
  const CallSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.support_agent, size: 80, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'সরাসরি টেকনিশিয়ানের সাথে কথা বলুন',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'আপনার ফোনের সমস্যা সরাসরি দেখাতে ভিডিও কল করুন অথবা কথা বলতে অডিও কল দিন।',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('অডিও কল সংযোগ হচ্ছে...')),
                    );
                  },
                  icon: const Icon(Icons.call),
                  label: const Text('অডিও কল'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ভিডিও কল সংযোগ হচ্ছে...')),
                    );
                  },
                  icon: const Icon(Icons.videocam),
                  label: const Text('ভিডিও কল'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StoreLocationScreen extends StatelessWidget {
  const StoreLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.map, size: 60, color: Colors.blue),
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            child: ListTile(
              leading: Icon(Icons.location_on, color: Colors.red),
              title: Text('জাকির মোবাইল সার্ভিসিং পয়েন্ট', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('যোগীর কোফা, বহেড়াতৈল, সখীপুর, টাঙ্গাইল\nফোন: ০১৭৯০৬০২৬১৩\nসকাল ৯টা - রাত ৮টা পর্যন্ত খোলা।'),
            ),
          ),
        ],
      ),
    );
  }
}

class OwnerProfileScreen extends StatelessWidget {
  const OwnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 12),
          const Text(
            'প্রোপ্রাইটর ও টেকনিশিয়ান',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 30),
          const Text(
            'আর্টিস্টিক পোর্ট্রেট স্কেচ:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text("আপনার জেনারেট করা স্কেচটি এখানে প্রদর্শিত হবে"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
