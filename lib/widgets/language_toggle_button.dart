import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return FloatingActionButton(
          onPressed: () => languageProvider.toggleLanguage(),
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            languageProvider.isEnglish ? 'RU' : 'EN',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
} 