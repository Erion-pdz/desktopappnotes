import 'package:flutter/material.dart';

class TagSelector extends StatelessWidget {
  final List<String> tags;
  final void Function(String) onSelected;

  const TagSelector({super.key, required this.tags, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: tags.map((tag) {
        return ActionChip(
          label: Text(tag),
          onPressed: () => onSelected(tag),
        );
      }).toList(),
    );
  }
}
