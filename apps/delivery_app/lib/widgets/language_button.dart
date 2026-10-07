import 'package:flutter/material.dart';
import '../api.dart';
import '../l10n.dart';
import '../locale_controller.dart';

List<(String, String)> kLanguages = [
  ('ar', 'arabic'),
  ('en', 'english'),
  ('fr', 'french'),
  ('es', 'spanish'),
];

class LanguageButton extends StatelessWidget {
  final LocaleController controller;
  final Api? api;
  const LanguageButton({super.key, required this.controller, this.api});

  String _label(String code, AppStrings t) => switch (code) {
        'ar' => t.arabic,
        'fr' => t.french,
        'es' => t.spanish,
        _ => t.english,
      };

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    return IconButton(
      tooltip: t.language,
      icon: const Icon(Icons.language),
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        builder: (sheetCtx) {
          final st = AppStrings.of(sheetCtx);
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(st.chooseLanguage, style: Theme.of(sheetCtx).textTheme.titleMedium),
                ),
                for (final (code, _) in kLanguages)
                  ListTile(
                    leading: Icon(
                      code == controller.code ? Icons.check_circle : Icons.circle_outlined,
                      color: code == controller.code ? const Color(0xFF2563EB) : Colors.grey,
                    ),
                    title: Text(_label(code, st)),
                    onTap: () {
                      controller.set(code);
                      api?.put('/profile', {'lang': code});
                      Navigator.of(sheetCtx).pop();
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}