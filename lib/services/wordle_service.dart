import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wordle_response.dart';
import '../models/letter_status.dart';

class WordleService {
  // static const betyder at "baseUrl" er en konstant, og ikke kan ændres.
  // Hvis der i stedet stod "final", ville det betyde at variablen kun kan tildeles én gang (ligesom "readonly" i C#/JS), men værdien kan f.eks. konstrueres ud fra en beregning.
  // "const" betyder at værdien er kendt ved compile-time. "final" betyder kun at den ikke kan ændres efter tildeling, men værdien kan bestemmes ved runtime.
  static const String baseUrl = 'https://opgaver.mercantec.tech';

  // Future<List<String>> = Tilsvarer Promise<string[]> i JS eller Task<List<string>> i C#
  // async keyword virker ligesom i JS/C# - markerer at funktionen indeholder asynkrone operationer
  Future<List<String>> fetchWordList() async {
    try {
      // await http.get() = Tilsvarer fetch() i JS eller HttpClient.GetAsync() i C#
      // http.get() returnerer en Future<Response> (Promise<Response> i JS / Task<HttpResponseMessage> i C#)
      // 
      // Uri.parse() = Dart's måde at parse URLs. I JS bruger man bare en string direkte i fetch(),
      // i C# bruger man new Uri() eller HttpClient.BaseAddress
      final response = await http.get(
        Uri.parse('$baseUrl/Opgaver/Wordle'),
        // Headers = samme koncept som i fetch() (JS) eller HttpClient.DefaultRequestHeaders (C#)
        headers: {'accept': '*/*'},
      );

      // response.statusCode = tilsvarer response.status i JS eller response.StatusCode i C#
      if (response.statusCode == 200) {
        // json.decode() = Tilsvarer JSON.parse() i JS eller JsonSerializer.Deserialize() i C#
        // "as Map<String, dynamic>" = type casting. I JS er alt dynamic, i C# bruger man JsonElement eller generics
        // "dynamic" i Dart er ligesom "any" i TypeScript eller "object" i C#
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        
        // fromJson() = Tilsvarer en custom deserialiseringsmetode.
        // I JS ville man typisk bruge: new MyClass(responseJson)
        // I C#: JsonSerializer.Deserialize<MyClass>(jsonString)
        final wordleResponse = WordleResponse.fromJson(jsonData);
        return wordleResponse.wordlist;
      } else {
        // throw Exception = samme koncept som throw new Error() i JS eller throw new Exception() i C#
        throw Exception('Fejl ved hentning af ordliste: ${response.statusCode}');
      }
    } catch (e) {
      // catch blok virker ligesom i JS/C#, men i Dart kan man ikke specifikt fange forskellige exception typer
      // uden at tjekke runtime type (modsat C#'s catch (HttpException e))
      throw Exception('Fejl ved API kald: $e');
    }
  }

  bool isWordValid(String word, List<String> wordList) {
    return wordList.contains(word.toLowerCase());
  }

  List<LetterStatus> evaluateGuess(String guess, String target) {
    final guessLower = guess.toLowerCase();
    final targetLower = target.toLowerCase();
    final result = List<LetterStatus>.filled(guess.length, LetterStatus.absent);
    final targetLetterCounts = <String, int>{};

    // Tæl forekomster af hvert bogstav i target ordet
    for (var i = 0; i < targetLower.length; i++) {
      final char = targetLower[i];
      targetLetterCounts[char] = (targetLetterCounts[char] ?? 0) + 1;
    }

    // Først find korrekte positioner (grøn)
    for (var i = 0; i < guessLower.length && i < targetLower.length; i++) {
      if (guessLower[i] == targetLower[i]) {
        result[i] = LetterStatus.correct;
        targetLetterCounts[guessLower[i]] =
            (targetLetterCounts[guessLower[i]] ?? 0) - 1;
      }
    }

    // Derefter find bogstaver der findes men ikke på korrekt position (gul)
    for (var i = 0; i < guessLower.length && i < targetLower.length; i++) {
      if (result[i] != LetterStatus.correct) {
        final char = guessLower[i];
        if (targetLetterCounts.containsKey(char) &&
            targetLetterCounts[char]! > 0) {
          result[i] = LetterStatus.present;
          targetLetterCounts[char] = targetLetterCounts[char]! - 1;
        }
      }
    }

    return result;
  }
}
