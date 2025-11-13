import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const SettingsScreen({super.key, required this.toggleTheme, required this.isDarkMode});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _scanSound = true;
  bool _autoOpenLinks = false;
  String _themeSelection = 'System';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _scanSound = prefs.getBool('scanSound') ?? true;
      _autoOpenLinks = prefs.getBool('autoOpenLinks') ?? false;
      _themeSelection = prefs.getString('themeSelection') ?? 'System';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Scan Sound'),
            subtitle: const Text('Play sound on successful scan'),
            value: _scanSound,
            onChanged: (value) {
              setState(() => _scanSound = value);
              _saveSetting('scanSound', value);
            },
          ),
          SwitchListTile(
            title: const Text('Auto-Open Links'),
            subtitle: const Text('Automatically open URLs when scanned'),
            value: _autoOpenLinks,
            onChanged: (value) {
              setState(() => _autoOpenLinks = value);
              _saveSetting('autoOpenLinks', value);
            },
          ),
          ListTile(
            title: const Text('Theme Selection'),
            subtitle: Text(_themeSelection),
            trailing: DropdownButton<String>(
              value: _themeSelection,
              items: const [
                DropdownMenuItem(value: 'Light', child: Text('Light')),
                DropdownMenuItem(value: 'Dark', child: Text('Dark')),
                DropdownMenuItem(value: 'System', child: Text('System')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _themeSelection = value);
                  _saveSetting('themeSelection', value);
                  // Note: Actual theme switching would need to be handled at app level
                }
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Data Export'),
            subtitle: const Text('Export employees data as CSV'),
            trailing: const Icon(Icons.download),
            onTap: () {
              // TODO: Implement CSV export
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('CSV export not yet implemented')),
              );
            },
          ),
        ],
      ),
    );
  }
}
