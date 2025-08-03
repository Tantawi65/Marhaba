import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ollama_service.dart';

enum VoiceAssistantState {
  idle,
  listening,
  processing,
  speaking,
  error
}

class VoiceAssistantService extends ChangeNotifier {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  
  VoiceAssistantState _state = VoiceAssistantState.idle;
  String _lastWords = '';
  String _lastResponse = '';
  bool _isInitialized = false;
  bool _isOllamaAvailable = false;
  
  // Getters
  VoiceAssistantState get state => _state;
  String get lastWords => _lastWords;
  String get lastResponse => _lastResponse;
  bool get isInitialized => _isInitialized;
  bool get isOllamaAvailable => _isOllamaAvailable;
  
  VoiceAssistantService() {
    _initializeServices();
  }
  
  Future<void> _initializeServices() async {
    try {
      // Initialize speech recognition
      _speech = stt.SpeechToText();
      
      // Initialize text-to-speech
      _flutterTts = FlutterTts();
      await _configureTts();
      
      // Check permissions
      await _requestPermissions();
      
      // Check Ollama availability
      _isOllamaAvailable = await OllamaService.isOllamaRunning();
      if (_isOllamaAvailable) {
        _isOllamaAvailable = await OllamaService.isModelAvailable();
      }
      
      _isInitialized = true;
      notifyListeners();
      
      if (kDebugMode) {
        print('Voice Assistant initialized. Ollama with Gemma 2B available: $_isOllamaAvailable');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing voice assistant: $e');
      }
      _setState(VoiceAssistantState.error);
    }
  }
  
