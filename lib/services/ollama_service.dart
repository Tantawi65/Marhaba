import 'dart:convert';
import 'package:http/http.dart' as http;

class OllamaService {
  static const String _baseUrl = 'http://localhost:11434';
  static const String _model = 'gemma:2b'; // Using Gemma 2B model
  
  /// Initialize the service and check if Ollama is running
  static Future<bool> isOllamaRunning() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/tags'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Ollama connection error: $e');
      return false;
    }
  }
  
  /// Send a message to Gemma 3 and get response
  static Future<String> sendMessage(String message) async {
    try {
      // First, try to get the best available Gemma model
      final availableModel = await getAvailableGemmaModel();
      if (availableModel == null) {
        return 'Gemma model is not available. Please install it using: ollama pull gemma:2b';
      }

      // Create the system prompt for Marhaba assistant (optimized for offline use)
      final systemPrompt = '''
You are Marhaba, a helpful offline assistant for refugees, migrants, and displaced people. 
You help them navigate life in a new country. You should:

1. Be empathetic and understanding
2. Provide practical, actionable advice
3. Keep responses concise but helpful (under 200 words)
4. Focus on essential services like healthcare, education, housing, legal rights
5. Be supportive and encouraging
6. Provide general guidance that applies broadly, since you're running offline
7. Suggest local resources they should look for in their area

Always respond in a warm, helpful tone. The user's question is: $message
''';

      final requestBody = {
        'model': availableModel, // Use the dynamically detected model
        'prompt': systemPrompt,
        'stream': false,
        'options': {
          'temperature': 0.7,
          'top_p': 0.9,
          'max_tokens': 250, // Reduced for faster offline processing
          'num_ctx': 2048, // Reduced context for better offline performance
        }
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 45)); // Increased timeout for offline processing

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['response'] ?? 'Sorry, I couldn\'t process that request.';
      } else {
        print('Ollama API error: ${response.statusCode} - ${response.body}');
        return 'I\'m having trouble processing your request. Please try again.';
      }
    } catch (e) {
      print('Error sending message to Ollama: $e');
      return 'I\'m currently having trouble processing your request. Please ensure Ollama is running and the Gemma model is installed (ollama pull gemma:2b).';
    }
  }
  
  /// Check if Gemma model is available
  static Future<bool> isModelAvailable() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/tags'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final models = jsonResponse['models'] as List;
        
        // Check for exact model name first, then fallbacks
        return models.any((model) {
          final modelName = model['name'].toString().toLowerCase();
          return modelName == 'gemma:2b' ||
                 modelName.contains('gemma:2b') ||
                 modelName.contains('gemma3:latest') ||
                 modelName.contains('gemma3') ||
                 modelName.contains('gemma2:3b') ||
                 modelName.contains('gemma:3b') ||
                 modelName.contains('gemma2') ||
                 modelName.contains('gemma');
        });
      }
      return false;
    } catch (e) {
      print('Error checking model availability: $e');
      return false;
    }
  }

  /// Get the first available Gemma model
  static Future<String?> getAvailableGemmaModel() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/tags'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final models = jsonResponse['models'] as List;
        
        // Priority order: gemma:2b, gemma3:latest, gemma2:3b, gemma2:2b, gemma:3b, any gemma
        final priorities = ['gemma:2b', 'gemma3:latest', 'gemma2:3b', 'gemma2:2b', 'gemma:3b'];
        
        for (final priority in priorities) {
          final found = models.firstWhere(
            (model) => model['name'].toString().toLowerCase() == priority,
            orElse: () => null,
          );
          if (found != null) {
            return found['name'].toString();
          }
        }
        
        // Fallback: any model containing "gemma"
        final anyGemma = models.firstWhere(
          (model) => model['name'].toString().toLowerCase().contains('gemma'),
          orElse: () => null,
        );
        
        return anyGemma?['name']?.toString();
      }
      return null;
    } catch (e) {
      print('Error getting available Gemma model: $e');
      return null;
    }
  }

  /// Pull Gemma model if not available
  static Future<bool> pullModel() async {
    try {
      final requestBody = {
        'name': _model,
        'stream': false
      };
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/pull'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(minutes: 30)); // Long timeout for model download
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error pulling model: $e');
      return false;
    }
  }
}
