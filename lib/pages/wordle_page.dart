import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/letter_status.dart';
import '../services/wordle_service.dart';
import '../services/keyboard_input_service.dart';

class WordlePage extends StatefulWidget {
  const WordlePage({super.key});

  @override
  State<WordlePage> createState() => _WordlePageState();
}

class _WordlePageState extends State<WordlePage> {
  final WordleService _wordleService = WordleService();
  final KeyboardInputService _keyboardService = KeyboardInputService();
  final int wordLength = 5;
  final int maxGuesses = 6;
  final FocusNode _focusNode = FocusNode();
  
  List<String> _wordList = [];
  String _targetWord = '';
  List<List<Letter>> _guesses = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _gameWon = false;
  bool _gameOver = false;
  bool _showTargetWord = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    // Sæt fokus når siden er klar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _initializeGame() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _wordList = await _wordleService.fetchWordList();
      if (_wordList.isEmpty) {
        throw Exception('Ordlisten er tom');
      }
      
      // Vælg et tilfældigt ord fra listen
      final random = Random();
      _targetWord = _wordList[random.nextInt(_wordList.length)];
      
      // Initialiser gæt
      _guesses = List.generate(
        maxGuesses,
        (_) => List.generate(wordLength, (_) => Letter(character: '', status: LetterStatus.empty)),
      );
      
