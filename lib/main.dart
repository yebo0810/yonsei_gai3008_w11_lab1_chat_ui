import 'package:flutter/material.dart';

void main() => runApp(const ChatLabApp());

class ChatLabApp extends StatelessWidget {
  const ChatLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Chat — 실습 1',
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
    });

    _controller.clear();

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      setState(() {
        _messages.add(
          ChatMessage(
            text: '안녕하세요! "$text"에 대한 답변입니다.',
            isUser: false,
          ),
        );

        _isLoading = false;
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
        title: const Text('AI Chat — 실습 1'),
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

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'AI가 답변을 작성하고 있습니다...',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

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
        child: Text(
          message.text,
        ),
      ),
    );
  }
}