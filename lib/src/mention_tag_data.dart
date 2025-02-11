import 'package:flutter/material.dart';

@immutable
class MentionTagElement<T> {
  final String mentionSymbol;
  final String mention;
  final T data;
  final Widget? stylingWidget;
  const MentionTagElement({
    required this.mentionSymbol,
    required this.mention,
    required this.data,
    this.stylingWidget,
  });
}
