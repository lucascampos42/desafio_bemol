import 'package:flutter/material.dart';
import '../../core/utils/constants.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final bool isSearching;
  final VoidCallback onClear;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.isSearching,
    required this.onClear,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search Products...',
            prefixIcon: GestureDetector(
              onTap: () {
                _focusNode.requestFocus();
              },
              child: const Icon(Icons.search, color: Color.fromARGB(255, 56, 56, 56)),
            ),
            suffixIcon: widget.isSearching
                ? IconButton(
                    onPressed: widget.onClear,
                    icon: const Icon(Icons.clear),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
              vertical: AppConstants.defaultPadding,
            ),
          ),
        ),
      ),
    );
  }
}