  Future<void> _configureTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.8); // Slightly slower for clarity
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    // Configure for offline use - prefer system voices over online ones
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _flutterTts.setEngine('com.google.android.tts');
    }
    
    // Set up TTS completion callback
    _flutterTts.setCompletionHandler(() {
      if (_state == VoiceAssistantState.speaking) {
        _setState(VoiceAssistantState.idle);
      }
    });
    
    // Set up error handler for offline reliability
    _flutterTts.setErrorHandler((message) {
      if (kDebugMode) {
        print('TTS Error: $message');
      }
      if (_state == VoiceAssistantState.speaking) {
        _setState(VoiceAssistantState.idle);
      }
    });
  }
  
  Future<void> _requestPermissions() async {
    final microphoneStatus = await Permission.microphone.request();
    if (microphoneStatus != PermissionStatus.granted) {
      throw Exception('Microphone permission is required for voice assistant');
    }
  }
  
  void _setState(VoiceAssistantState newState) {
    _state = newState;
    notifyListeners();
  }
  
  /// Start listening for voice input
  Future<void> startListening() async {
    if (!_isInitialized) {
      if (kDebugMode) {
        print('Voice assistant not initialized');
      }
      return;
    }
    
    if (_state != VoiceAssistantState.idle) {
      return;
    }
    
    try {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (kDebugMode) {
            print('Speech recognition status: $status');
          }
        },
        onError: (error) {
          if (kDebugMode) {
            print('Speech recognition error: $error');
          }
          _setState(VoiceAssistantState.error);
        },
      );
      
      if (!available) {
        _speak('Sorry, speech recognition is not available on this device.');
        return;
      }
      
      _setState(VoiceAssistantState.listening);
      _lastWords = '';
      
      await _speech.listen(
        onResult: (result) {
          _lastWords = result.recognizedWords;
          notifyListeners();
          
          if (result.finalResult) {
            _processVoiceInput(_lastWords);
          }
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        cancelOnError: true,
        partialResults: true,
      );
      
    } catch (e) {
      if (kDebugMode) {
        print('Error starting speech recognition: $e');
      }
      _setState(VoiceAssistantState.error);
    }
  }
  
  /// Stop listening
  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
    if (_state == VoiceAssistantState.listening) {
      _setState(VoiceAssistantState.idle);
    }
  }
  
  /// Process the voice input and get AI response
  Future<void> _processVoiceInput(String input) async {
    if (input.trim().isEmpty) {
      _setState(VoiceAssistantState.idle);
      return;
    }
    
    _setState(VoiceAssistantState.processing);
    
    try {
      String response;
      
      if (_isOllamaAvailable) {
        response = await OllamaService.sendMessage(input);
      } else {
        response = _getOfflineResponse(input);
      }
      
      _lastResponse = response;
      await _speak(response);
      
    } catch (e) {
      if (kDebugMode) {
        print('Error processing voice input: $e');
      }
      await _speak('Sorry, I encountered an error processing your request.');
      _setState(VoiceAssistantState.idle);
    }
  }
  
  /// Provide comprehensive offline responses when Ollama is not available
  String _getOfflineResponse(String input) {
    final lowerInput = input.toLowerCase();
    
    // Medical and healthcare
    if (lowerInput.contains('hospital') || lowerInput.contains('medical') || 
        lowerInput.contains('doctor') || lowerInput.contains('sick') || 
        lowerInput.contains('emergency') || lowerInput.contains('health')) {
      return 'For medical emergencies, call your local emergency number immediately. For non-emergency medical care, visit community health centers, federally qualified health centers, or free clinics. Many provide services regardless of immigration status. Search online for "free clinic near me" or contact local hospitals about charity care programs.';
    }
    
    // Education and school
    if (lowerInput.contains('school') || lowerInput.contains('education') || 
        lowerInput.contains('children') || lowerInput.contains('learn') ||
        lowerInput.contains('english') || lowerInput.contains('language')) {
      return 'All children have the right to public education regardless of immigration status. Visit your local school district office to enroll children. For adults, look for ESL classes at community colleges, libraries, or community centers. Many offer free English language learning programs.';
    }
    
    // Food assistance
    if (lowerInput.contains('food') || lowerInput.contains('hungry') || 
        lowerInput.contains('eat') || lowerInput.contains('meal') ||
        lowerInput.contains('grocery') || lowerInput.contains('kitchen')) {
      return 'Food banks, soup kitchens, and food pantries provide free meals and groceries. Search online for "food bank near me" or contact 211 for local resources. Religious organizations, community centers, and the Salvation Army often provide food assistance. Some areas have mobile food trucks that visit neighborhoods.';
    }
    
    // Housing and shelter
    if (lowerInput.contains('housing') || lowerInput.contains('shelter') || 
        lowerInput.contains('home') || lowerInput.contains('apartment') ||
        lowerInput.contains('rent') || lowerInput.contains('homeless')) {
      return 'For emergency housing, contact local homeless shelters or dial 211. For longer-term housing, reach out to refugee resettlement agencies, local housing authorities, or Habitat for Humanity. Some areas have transitional housing programs. Check with local religious organizations and community centers for housing assistance programs.';
    }
    
    // Employment and work
    if (lowerInput.contains('work') || lowerInput.contains('job') || 
        lowerInput.contains('employment') || lowerInput.contains('money') ||
        lowerInput.contains('career') || lowerInput.contains('interview')) {
      return 'First, verify your work authorization status. If authorized to work, visit local American Job Centers, employment agencies, or search online job boards like Indeed or LinkedIn. Many organizations offer job training programs, resume help, and interview preparation. Contact your local workforce development office for free services.';
    }
    
    // Legal and documentation
    if (lowerInput.contains('document') || lowerInput.contains('paper') || 
        lowerInput.contains('form') || lowerInput.contains('legal') ||
        lowerInput.contains('lawyer') || lowerInput.contains('immigration') ||
        lowerInput.contains('visa') || lowerInput.contains('citizen')) {
      return 'For help with legal documents and immigration matters, contact legal aid organizations, refugee assistance programs, or local bar associations that offer pro bono services. Many community centers provide free document assistance. Be cautious of immigration scams - only work with qualified attorneys or accredited representatives.';
    }
    
    // Transportation
    if (lowerInput.contains('transport') || lowerInput.contains('bus') || 
        lowerInput.contains('train') || lowerInput.contains('car') ||
        lowerInput.contains('drive') || lowerInput.contains('license')) {
      return 'Public transportation is often the most affordable option. Many cities offer reduced-fare programs for low-income residents. To get a driver\'s license, contact your local DMV office. Some organizations provide driving lessons and help with obtaining licenses. Ride-sharing and bike-sharing programs may also be available in your area.';
    }
    
    // General help and resources
    if (lowerInput.contains('help') || lowerInput.contains('resource') || 
        lowerInput.contains('where') || lowerInput.contains('how') ||
        lowerInput.contains('need') || lowerInput.contains('assistance')) {
      return 'For comprehensive local resources, call 211 - it\'s a free service that connects you with local assistance programs. Visit community centers, libraries, and religious organizations, as they often have information about local services. Refugee resettlement agencies can provide ongoing support even if you didn\'t originally work with them.';
    }
    
    // Default response with more helpful information
    return 'I\'m currently working in offline mode with limited responses. For specific help in your area, I recommend: 1) Calling 211 for local resources, 2) Visiting your local library for assistance and information, 3) Contacting refugee assistance organizations, community centers, or religious organizations, 4) Checking with local government offices for available programs. They can provide specific guidance for your location and situation.';
  }
  
  /// Speak the given text
  Future<void> _speak(String text) async {
    if (text.trim().isEmpty) return;
    
    _setState(VoiceAssistantState.speaking);
    
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      if (kDebugMode) {
        print('Error speaking: $e');
      }
      _setState(VoiceAssistantState.idle);
    }
  }
  
  /// Stop speaking
  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
    if (_state == VoiceAssistantState.speaking) {
      _setState(VoiceAssistantState.idle);
    }
  }
  
  /// Check and refresh Ollama connection
  Future<void> refreshOllamaConnection() async {
    _isOllamaAvailable = await OllamaService.isOllamaRunning();
    if (_isOllamaAvailable) {
      _isOllamaAvailable = await OllamaService.isModelAvailable();
      
      // If Ollama is running but Gemma model is not available, try to pull it
      if (!_isOllamaAvailable) {
        if (kDebugMode) {
          print('Attempting to pull Gemma 2B model...');
        }
        final pullSuccess = await OllamaService.pullModel();
        if (pullSuccess) {
          _isOllamaAvailable = await OllamaService.isModelAvailable();
        }
      }
    }
    notifyListeners();
  }

  /// Try to setup Gemma 2B model automatically
  Future<bool> setupGemma3Model() async {
    if (!await OllamaService.isOllamaRunning()) {
      return false;
    }
    
    if (await OllamaService.isModelAvailable()) {
      _isOllamaAvailable = true;
      notifyListeners();
      return true;
    }
    
    // Try to pull the model
    final success = await OllamaService.pullModel();
    if (success) {
      _isOllamaAvailable = await OllamaService.isModelAvailable();
      notifyListeners();
    }
    
    return _isOllamaAvailable;
  }
  
  @override
  void dispose() {
    _speech.cancel();
    _flutterTts.stop();
    super.dispose();
  }
}
