import 'package:flutter/services.dart';

/// KEYBOARD INPUT SERVICE - Demonstrerer DRY (Don't Repeat Yourself) princip
/// 
/// DENNE SERVICE:
/// - Centraliserer keyboard input håndtering
/// - Kan genbruges mellem Wordle og Hangman
/// - Gør det nemt at tilføje keyboard support til nye spil
/// 
/// DRY FORDELE:
/// 1. Én kilde til sandhed - keyboard logik er samlet ét sted
/// 2. Nem vedligeholdelse - ændringer skal kun laves ét sted
/// 3. Konsistent adfærd - alle spil håndterer keyboard ens
/// 4. Testbarhed - service kan testes isoleret
/// 5. Genbrugelighed - nye spil kan bruge samme service
class KeyboardInputService {
  /// Valider om et tastetryk er et gyldigt bogstav
  /// 
  /// UNDERSTØTTER:
  /// - Danske bogstaver (æ, ø, å)
  /// - Kun små bogstaver (a-z, æ, ø, å)
  bool isValidLetter(String key) {
    return key.length == 1 && key.contains(RegExp(r'[a-zæøå]'));
  }

  /// Konverter et RawKeyEvent til en normaliseret streng
  /// 
  /// RETURNERER:
  /// - 'ENTER' for Enter tast
  /// - 'BACKSPACE' for Backspace/Delete taster
  /// - Bogstav i uppercase (A-Z, Æ, Ø, Å)
  /// - null hvis tasten ikke er relevant
  String? processKeyEvent(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) {
      return null;
    }

    // Håndter Enter tast
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      return 'ENTER';
    }

    // Håndter Backspace/Delete taster
    if (event.logicalKey == LogicalKeyboardKey.backspace ||
        event.logicalKey == LogicalKeyboardKey.delete) {
      return 'BACKSPACE';
    }

    // Håndter bogstaver
    final keyLabel = event.logicalKey.keyLabel;
    if (keyLabel.length == 1) {
      final lowerKey = keyLabel.toLowerCase();
      if (isValidLetter(lowerKey)) {
        return keyLabel.toUpperCase();
      }
    }

    return null;
  }

  /// Håndter keyboard input med en callback
  /// 
  /// PARAMETRE:
  /// - event: RawKeyEvent fra Flutter
  /// - onKeyPressed: Callback der kaldes med normaliseret key streng
  /// 
  /// EKSEMPEL BRUG:
  /// ```dart
  /// KeyboardInputService().handleKeyEvent(
  ///   event,
  ///   onKeyPressed: (key) {
  ///     if (key == 'ENTER') {
  ///       submitGuess();
  ///     } else if (key == 'BACKSPACE') {
  ///       handleBackspace();
  ///     } else {
  ///       handleLetter(key);
  ///     }
  ///   },
  /// );
  /// ```
  void handleKeyEvent(
    RawKeyEvent event,
    {required Function(String) onKeyPressed}
  ) {
    final processedKey = processKeyEvent(event);
    if (processedKey != null) {
      onKeyPressed(processedKey);
    }
  }
}
