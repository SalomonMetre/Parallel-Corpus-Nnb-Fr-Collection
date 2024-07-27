// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transcollect_nnb_fr_hub/data/models/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _sourceTextController = TextEditingController();
  final TextEditingController _targetTextController = TextEditingController();
  int _selectedIndex = 0;
  String _selectedDropDownValue = "NNB-FR";

  void _showAppInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Column(
            children: [
              Text('About this project'),
              Divider(),
            ],
          ),
          content: RichText(
            text: const TextSpan(
              style: TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  text: 'This app allows users to submit sentences that will form a large parallel corpus for an ongoing Nande-French translation project. ',
                ),
                TextSpan(
                  text: 'Your submissions are anonymous. ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: 'If you want your contributions to be recognized, head over to the ',
                ),
                TextSpan(
                  text: '"View sentences"',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                TextSpan(
                  text: ' page and read the instructions by clicking on the ',
                ),
                TextSpan(
                  text: 'question mark icon.',
                  style: TextStyle(color: Colors.teal,),
                ),
              ],
            ),),
          actions: [
            TextButton(
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(Colors.white),
                backgroundColor: WidgetStateProperty.all(Colors.red),
              ),
              child: const Text('Close',),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleSubmit() async {
    // Define your submit function here
    final sourceText = _sourceTextController.text;
    final targetText = _targetTextController.text;

    if (sourceText.isEmpty || targetText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "You cannot submit empty sentences!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String email = prefs.getString('email') ?? '';
      final dataToSubmit = <String, String>{
        "source_lang": _selectedDropDownValue == "NNB-FR" ? "nnb" : "fr",
        "target_lang": _selectedDropDownValue == "NNB-FR" ? "fr" : "nnb",
        "source_sentence": sourceText,
        "target_sentence": targetText,
        if (email.isNotEmpty)
        "email" : email,
      };
      await FirestoreModel().add("sentences", dataToSubmit);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "New sentence pair successfully submitted !",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.teal,
        ),
      );
    }
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // const Text(
            //   '',
            //   style: TextStyle(
            //     fontSize: 14.0,
            //     color: Colors.teal,
            //   ),
            // ),
            const SizedBox(width: 16),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.teal,
                ),
                items: <String>['NNB-FR', 'FR-NNB'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(color: Colors.teal),
                    ),
                  );
                }).toList(),
                value: _selectedDropDownValue,
                onChanged: (value) {
                  // Handle dropdown menu selection
                  setState(() {
                    _selectedDropDownValue = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(builder: (context, constraints) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                if (constraints.maxWidth < 600)
                  ..._buildContent()
                else
                  Expanded(
                    flex: 12,
                    child: Row(
                      children: [
                        ..._buildContent(),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                    backgroundColor: WidgetStateProperty.all(Colors.teal),
                  ),
                  child: const Text('Submit'),
                ),
              ],
            );
          }),
        ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showAppInfoDialog(context);
        },
        child: const Icon(Icons.question_mark_sharp),
      ),
    );
  }

  List<Widget> _buildContent() {
    return [
      const SizedBox(height: 16),
      Expanded(
        flex: 4,
        child: TextField(
          controller: _sourceTextController,
          style: const TextStyle(color: Colors.teal),
          decoration: InputDecoration(
            hintText:
                "Enter a sentence in ${_selectedDropDownValue == "NNB-FR" ? "Nande" : "French"}",
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ),
      const SizedBox(height: 16),
      Expanded(
        flex: 4,
        child: TextField(
          controller: _targetTextController,
          style: const TextStyle(color: Colors.teal),
          decoration: InputDecoration(
            hintText:
                "Enter the translation in ${_selectedDropDownValue == "NNB-FR" ? "French" : "Nande"}",
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ),
    ];
  }
}
