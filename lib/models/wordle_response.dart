class WordleResponse {
  final List<String> wordlist;

  WordleResponse({required this.wordlist});

  factory WordleResponse.fromJson(Map<String, dynamic> json) {
    return WordleResponse(
      wordlist: List<String>.from(json['wordlist'] as List),
    );
  }
}
