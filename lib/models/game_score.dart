import 'package:flutter/foundation.dart';

/// STATE MANAGEMENT EKSEMPEL
/// 
/// Denne klasse demonstrerer simpel state management med ChangeNotifier.
/// ChangeNotifier er en del af Flutter framework og kan bruges til at dele state
/// mellem widgets uden at man skal passere data gennem konstruktører hele tiden.
/// 
/// I denne app bruges det til at holde styr på spilstatistikker (scores).
/// 
/// ALTERNATIVER:
/// - setState() - For lokal state i en StatefulWidget (bruges i WordlePage)
/// - Provider package - For global state management (kræver ekstra dependency)
/// - Riverpod / Bloc - For mere kompleks state management
class GameScore extends ChangeNotifier {
  int wordleWins = 0;
  int hangmanWins = 0;
  int totalGames = 0;

  /// Incrementer Wordle vind
  void incrementWordleWin() {
    wordleWins++;
    totalGames++;
    // notifyListeners() fortæller alle widgets der lytter til at de skal opdatere sig
    notifyListeners();
    debugPrint('Wordle vind talt op: $wordleWins (Total: $totalGames)');
  }

  /// Incrementer Hangman vind
  void incrementHangmanWin() {
    hangmanWins++;
    totalGames++;
    notifyListeners();
    debugPrint('Hangman vind talt op: $hangmanWins (Total: $totalGames)');
  }

  /// Nulstil alle scores
  void reset() {
    wordleWins = 0;
    hangmanWins = 0;
    totalGames = 0;
    notifyListeners();
    debugPrint('Alle scores nulstillet');
  }
}
