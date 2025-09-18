import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ruz_timetable/screens/timetable_screen.dart';
import 'package:ruz_timetable/screens/settings_screen.dart';
import 'package:ruz_timetable/services/settings_service.dart';
import 'package:ruz_timetable/services/language_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  Locale _locale = const Locale('en', '');

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    developer.log('🚀 App starting - loading initial settings');
    final themeMode = await SettingsService.getThemeMode();
    final selectedEntity = await SettingsService.getSelectedEntity();
    final locale = await LanguageService.getSavedLanguage();
    
    developer.log('🚀 Initial settings loaded - Theme: $themeMode, Entity: ${selectedEntity?.name ?? 'None'}, Locale: ${locale.languageCode}');
    
    setState(() {
      _themeMode = themeMode;
      _selectedEntity = selectedEntity;
      _locale = locale;
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

  void _setLocale(Locale locale) {
    developer.log('🌍 Language changed from ${_locale.languageCode} to ${locale.languageCode}');
    setState(() {
      _locale = locale;
    });
    LanguageService.saveLanguage(locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RUZ Timetable',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LanguageService.supportedLocales,
      locale: _locale,
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
          locale: _locale,
          onLocaleChanged: _setLocale,
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
    required this.locale,
    required this.onLocaleChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final SelectedEntity? selectedEntity;
  final ValueChanged<SelectedEntity?> onSelectedEntityChanged;
  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  State<_RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<_RootScaffold> {
  int _currentIndex = 0;
  late PageController _pageController;

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
    final l10n = AppLocalizations.of(context)!;
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
              selectedEntityName: widget.selectedEntity?.name ?? l10n.noGroupSelected,
              selectedEntity: widget.selectedEntity,
              onNavigateToSettings: () {
                _pageController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
                        SettingsScreen(
                          themeMode: widget.themeMode,
                          onThemeModeChanged: widget.onThemeModeChanged,
                          selectedEntity: widget.selectedEntity,
                          onSelectedEntityChanged: widget.onSelectedEntityChanged,
                          locale: widget.locale,
                          onLocaleChanged: widget.onLocaleChanged,
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
            destinations: <NavigationDestination>[
              NavigationDestination(icon: const Icon(Icons.calendar_today), label: l10n.timetable),
              NavigationDestination(icon: const Icon(Icons.settings), label: l10n.settings),
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
