import 'package:flutter_tts/flutter_tts.dart';

/// Reads questions aloud with the phone's text-to-speech voice.
class Speech {
  Speech._();
  static final instance = Speech._();

  static const _locales = {
    'en': 'en-US',
    'vi': 'vi-VN',
    'es': 'es-US',
    'de': 'de-DE',
    'ro': 'ro-RO',
    'pl': 'pl-PL',
  };

  final _tts = FlutterTts();

  /// Speaks [text] in [lang]. Returns false when the phone has no voice for
  /// that language (or no speech engine at all).
  Future<bool> speak(String text, String lang) async {
    try {
      final locale = _locales[lang] ?? lang;
      if (await _tts.isLanguageAvailable(locale) != true) return false;
      await _tts.stop();
      await _tts.setLanguage(locale);
      await _tts.setSpeechRate(0.45);
      await _tts.speak(text);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
