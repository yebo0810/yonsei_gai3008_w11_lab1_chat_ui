import 'package:flutter/material.dart';

void main() => runApp(const ChatLabApp());

class ChatLabApp extends StatelessWidget {
  const ChatLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Chat — 실습 4',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F6FE4),
        ),
        useMaterial3: true,
      ),
      home: const ChatPage(),
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.isUser,
  });

  final String text;
  final bool isUser;
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();

  final List<ChatMessage> _messages = [];

  bool _isLoading = false;
  bool _hasError = false;

  String? _failedMessage;

  // 실습용: 첫 번째 요청은 실패하도록 설정
  bool _firstRequest = true;

  void _send() {
    final text = _controller.text.trim();

    if (text.isEmpty || _isLoading) {
      return;
    }

    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
        ),
      );

      _isLoading = true;
      _hasError = false;
      _failedMessage = text;
    });

    _controller.clear();

    _requestReply(text);
  }

  void _retry() {
    if (_failedMessage == null || _isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    _requestReply(_failedMessage!);
  }

  void _requestReply(String text) {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      // 第一次请求模拟失败
      if (_firstRequest) {
        _firstRequest = false;

        setState(() {
          _isLoading = false;
          _hasError = true;
        });

        return;
      }

      // Retry 后模拟请求成功
      setState(() {
        _messages.add(
          ChatMessage(
            text: '안녕하세요! "$text"에 대한 답변입니다.',
            isUser: false,
          ),
        );

        _isLoading = false;
        _hasError = false;
        _failedMessage = null;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat — 실습 4'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message =
                          _messages[_messages.length - 1 - index];

                      return _Bubble(
                        message: message,
                      );
                    },
                  ),

                  if (_messages.isEmpty)
                    const Center(
                      child: Text(
                        '무엇이든 물어보세요',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Loading
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('응답을 기다리는 중...'),
                    ],
                  ),
                ),
              ),

            // Error message + Retry button
            if (_hasError)
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '오류가 발생했습니다.',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      '요청을 처리할 수 없습니다. 다시 시도해 주세요.',
                    ),

                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: _retry,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ),
                  ],
                ),
              ),

            // Input bar
            Container(
              padding: const EdgeInsets.fromLTRB(
                12,
                8,
                12,
                12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: '메시지를 입력하세요...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  IconButton.filled(
                    onPressed: _isLoading ? null : _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.message,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: message.isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        constraints: const BoxConstraints(
          maxWidth: 420,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(message.text),
      ),
    );
  }
}