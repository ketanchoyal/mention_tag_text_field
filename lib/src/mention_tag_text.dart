import 'package:flutter/material.dart';
import 'package:mention_tag_text_field/src/mention_tag_data.dart';

class MentionTagReply<T> extends StatelessWidget {
  const MentionTagReply(
    this.data, {
    super.key,
    // required this.toFrontendConverter,
    required this.mentions,
  });

  final String data;
  //If sequence of mentions is not in the same order as in the text then we have to use this or else we can use mentionText from MentionTagElement
  // final String Function(String mentionId) toFrontendConverter;
  final List<MentionTagElement<T>> mentions;

// example: "Hello @Stephen Hawking"
// returns: "[Hello, @8d8289c9-50fd-45c7-9a26-cd3c535693ad]" TextSpan
  TextSpan forFrontEndFrombackendTextSpan(String backendText) {
    final List<MentionTagElement<T>> tempList = List.from(mentions);
    RegExp mentionRegex = RegExp(
        r'@[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}');
    final List<TextSpan> textSpans = [];
    backendText.splitMapJoin(mentionRegex, onMatch: (match) {
      final MentionTagElement<T> removedMention = tempList.removeAt(0);
      // final frontendText =
      //     toFrontendConverter(match.group(0)!.replaceAll("@", ''));
      final String mention =
          "${removedMention.mentionSymbol}${removedMention.mention}";
      textSpans.add(TextSpan(
          text: mention,
          style: const TextStyle(
            color: Colors.blue,
          )));
      return '';
    }, onNonMatch: (nonMatch) {
      textSpans.add(TextSpan(text: nonMatch));
      return '';
    });
    return TextSpan(children: textSpans);
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(forFrontEndFrombackendTextSpan(data));
  }
}
