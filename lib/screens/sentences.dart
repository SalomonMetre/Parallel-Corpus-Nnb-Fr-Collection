import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transcollect_nnb_fr_hub/data/models/firestore.dart';

class SentenceProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _sentences = [];
  String _email = '';
  bool _isAdmin = false;
  final FirestoreModel _firestoreModel = FirestoreModel();

  List<Map<String, dynamic>> get sentences => _sentences;
  String get email => _email;
  bool get isAdmin => _isAdmin;

  Future<void> fetchSentences() async {
    _sentences = await _firestoreModel.getAll('sentences');
    notifyListeners();
  }

  Future<void> fetchEmailStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _email = prefs.getString('email') ?? '';
    if (_email.isNotEmpty) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('admins')
          .doc(_email)
          .get();
      if (snapshot.exists && snapshot.data() is Map<String, dynamic>) {
        final data = snapshot.data() as Map<String, dynamic>;
        _isAdmin = data['status'] == 'valid';
      }
    }
    notifyListeners();
  }

  Future<void> saveEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await FirebaseFirestore.instance
        .collection('admins')
        .doc(email)
        .set({'email': email, 'status': 'invalid'});
    _email = email;
    _isAdmin = true;
    notifyListeners();
  }
}

class SentenceListScreen extends StatefulWidget {
  @override
  _SentenceListScreenState createState() => _SentenceListScreenState();
}

class _SentenceListScreenState extends State<SentenceListScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 1;

  void _showEmailSubmissionInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Column(
            children: [
              Text('Before you add your email address ⚠️'),
              Divider(),
            ],
          ),
          content: RichText(
            text: const TextSpan(
              style: TextStyle(color: Colors.black),
              children: [
                TextSpan(
                    text:
                        'Currently, your contributions are still anonymous. '),
                TextSpan(
                  text:
                      'By adding your email, your contributions will be saved along with your email address. ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: 'If you wish to become an admin, reach out to '),
                TextSpan(
                  text: 'leblack2008@gmail.com.',
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
                TextSpan(
                    text: 'As an admin, you will be able to edit sentences.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(Colors.white),
                backgroundColor: WidgetStateProperty.all(Colors.red),
              ),
              child: const Text(
                'Close',
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigation based on index
    switch (index) {
      case 0:
        // navigate to the Home screen
        context.goNamed("home");
      case 1:
        // Navigate to View Sentences
        context.goNamed("sentences");
        break;
      case 2:
        SystemNavigator.pop();
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SentenceProvider>(context, listen: false);
    provider.fetchSentences();
    provider.fetchEmailStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Sentences'),
        actions: [
          IconButton(
            icon: const Icon(Icons.attach_email_rounded),
            onPressed: () => _showEmailDialog(context),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedLabelStyle: const TextStyle(fontStyle: FontStyle.italic),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'View Sentences',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.exit_to_app),
            label: 'Quit',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
      body: Consumer<SentenceProvider>(
        builder: (context, provider, child) {
          final sentences = provider.sentences.where((sentence) {
            final query = _searchController.text.toLowerCase();
            final sourceText =
                sentence['source_sentence']?.toString().toLowerCase() ?? '';
            final targetText =
                sentence['target_sentence']?.toString().toLowerCase() ?? '';
            return sourceText.contains(query) || targetText.contains(query);
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: sentences.length,
                  itemBuilder: (context, index) {
                    final sentence = sentences[index];
                    return ListTile(
                      title: Card(
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          margin: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sentence['source_lang'] == "nnb"
                                    ? "Nande"
                                    : "French",
                                style: const TextStyle(color: Colors.red),
                              ),
                              TextFormField(
                                initialValue: sentence['source_sentence'],
                                enabled: provider.isAdmin,
                                decoration: const InputDecoration(
                                    border: InputBorder.none),
                                onFieldSubmitted: (value) {
                                  if (provider.isAdmin) {
                                    // Update source text
                                    FirebaseFirestore.instance
                                        .collection('sentences')
                                        .doc(sentence['id'])
                                        .update({'source_sentence': value});
                                  }
                                },
                              ),
                              Divider(
                                thickness: 2,
                                color: Colors.teal.shade100,
                              ),
                              Text(
                                sentence['target_lang'] == "nnb"
                                    ? "Nande"
                                    : "French",
                                style: const TextStyle(color: Colors.red),
                              ),
                              TextFormField(
                                initialValue: sentence['target_sentence'],
                                enabled: provider.isAdmin,
                                decoration: const InputDecoration(
                                    border: InputBorder.none),
                                onFieldSubmitted: (value) {
                                  if (provider.isAdmin) {
                                    // Update target text
                                    FirebaseFirestore.instance
                                        .collection('sentences')
                                        .doc(sentence['id'])
                                        .update({'target_sentence': value});
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showEmailSubmissionInfo(context);
        },
        child: const Icon(Icons.question_mark_rounded),
      ),
    );
  }

  void _showEmailDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Your Email'),
        content: TextField(
          controller: emailController,
          decoration: InputDecoration(
              labelText: 'Email',
              helper: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.teal.shade300),
                  children: [
                    const TextSpan(
                        text:
                            'Please make sure you have read the instructions '),
                    TextSpan(
                      text: '(by clicking the question mark icon)',
                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.red.shade900),
                    ),
                    const TextSpan(text: ' before you add your email.'),
                  ],
                ),
              )),
        ),
        actions: [
          TextButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.red),
              foregroundColor: WidgetStateProperty.all(Colors.white),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.teal),
              foregroundColor: WidgetStateProperty.all(Colors.white),
            ),
            onPressed: () {
              Provider.of<SentenceProvider>(context, listen: false)
                  .saveEmail(emailController.text);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "You have added your email to be part of admins !",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.teal,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
