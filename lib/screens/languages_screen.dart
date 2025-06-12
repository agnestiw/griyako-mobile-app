import 'package:flutter/material.dart';

// Enum to represent the available languages
enum Language { english, indonesian }

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  // State variable to hold the currently selected language.
  // Default to English.
  Language _selectedLanguage = Language.english;

  // Method to build a list tile for a language option
  Widget _buildLanguageTile(
      String title, String subtitle, Language value) {
    return RadioListTile<Language>(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      groupValue: _selectedLanguage,
      onChanged: (Language? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedLanguage = newValue;
            // --- Placeholder for your language change logic ---
            // In a real app, you would call your localization/state
            // management service here to change the app's language.
            // For example:
            //   LocaleService.of(context).setLocale(newValue == Language.english ? 'en' : 'id');
            print('Selected language: $newValue');

            // Optionally, show a confirmation snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$title selected'),
                duration: const Duration(seconds: 1),
              ),
            );
          });
        }
      },
      activeColor: Theme.of(context).primaryColor,
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Text(
              'Suggested Languages',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              children: [
                _buildLanguageTile(
                  'English',
                  'English',
                  Language.english,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildLanguageTile(
                  'Indonesian',
                  'Bahasa Indonesia',
                  Language.indonesian,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
