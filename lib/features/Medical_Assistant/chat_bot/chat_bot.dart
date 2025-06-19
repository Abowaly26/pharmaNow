import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:pharma_now/features/Medical_Assistant/MedicalAssistant%20.dart';
import '../../../core/utils/app_images.dart';

// Data Models
class ChatMessage {
  final String role;
  final String content;
  final DateTime timestamp;
  final String? messageId;

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.messageId,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
}

class ApiResponse {
  final bool success;
  final String? content;
  final String? error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.content,
    this.error,
    this.statusCode,
  });
}

// Constants
class ChatConstants {
  static const String apiKey = 'f9b636960c1347b192d8252d1179c858';
  static const String apiUrl = 'https://api.aimlapi.com/chat/completions';
  static const String model = 'gpt-4o-mini';
  static const int maxTokens = 512;
  static const double temperature = 0.7;
  static const double topP = 0.7;
  static const int frequencyPenalty = 1;
  static const int topK = 50;

  static const String systemPrompt =
      'You are a professional medical consultant AI assistant. Provide accurate, '
      'evidence-based medical information and guidance in a clear, compassionate manner. '
      'Always include appropriate disclaimers about consulting licensed healthcare '
      'professionals for proper medical advice and diagnosis.';
}

// Colors
class ChatColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color secondary = Color(0xFF3638DA);
  static const Color background = Color(0xFFF2F4F9);
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.grey;
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE5E7EB);
}

// Service Layer
class ChatApiService {
  static Future<ApiResponse> sendMessage(String userMessage) async {
    try {
      final response = await http
          .post(
            Uri.parse(ChatConstants.apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${ChatConstants.apiKey}',
            },
            body: jsonEncode({
              'model': ChatConstants.model,
              'messages': [
                {
                  'role': 'system',
                  'content': ChatConstants.systemPrompt,
                },
                {
                  'role': 'user',
                  'content': userMessage,
                }
              ],
              'temperature': ChatConstants.temperature,
              'top_p': ChatConstants.topP,
              'frequency_penalty': ChatConstants.frequencyPenalty,
              'max_tokens': ChatConstants.maxTokens,
              'top_k': ChatConstants.topK,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]['message']['content'] ??
            data['content'] ??
            'No response available';

        return ApiResponse(success: true, content: content);
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage =
            errorData['error']?['message'] ?? 'Unknown server error';

        return ApiResponse(
          success: false,
          error: 'Server Error (${response.statusCode}): $errorMessage',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      return ApiResponse(
        success: false,
        error: 'Request timeout. Please check your internet connection.',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Connection failed: ${e.toString()}',
      );
    }
  }
}

// Main Chat Page
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  static const routeName = 'chat_page';

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  // Controllers and State
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;
  bool _hasText = false;

  late AnimationController _typingAnimationController;

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Listen to text changes
    _messageController.addListener(() {
      setState(() {
        _hasText = _messageController.text.trim().isNotEmpty;
      });
    });

    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      role: 'assistant',
      content: 'Hello! I\'m your medical assistant. How can I help you today? '
          'Please remember that I provide general information only, and you should '
          'consult with a healthcare professional for medical advice.',
    ));
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty || _isLoading) return;

    // Add user message
    final userMessage = ChatMessage(role: 'user', content: messageText);
    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Send to API
    final response = await ChatApiService.sendMessage(messageText);

    // Add response message
    final assistantMessage = ChatMessage(
      role: 'assistant',
      content: response.success ? response.content! : response.error!,
    );

    setState(() {
      _messages.add(assistantMessage);
      _isLoading = false;
      _isTyping = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _navigateBack() {
    Navigator.pushReplacementNamed(context, MedicalAssistant.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChatColors.surface,
      appBar: _buildAppBar(),
      body: _buildBody(),
      resizeToAvoidBottomInset: true,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: ChatColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: ChatColors.textPrimary),
        onPressed: _navigateBack,
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ChatColors.background,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              Assets.chatImage,
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Medical Assistant',
                style: TextStyle(
                  color: ChatColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _isTyping ? 'Typing...' : 'Online',
                style: TextStyle(
                  color: _isTyping ? ChatColors.primary : Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: ChatColors.textPrimary),
          onPressed: () => _showOptionsMenu(),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildDateHeader(),
        Expanded(child: _buildMessagesList()),
        if (_isLoading) _buildTypingIndicator(),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildDateHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        _formatDate(DateTime.now()),
        style: TextStyle(
          color: ChatColors.textSecondary.withOpacity(0.7),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isAssistant) ...[
            Container(
              margin: const EdgeInsets.only(right: 8, top: 4),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: ChatColors.background,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                Assets.chatImage,
                width: 16,
                height: 16,
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? ChatColors.primary
                    : ChatColors.primaryLight,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: message.isAssistant
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                  bottomRight: message.isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: message.isUser
                      ? ChatColors.surface
                      : ChatColors.textPrimary,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: ChatColors.background,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              Assets.chatImage,
              width: 16,
              height: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: ChatColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: AnimatedBuilder(
              animation: _typingAnimationController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final delay = index * 0.2;
                    final animationValue =
                        (_typingAnimationController.value - delay)
                            .clamp(0.0, 1.0);
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: ChatColors.primary.withOpacity(animationValue),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ChatColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: ChatColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: ChatColors.border),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _messageFocusNode,
                enabled: !_isLoading,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(
                  hintText: 'Ask me anything about health...',
                  hintStyle: TextStyle(
                    color: ChatColors.textSecondary,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 15,
                  color: ChatColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _hasText && !_isLoading
                  ? ChatColors.secondary
                  : ChatColors.textSecondary.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _hasText && !_isLoading ? _sendMessage : null,
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ChatColors.surface,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.send_rounded,
                      color: _hasText && !_isLoading
                          ? ChatColors.surface
                          : ChatColors.surface.withOpacity(0.5),
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.clear_all),
              title: const Text('Clear Chat'),
              onTap: () {
                Navigator.pop(context);
                _clearChat();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear all messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _messages.clear();
                _addWelcomeMessage();
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Medical Assistant'),
        content: const Text(
          'This AI assistant provides general medical information and guidance. '
          'Always consult with qualified healthcare professionals for proper '
          'medical advice, diagnosis, and treatment.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
