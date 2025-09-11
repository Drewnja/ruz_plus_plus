import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:ruz_timetable/screens/timetable_screen.dart';
import 'package:ruz_timetable/screens/settings_screen.dart';
import 'package:ruz_timetable/services/settings_service.dart';

void main() {
  runApp(const RuzTimetableApp());
}

class RuzTimetableApp extends StatefulWidget {
  const RuzTimetableApp({super.key});

  @override
  State<RuzTimetableApp> createState() => _RuzTimetableAppState();
}

class _RuzTimetableAppState extends State<RuzTimetableApp> {
  ThemeMode _themeMode = ThemeMode.system;
  SelectedEntity? _selectedEntity;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    developer.log('🚀 App starting - loading initial settings');
    final themeMode = await SettingsService.getThemeMode();
    final selectedEntity = await SettingsService.getSelectedEntity();
    
    developer.log('🚀 Initial settings loaded - Theme: $themeMode, Entity: ${selectedEntity?.name ?? 'None'}');
    
    setState(() {
      _themeMode = themeMode;
      _selectedEntity = selectedEntity;
    });
  }

  void _setThemeMode(ThemeMode mode) {
    developer.log('🎨 Theme mode changed from $_themeMode to $mode');
    setState(() {
      _themeMode = mode;
    });
    SettingsService.setThemeMode(mode);
  }

  void _setSelectedEntity(SelectedEntity? entity) {
    developer.log('👥 Selected entity changed from "${_selectedEntity?.name ?? 'None'}" to "${entity?.name ?? 'None'}"');
    setState(() {
      _selectedEntity = entity;
    });
    if (entity != null) {
      SettingsService.setSelectedEntity(entity);
    } else {
      SettingsService.clearSelectedEntity();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RUZ Timetable',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF03DAC6)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF03DAC6),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
        home: _RootScaffold(
          themeMode: _themeMode,
          onThemeModeChanged: _setThemeMode,
          selectedEntity: _selectedEntity,
          onSelectedEntityChanged: _setSelectedEntity,
        ),
    );
  }
}

class _RootScaffold extends StatefulWidget {
  const _RootScaffold({
    required this.themeMode, 
    required this.onThemeModeChanged,
    required this.selectedEntity,
    required this.onSelectedEntityChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final SelectedEntity? selectedEntity;
  final ValueChanged<SelectedEntity?> onSelectedEntityChanged;

  @override
  State<_RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<_RootScaffold> {
  int _currentIndex = 0;
  late PageController _pageController;

  String get _selectedEntityName => widget.selectedEntity?.name ?? 'No Group Selected';

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: PageView(
          controller: _pageController,
          onPageChanged: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: <Widget>[
            TimetableScreen(
              selectedEntityName: _selectedEntityName,
            ),
                        SettingsScreen(
                          themeMode: widget.themeMode,
                          onThemeModeChanged: widget.onThemeModeChanged,
                          selectedEntity: widget.selectedEntity,
                          onSelectedEntityChanged: widget.onSelectedEntityChanged,
                        ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: NavigationBar(
            selectedIndex: _currentIndex,
            destinations: const <NavigationDestination>[
              NavigationDestination(icon: Icon(Icons.calendar_today), label: 'Timetable'),
              NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
            ],
            onDestinationSelected: (int index) {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            animationDuration: const Duration(milliseconds: 300),
          ),
        ),
      ),
    );
  }
}

// Screens and widgets are defined in their own files under lib/screens and lib/widgets