      _gameWon = false;
      _gameOver = false;
    } catch (e) {
      setState(() {
        _errorMessage = 'Fejl ved indlæsning: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onKeyPressed(String key) {
    if (_gameWon || _gameOver) return;
    
    final currentGuessIndex = _getCurrentGuessIndex();
    if (currentGuessIndex == -1) return;

    if (key == 'ENTER') {
      _submitGuess();
    } else if (key == 'BACKSPACE') {
      _handleBackspace(currentGuessIndex);
    } else {
      _handleLetterInput(key.toLowerCase(), currentGuessIndex);
    }
  }

  void _handleLetterInput(String key, int rowIndex) {
    final emptyIndex = _guesses[rowIndex]
        .indexWhere((letter) => letter.character.isEmpty);
    
    if (emptyIndex != -1 && _isValidLetter(key)) {
      setState(() {
        _guesses[rowIndex][emptyIndex] = Letter(
          character: key,
          status: LetterStatus.empty,
        );
      });
    }
  }

  void _handleBackspace(int rowIndex) {
    final lastFilledIndex = _guesses[rowIndex]
        .lastIndexWhere((letter) => letter.character.isNotEmpty);
    
    if (lastFilledIndex != -1) {
      setState(() {
        _guesses[rowIndex][lastFilledIndex] = Letter(
          character: '',
          status: LetterStatus.empty,
        );
      });
    }
  }

  bool _isValidLetter(String key) {
    // DRY PRINCIP: Bruger nu KeyboardInputService i stedet for duplikeret logik
    return _keyboardService.isValidLetter(key);
  }

  int _getCurrentGuessIndex() {
    // Find den første række hvor alle felter stadig har status empty
    // (dvs. rækken er ikke blevet evalueret endnu)
    return _guesses.indexWhere(
      (guess) => guess.every((letter) => letter.status == LetterStatus.empty),
    );
  }

  String _getCurrentGuess(int rowIndex) {
    return _guesses[rowIndex]
        .where((letter) => letter.character.isNotEmpty)
        .map((letter) => letter.character)
        .join();
  }

  void _submitGuess() {
    final currentGuessIndex = _getCurrentGuessIndex();
    if (currentGuessIndex == -1) return;

    final currentGuess = _getCurrentGuess(currentGuessIndex);
    if (currentGuess.length != wordLength) return;

    // Tjek om ordet er gyldigt
    if (!_wordleService.isWordValid(currentGuess, _wordList)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dette ord findes ikke i ordlisten'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Evaluer gættet
    final evaluation = _wordleService.evaluateGuess(currentGuess, _targetWord);
    final newGuess = List.generate(
      wordLength,
      (i) => Letter(
        character: currentGuess[i],
        status: evaluation[i],
      ),
    );

    setState(() {
      _guesses[currentGuessIndex] = newGuess;
    });

    // Tjek om spillet er vundet
    if (evaluation.every((status) => status == LetterStatus.correct)) {
      setState(() {
        _gameWon = true;
        _gameOver = true;
      });
      _showGameOverDialog(won: true);
    } else if (currentGuessIndex == maxGuesses - 1) {
      setState(() {
        _gameOver = true;
      });
      _showGameOverDialog(won: false);
    }
  }

  void _showGameOverDialog({required bool won}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(won ? 'Tillykke!' : 'Spillet er slut'),
        content: Text(won
            ? 'Du gættede ordet korrekt!'
            : 'Det rigtige ord var: $_targetWord'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeGame();
            },
            child: const Text('Prøv igen'),
          ),
        ],
      ),
    );
  }

  Color _getLetterColor(LetterStatus status) {
    switch (status) {
      case LetterStatus.correct:
        return Colors.green;
      case LetterStatus.present:
        return Colors.orange;
      case LetterStatus.absent:
        return Colors.grey;
      case LetterStatus.empty:
        return Colors.grey.shade300;
    }
  }

  LetterStatus? _getBestStatusForLetter(String letter) {
    LetterStatus? bestStatus;
    
    // Gennemgå alle evaluerede gæt (rækker hvor status ikke er empty)
    for (var guess in _guesses) {
      for (var l in guess) {
        if (l.character.toLowerCase() == letter.toLowerCase() && 
            l.status != LetterStatus.empty) {
          // Prioritér: correct > present > absent
          if (l.status == LetterStatus.correct) {
            return LetterStatus.correct;
          } else if (l.status == LetterStatus.present && 
                     bestStatus != LetterStatus.correct) {
            bestStatus = LetterStatus.present;
          } else if (l.status == LetterStatus.absent && 
                     bestStatus == null) {
            bestStatus = LetterStatus.absent;
          }
        }
      }
    }
    
    return bestStatus;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('WORDLE')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _initializeGame,
                child: const Text('Prøv igen'),
              ),
            ],
          ),
        ),
      );
    }

    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: (RawKeyEvent event) {
        // DRY PRINCIP: Bruger KeyboardInputService til at håndtere keyboard input
        // I stedet for at have keyboard logik direkte i widget'en, bruger vi nu en service
        // Dette gør koden mere genbrugelig og nemmere at vedligeholde
        _keyboardService.handleKeyEvent(
          event,
          onKeyPressed: _onKeyPressed,
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('WORDLE'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // ROUTING: Tilbage knap til menu
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              debugPrint('Navigerer tilbage til menu');
              Navigator.of(context).pop();
            },
          ),
          actions: [
            Row(
              children: [
                const Text('Vis ord'),
                Switch(
                  value: _showTargetWord,
                  onChanged: (value) {
                    // STATE MANAGEMENT EKSEMPEL: setState() opdaterer UI
                    // DEBUGGING: Log state ændring
                    debugPrint('Toggle vis ord: $value');
                    setState(() {
                      _showTargetWord = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            // Vis det valgte ord hvis toggle er aktiveret
            if (_showTargetWord)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                color: Colors.blue.shade100,
                child: Center(
                  child: Text(
                    'Det valgte ord: ${_targetWord.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            // Spilbræt
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < maxGuesses; i++) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var j = 0; j < wordLength; j++)
                              _buildLetterBox(_guesses[i][j], i),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // Keyboard
            _buildKeyboard(),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterBox(Letter letter, int rowIndex) {
    final currentRowIndex = _getCurrentGuessIndex();
    final isCurrentRow = currentRowIndex == rowIndex;
    final isEmpty = letter.status == LetterStatus.empty && letter.character.isEmpty;
    
    return Container(
      width: 50,
      height: 50,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isEmpty ? Colors.white : _getLetterColor(letter.status),
        border: Border.all(
          color: isCurrentRow && isEmpty
              ? Colors.blue
              : Colors.grey,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: letter.character.isEmpty
            ? null
            : Text(
                letter.character.toUpperCase(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isEmpty ? Colors.black : Colors.white,
                ),
              ),
      ),
    );
  }


  Widget _buildKeyboard() {
    final rows = [
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
      ['ENTER', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', 'BACKSPACE'],
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: rows.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((key) {
                final isSpecial = key == 'ENTER' || key == 'BACKSPACE';
                
                // Find status for dette bogstav (hvis det ikke er en special knap)
                Color? keyColor;
                Color? textColor = Colors.black;
                
                if (!isSpecial) {
                  final letterStatus = _getBestStatusForLetter(key);
                  if (letterStatus != null) {
                    keyColor = _getLetterColor(letterStatus);
                    // Hvis knappen har farve, skal teksten være hvid
                    if (letterStatus != LetterStatus.empty) {
                      textColor = Colors.white;
                    }
                  } else {
                    keyColor = Colors.grey.shade300;
                  }
                } else {
                  keyColor = Colors.grey.shade300;
                }
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: SizedBox(
                    width: isSpecial ? 70 : 32,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _onKeyPressed(key),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: keyColor,
                        foregroundColor: textColor,
                      ),
                      child: key == 'BACKSPACE'
                          ? const Icon(Icons.backspace)
                          : Text(
                              key,
                              style: TextStyle(
                                fontSize: 12,
                                color: textColor,
                              ),
                            ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}
