import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/voice_assistant_service.dart';
import 'services_map_screen.dart';
import 'service_list_screen.dart';
import 'data_test_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const VoiceAssistantScreen(),
    const DataTestScreen(),
    const ServicesMapScreen(),
    const ServiceListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2E7D59),
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.mic),
              activeIcon: Icon(Icons.mic, size: 28),
              label: 'Voice Assistant',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bug_report),
              activeIcon: Icon(Icons.bug_report, size: 28),
              label: 'Data Test',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map, size: 28),
              label: 'Map View',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              activeIcon: Icon(Icons.list, size: 28),
              label: 'List View',
            ),
          ],
        ),
      ),
    );
  }
}

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceAssistantService>(
      builder: (context, voiceService, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            title: const Text(
              'Marhaba',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            backgroundColor: const Color(0xFF2E7D59),
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(
                  voiceService.isOllamaAvailable 
                    ? Icons.cloud_done 
                    : Icons.cloud_off,
                  color: voiceService.isOllamaAvailable 
                    ? Colors.lightGreen 
                    : Colors.orange,
                ),
                onPressed: () {
                  voiceService.refreshOllamaConnection();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        voiceService.isOllamaAvailable
                          ? 'AI Assistant: Online with Gemma 2B'
                          : 'AI Assistant: Offline (Basic responses only)',
                      ),
                      backgroundColor: const Color(0xFF2E7D59),
                    ),
                  );
                },
                tooltip: voiceService.isOllamaAvailable 
                  ? 'AI Assistant Online' 
                  : 'AI Assistant Offline',
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Header
                  const Text(
                    'مرحبا - Marhaba!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D59),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your Personal Assistant for Life in a New Country',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF666666),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Voice Assistant Status
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildStatusIndicator(voiceService.state),
                        const SizedBox(height: 20),
                        _buildResponseArea(voiceService),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Voice Input Area
                  _buildVoiceInputArea(voiceService),
                  
                  const SizedBox(height: 20),
                  
                  // Quick Help Tips
                  _buildQuickTips(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator(VoiceAssistantState state) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (state) {
      case VoiceAssistantState.idle:
        statusText = 'Ready to help';
        statusColor = const Color(0xFF2E7D59);
        statusIcon = Icons.mic;
        break;
      case VoiceAssistantState.listening:
        statusText = 'Listening...';
        statusColor = Colors.blue;
        statusIcon = Icons.hearing;
        break;
      case VoiceAssistantState.processing:
        statusText = 'Processing...';
        statusColor = Colors.orange;
        statusIcon = Icons.psychology;
        break;
      case VoiceAssistantState.speaking:
        statusText = 'Speaking...';
        statusColor = const Color(0xFF2E7D59);
        statusIcon = Icons.volume_up;
        break;
      case VoiceAssistantState.error:
        statusText = 'Error occurred';
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(statusIcon, color: statusColor, size: 24),
        const SizedBox(width: 10),
        Text(
          statusText,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: statusColor,
          ),
        ),
      ],
    );
  }

  Widget _buildResponseArea(VoiceAssistantService voiceService) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (voiceService.lastWords.isNotEmpty) ...[
            const Text(
              'You said:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              voiceService.lastWords,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF333333),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 15),
          ],
          
          if (voiceService.lastResponse.isNotEmpty) ...[
            const Text(
              'Response:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              voiceService.lastResponse,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF333333),
                height: 1.4,
              ),
            ),
          ] else ...[
            const Text(
              'Ask me anything about living in your new country! I can help with healthcare, education, housing, employment, and more.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVoiceInputArea(VoiceAssistantService voiceService) {
    return Column(
      children: [
        // Voice Button
        GestureDetector(
          onTap: () async {
            if (voiceService.state == VoiceAssistantState.idle) {
              await voiceService.startListening();
            } else if (voiceService.state == VoiceAssistantState.listening) {
              await voiceService.stopListening();
            } else if (voiceService.state == VoiceAssistantState.speaking) {
              await voiceService.stopSpeaking();
            }
          },
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _getVoiceButtonColor(voiceService.state),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getVoiceButtonColor(voiceService.state).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              _getVoiceButtonIcon(voiceService.state),
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
        
        const SizedBox(height: 15),
        
        // Instructions
        Text(
          _getVoiceButtonText(voiceService.state),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuickTips() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D59).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2E7D59).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💡 Quick Tips:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D59),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '• Ask about hospitals, schools, or food banks\n'
            '• Get help with documents and legal matters\n'
            '• Learn about transportation and housing\n'
            '• Find employment and career guidance',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF2E7D59),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Color _getVoiceButtonColor(VoiceAssistantState state) {
    switch (state) {
      case VoiceAssistantState.idle:
        return const Color(0xFF2E7D59);
      case VoiceAssistantState.listening:
        return Colors.blue;
      case VoiceAssistantState.processing:
        return Colors.orange;
      case VoiceAssistantState.speaking:
        return const Color(0xFF2E7D59);
      case VoiceAssistantState.error:
        return Colors.red;
    }
  }

  IconData _getVoiceButtonIcon(VoiceAssistantState state) {
    switch (state) {
      case VoiceAssistantState.idle:
        return Icons.mic;
      case VoiceAssistantState.listening:
        return Icons.mic;
      case VoiceAssistantState.processing:
        return Icons.psychology;
      case VoiceAssistantState.speaking:
        return Icons.stop;
      case VoiceAssistantState.error:
        return Icons.refresh;
    }
  }

  String _getVoiceButtonText(VoiceAssistantState state) {
    switch (state) {
      case VoiceAssistantState.idle:
        return 'Tap to start speaking';
      case VoiceAssistantState.listening:
        return 'Listening... Tap to stop';
      case VoiceAssistantState.processing:
        return 'Processing your request...';
      case VoiceAssistantState.speaking:
        return 'Tap to stop speaking';
      case VoiceAssistantState.error:
        return 'Tap to try again';
    }
  }
}
