import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ruz_timetable/screens/group_selection_screen.dart';
import 'package:ruz_timetable/screens/filters_screen.dart';
import 'package:ruz_timetable/services/api_config_service.dart';
import 'package:ruz_timetable/services/settings_service.dart';
import 'package:ruz_timetable/services/language_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key, 
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
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        bottom: TabBar(
          controller: _tabController,
          tabs: <Tab>[
            Tab(text: l10n.groupSelection, icon: const Icon(Icons.person)),
            Tab(text: l10n.filters, icon: const Icon(Icons.tune)),
            Tab(text: l10n.settings, icon: const Icon(Icons.settings)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          GroupSelectionScreen(
            selectedEntity: widget.selectedEntity,
            onSelectedEntityChanged: widget.onSelectedEntityChanged,
          ),
          const FiltersScreen(),
          _GeneralSettingsTab(
            themeMode: widget.themeMode,
            onThemeModeChanged: widget.onThemeModeChanged,
            locale: widget.locale,
            onLocaleChanged: widget.onLocaleChanged,
          ),
        ],
      ),
    );
  }
}

class _GeneralSettingsTab extends StatefulWidget {
  const _GeneralSettingsTab({
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.locale,
    required this.onLocaleChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  State<_GeneralSettingsTab> createState() => _GeneralSettingsTabState();
}

class _GeneralSettingsTabState extends State<_GeneralSettingsTab> {
  final TextEditingController _apiEndpointController = TextEditingController();
  bool _isUsingCustomEndpoint = false;

  @override
  void initState() {
    super.initState();
    _loadApiEndpoint();
  }

  @override
  void dispose() {
    _apiEndpointController.dispose();
    super.dispose();
  }

  Future<void> _loadApiEndpoint() async {
    final endpoint = await ApiConfigService.getApiEndpoint();
    final isCustom = await ApiConfigService.isUsingCustomEndpoint();
    
    setState(() {
      _isUsingCustomEndpoint = isCustom;
      _apiEndpointController.text = endpoint;
    });
  }

  Future<void> _saveApiEndpoint() async {
    final newEndpoint = _apiEndpointController.text.trim();
    if (newEndpoint.isEmpty) {
      return;
    }

    try {
      await ApiConfigService.setApiEndpoint(newEndpoint);
      await _loadApiEndpoint();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ API endpoint saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to save endpoint: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _resetToDefault() async {
    await ApiConfigService.resetToDefault();
    await _loadApiEndpoint();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Reset to default endpoint'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: <Widget>[
        // Theme Setting
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: SegmentedButton<ThemeMode>(
              key: ValueKey<ThemeMode>(widget.themeMode),
              segments: <ButtonSegment<ThemeMode>>[
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.light, 
                  label: Text(l10n.lightTheme, textAlign: TextAlign.center),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.system, 
                  label: Text(l10n.systemTheme, textAlign: TextAlign.center),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.dark, 
                  label: Text(l10n.darkTheme, textAlign: TextAlign.center),
                ),
              ],
              selected: <ThemeMode>{widget.themeMode},
              multiSelectionEnabled: false,
              onSelectionChanged: (Set<ThemeMode> selection) {
                if (selection.isNotEmpty) {
                  widget.onThemeModeChanged(selection.first);
                }
              },
            ),
          ),
        ),
        
        const Divider(),
        
        // Language Setting
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(l10n.language),
          trailing: DropdownButton<Locale>(
            value: LanguageService.supportedLocales.firstWhere(
              (locale) => locale.languageCode == widget.locale.languageCode,
              orElse: () => LanguageService.supportedLocales.first,
            ),
            onChanged: (Locale? newLocale) {
              if (newLocale != null) {
                widget.onLocaleChanged(newLocale);
              }
            },
            items: LanguageService.supportedLocales.map((Locale locale) {
              return DropdownMenuItem<Locale>(
                value: locale,
                child: Text(LanguageService.getLanguageDisplayName(locale)),
              );
            }).toList(),
          ),
        ),
        
        const Divider(),
        
        // Custom API Endpoint
        ListTile(
          leading: const Icon(Icons.api),
          title: Text(l10n.apiEndpoint),
          subtitle: Text(_isUsingCustomEndpoint ? 'Using custom endpoint' : 'Using default endpoint'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _apiEndpointController,
            decoration: InputDecoration(
              labelText: l10n.apiEndpoint,
              hintText: l10n.enterApiEndpoint,
              border: const OutlineInputBorder(),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isUsingCustomEndpoint)
                    IconButton(
                      icon: const Icon(Icons.restore),
                      onPressed: _resetToDefault,
                      tooltip: 'Reset to default',
                    ),
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: _saveApiEndpoint,
                    tooltip: l10n.save,
                  ),
                ],
              ),
            ),
            onSubmitted: (_) => _saveApiEndpoint(),
          ),
        ),
        
        const Divider(),
        
        // About Section
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(l10n.about),
          subtitle: Text('RUZ++ v1.2.1'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.madeByTeam,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.link, size: 18, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => _launchUrl('https://drewnja.xyz'),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                        child: Text(
                          'drewnja.xyz',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () => _launchUrl('https://wki7.ru'),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                        child: Text(
                          'wki7.ru',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


