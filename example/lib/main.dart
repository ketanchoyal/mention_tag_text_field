import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mention_tag_text_field/mention_tag_text_field.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MentionTagTextFieldExample(),
    );
  }
}

class MentionTagTextFieldExample extends StatefulWidget {
  const MentionTagTextFieldExample({
    super.key,
  });

  @override
  State<MentionTagTextFieldExample> createState() =>
      _MentionTagTextFieldExampleState();
}

class _MentionTagTextFieldExampleState
    extends State<MentionTagTextFieldExample> {
  final MentionTagTextEditingController<User> _controller =
      MentionTagTextEditingController<User>(
    toBackendConverter: (value) => value.id,
    // toFrontendConverter: (value) => users
    //     .firstWhere((element) => element.id == value,
    //         orElse: () => const User(id: '', displayName: ''))
    //     .displayName,
  );

  @override
  void initState() {
    super.initState();
    _controller.setText = "Hello @Stephen Hawking ";
  }

  String? mentionValue;
  List<User> searchResults = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'For Backend:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              SelectableText(
                _controller.getBackendText,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple),
              ),
              const Text(
                'For Frontend:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              MentionTagReply<User>(
                _controller.getBackendText,
                // toFrontendConverter: (value) => users
                //     .firstWhere((element) => element.id == value,
                //         orElse: () => const User(id: '', displayName: ''))
                //     .displayName,
                mentions: _controller.mentions
                    .map((e) => MentionTagElement(
                        mentionSymbol: "@", mention: e.displayName, data: e))
                    .toList(),
              ),
              // Text(
              //   _controller
              //       .forFrontEndFrombackendText(_controller.getBackendText),
              //   style: const TextStyle(
              //       fontSize: 20,
              //       fontWeight: FontWeight.bold,
              //       color: Colors.deepPurple),
              // ),
              if (mentionValue != null)
                suggestions()
              else
                const Expanded(child: SizedBox()),
              const SizedBox(
                height: 16,
              ),
              mentionField(),
            ],
          ),
        ),
      ),
    );
  }

  MentionTagTextField mentionField() {
    final border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none);
    return MentionTagTextField<User>(
      keyboardType: TextInputType.multiline,
      minLines: 1,
      maxLines: 5,
      controller: _controller,
      initialMentions: const [
        (
          "@Stephen Hawking",
          User(
              id: '8d8289c9-50fd-45c7-9a26-cd3c535693ad',
              displayName: 'Stephen Hawking'),
          null,
        ),
      ],
      onMention: onMention,
      mentionTagDecoration: MentionTagDecoration(
        mentionStart: ['@'],
        mentionBreak: ' ',
        allowDecrement: true,
        allowEmbedding: false,
        showMentionStartSymbol: false,
        maxWords: null,
        mentionTextStyle: TextStyle(
          color: Colors.blue,
          backgroundColor: Colors.blue.shade50,
        ),
      ),
      decoration: InputDecoration(
        hintText: 'Write something...',
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: border,
        focusedBorder: border,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
    );
  }

  Widget suggestions() {
    // setState(() {});
    if (searchResults.isEmpty) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Flexible(
        fit: FlexFit.loose,
        child: ListView.builder(
            itemCount: searchResults.length,
            reverse: true,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  _controller.addMention(
                    label: searchResults[index].displayName,
                    data: User(
                        id: searchResults[index].id,
                        displayName: searchResults[index].displayName),
                    stylingWidget: MyCustomTag(
                      controller: _controller,
                      text: searchResults[index].displayName,
                      matchingLogic: (element) =>
                          element.id == searchResults[index].id,
                    ),
                  );
                  mentionValue = null;
                  setState(() {});
                },
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                        searchResults[index].displayName[0].substring(0, 1)),
                  ),
                  title: Text(
                    searchResults[index].displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    searchResults[index].id,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ),
              );
            }));
  }

  Future<void> onMention(String? value) async {
    mentionValue = value;
    // searchResults.clear();
    // setState(() {});
    if (value == null) return;
    final searchInput = mentionValue!.substring(1);
    // searchResults = [];

    searchResults = users
        .where((element) => element.displayName
            .toLowerCase()
            .contains(searchInput.toLowerCase()))
        .toList();
    setState(() {});
  }

  Future<List?> fetchSuggestionsFromServer(String input) async {
    try {
      final response = await http
          .get(Uri.parse('http://dummyjson.com/users/search?q=$input'));
      return jsonDecode(response.body)['users'];
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }
}

class MyCustomTag<T> extends StatelessWidget {
  const MyCustomTag({
    super.key,
    required this.controller,
    required this.text,
    required this.matchingLogic,
  });

  final MentionTagTextEditingController<T> controller;
  final String text;

  final bool Function(T) matchingLogic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
          color: Colors.yellow.shade50,
          borderRadius: const BorderRadius.all(Radius.circular(50))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text,
              style: TextStyle(
                color: Colors.yellow.shade700,
              )),
          const SizedBox(
            width: 6.0,
          ),
          GestureDetector(
            onTap: () {
              final index = controller.mentions.indexWhere((element) {
                return matchingLogic(element);
              });
              controller.remove(index: index);
              print(controller.text);
            },
            child: Icon(
              Icons.close,
              size: 12,
              color: Colors.yellow.shade700,
            ),
          )
        ],
      ),
    );
  }
}

class User {
  final String id;
  final String displayName;
  final String? imageUri;
  const User({
    required this.id,
    required this.displayName,
    this.imageUri,
  });
}

// / A list of users to search from.
const users = <User>[
  User(id: '94c1f2fd-764b-4660-8c52-1d86271e338f', displayName: 'Alice'),
  User(
    id: 'ac4b9617-bf4f-4e02-b371-4a203c92f805',
    displayName: 'Alice',
  ),
  User(id: '393760a7-b688-468c-a9bb-7d4718730b6b', displayName: 'Bob'),
  User(id: '40a5c0fc-2d10-4b60-a973-bf82e5d25801', displayName: 'Charlie'),
  User(id: '7e6acb06-e6a8-4867-b5f3-2016227ceb2c', displayName: 'Carol'),
  User(
      id: '8d8289c9-50fd-45c7-9a26-cd3c535693ad',
      displayName: 'Stephen Hawking'),
];
