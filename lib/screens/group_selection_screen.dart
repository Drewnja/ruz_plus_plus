import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:ruz_timetable/services/api_service.dart';
import 'package:ruz_timetable/models/api_models.dart';
import 'package:ruz_timetable/services/settings_service.dart';
import 'package:ruz_timetable/widgets/skeleton_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GroupSelectionScreen extends StatefulWidget {
  const GroupSelectionScreen({
    super.key,
    required this.selectedEntity,
    required this.onSelectedEntityChanged,
  });

  final SelectedEntity? selectedEntity;
  final ValueChanged<SelectedEntity?> onSelectedEntityChanged;

  @override
  State<GroupSelectionScreen> createState() => _GroupSelectionScreenState();
}

class _GroupSelectionScreenState extends State<GroupSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<SearchResult> _searchResults = <SearchResult>[];
  bool _isSearching = false;
  String? _selectedId;
  String? _errorMessage;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.selectedEntity?.id;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    final query = _searchController.text.trim();
    developer.log('🔤 Search text changed: "$query"');
    
    if (query.isEmpty) {
      developer.log('🔤 Empty query, clearing results');
      setState(() {
        _searchResults.clear();
        _isSearching = false;
        _errorMessage = null;
      });
      return;
    }

    // Clear previous results but don't show loading yet
    setState(() {
      _errorMessage = null;
      // Keep existing results until new search completes
    });

    developer.log('⏱️ Setting up 3-second debounce timer for: "$query"');
    
    // Set up new timer for 3 second debounce
    _debounceTimer = Timer(const Duration(seconds: 1), () {
      developer.log('⏰ Debounce timer fired for: "$query", current text: "${_searchController.text.trim()}"');
      if (mounted && _searchController.text.trim() == query) {
        developer.log('🚀 Executing search for: "$query"');
        _performSearch(query);
      } else {
        developer.log('❌ Search cancelled - text changed or widget unmounted');
      }
    });
  }

  void _performSearch(String query) async {
    if (query.length < 3) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
        _errorMessage = 'Search string too short, minimum 3 characters';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final results = await ApiService.search(searchString: query);
      if (mounted) {
        setState(() {
          _searchResults.clear();
          _searchResults.addAll(results);
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults.clear();
          _isSearching = false;
          _errorMessage = 'Search failed: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: AppLocalizations.of(context)!.searchGroupsPersonsLecturersHint,
              border: const OutlineInputBorder(),
            ),
            // No onChanged - we use the controller listener for debounce
          ),
          const SizedBox(height: 16),
          if (_isSearching)
            Expanded(
              child: SkeletonWidgets.searchResultListSkeleton(),
            )
          else if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: <Widget>[
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else if (_searchResults.isEmpty && _searchController.text.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'No results found for "${_searchController.text}"',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else if (_searchResults.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: <Widget>[
                    Icon(
                      Icons.search,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.searchGroupsPersonsLecturers,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  final SearchResult result = _searchResults[index];
                  return _SearchResultTile(
                    result: result,
                    isSelected: _selectedId == result.id,
                    onTap: () {
                      setState(() {
                        _selectedId = result.id;
                      });
                      
                      // Convert SearchResult to SelectedEntity and save
                      final selectedEntity = SelectedEntity(
                        type: result.type,
                        id: result.id,
                        name: result.name,
                        description: result.description,
                      );
                      widget.onSelectedEntityChanged(selectedEntity);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Selected: ${result.name}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  );
                },
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemCount: _searchResults.length,
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.result,
    required this.isSelected,
    required this.onTap,
  });

  final SearchResult result;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;
    
    switch (result.type) {
      case 1: // group
        icon = Icons.group;
        iconColor = Theme.of(context).colorScheme.primary;
        break;
      case 2: // lecturer
        icon = Icons.school;
        iconColor = Theme.of(context).colorScheme.secondary;
        break;
      default:
        icon = Icons.help;
        iconColor = Theme.of(context).colorScheme.onSurfaceVariant;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: <Widget>[
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      result.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (result.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        result.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Radio<String>(
                value: result.id,
                groupValue: isSelected ? result.id : null,
                onChanged: (_) => onTap(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

