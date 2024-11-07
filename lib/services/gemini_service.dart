import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String apiKey = 'AIzaSyAr-Y2j4EDzhAs0qFrto47owTtuRQTwKGE';
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
    );
  }

  Future<List<String>> generateGuideQuestions(Map<String, dynamic>? travelData) async {
    try {
      final prompt = '''
Based on this travel context:
${travelData != null ? travelData.entries.map((entry) => '- ${entry.key}: ${entry.value}').join('\n') : '- No travel data provided'}
Generate 5 short, engaging questions that users might want to ask about local food and dining. Make questions specific to the given context.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null) {
        return _getDefaultQuestions();
      }

      final questions = response.text!.split('\n').where((line) => line.trim().isNotEmpty).take(5).toList();

      return questions.isEmpty ? _getDefaultQuestions() : questions;
    } catch (e) {
      print('Error generating questions: $e');
      return _getDefaultQuestions();
    }
  }

  List<String> _getDefaultQuestions() {
    return [
      "What are the must-try local dishes?",
      "Which restaurants do you recommend?",
      "Where should I eat after arrival?",
      "Can you plan a food tour?",
      "What's the best area for dining?",
    ];
  }

  Future<String> getChatResponse(String prompt, {Map<String, dynamic>? travelData}) async {
    try {
      final contextPrompt = '''
Travel Context:
${travelData != null ? travelData.entries.map((entry) => '- ${entry.key}: ${entry.value}').join('\n') : '- No travel data provided'}

User Query: $prompt

Please provide a helpful response about food and dining options. Use markdown formatting for better readability:
- Use **bold** for important points
- Use *italic* for emphasis
- Use bullet points for lists
- Use ### for subheadings
''';

      final content = [Content.text(contextPrompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'I apologize, but I could not generate a response.';
    } catch (e) {
      print('Error getting chat response: $e');
      return '''
**Error Processing Request**

I apologize, but there was an error processing your request. Please try again later.

*Error details:* ${e.toString()}
''';
    }
  }
}
