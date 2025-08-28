import 'package:flutter/material.dart';
import '../../core/utils/app_constants.dart';
import '../../core/utils/responsive_helper.dart';

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
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final maxWidth = isDesktop ? 600.0 : double.infinity;
    
    return ResponsiveContainer(
      padding: ResponsiveHelper.getResponsivePadding(context),
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxWidth: maxWidth),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(20, 108, 108, 108),
                spreadRadius: 0,
                blurRadius: isDesktop ? 12 : 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: TextField(
            key: const Key('search_field'),
            controller: widget.controller,
            focusNode: _focusNode,
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
            ),
            decoration: InputDecoration(
              hintText: isDesktop ? 'Search products by name, category...' : 'Search Products...',
              hintStyle: TextStyle(
                fontSize: isDesktop ? 16 : 14,
                color: Colors.grey[600],
              ),
              prefixIcon: GestureDetector(
                onTap: () {
                  _focusNode.requestFocus();
                },
                child: Icon(
                  Icons.search, 
                  color: const Color.fromARGB(255, 56, 56, 56),
                  size: isDesktop ? 24 : 20,
                ),
              ),
              suffixIcon: widget.isSearching
                  ? IconButton(
                      onPressed: widget.onClear,
                      icon: Icon(
                        Icons.clear,
                        size: isDesktop ? 24 : 20,
                      ),
                      tooltip: 'Clear search',
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 20 : AppConstants.defaultPadding,
                vertical: isDesktop ? 18 : AppConstants.defaultPadding,
              ),
            ),
          ),
        ),
      ),
    );
  }
}