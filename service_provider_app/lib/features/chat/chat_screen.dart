// lib/features/chat/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../auth/auth_provider.dart';
import 'chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isFirstLoad = true;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final user = await ref.read(currentUserProvider.future);
    if (user == null) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    await ref.read(chatControllerProvider.notifier).sendMessage(
          widget.conversationId,
          user.id,
          message,
        );

    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.conversationId));
    final userAsync = ref.watch(currentUserProvider);
    final conversationAsync = ref.watch(conversationByIdProvider(widget.conversationId));

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0f172a),
            Color(0xFF1e293b),
            Color(0xFF0f172a),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF06b6d4).withOpacity(0.1),
                  const Color(0xFF06b6d4).withOpacity(0.05),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF06b6d4).withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF06b6d4)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: conversationAsync.when(
            data: (conversation) {
              if (conversation == null) {
                return const Text(
                  'Chat',
                  style: TextStyle(color: Color(0xFF06b6d4), fontSize: 16),
                );
              }
              
              final customer = conversation.customer;
              final customerName = customer?.fullName ?? 
                                 customer?.email?.split('@').first ?? 
                                 'Customer';
              final avatarUrl = customer?.avatarUrl;

              return Row(
                children: [
                  _buildAppBarAvatar(customerName, avatarUrl),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      customerName,
                      style: const TextStyle(
                        color: Color(0xFF06b6d4),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            },
            loading: () => const Text(
              'Chat',
              style: TextStyle(color: Color(0xFF06b6d4), fontSize: 16),
            ),
            error: (_, __) => const Text(
              'Chat',
              style: TextStyle(color: Color(0xFF06b6d4), fontSize: 16),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: messagesAsync.when(
                data: (messages) {
                  if (messages.isEmpty) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF06b6d4).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF06b6d4).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 48,
                              color: const Color(0xFF06b6d4).withOpacity(0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No messages yet',
                              style: TextStyle(
                                color: const Color(0xFF06b6d4).withOpacity(0.8),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Start the conversation!',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (_isFirstLoad) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                      _isFirstLoad = false;
                    });
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = userAsync.value?.id == message.senderId;
                      final sender = message.sender;

                      return MessageBubble(
                        key: ValueKey(message.id),
                        message: message.message,
                        timestamp: message.createdAt,
                        isMe: isMe,
                        senderName: isMe ? null : sender?.fullName,
                        senderAvatarUrl: isMe ? null : sender?.avatarUrl,
                      );
                    },
                  );
                },
                loading: () => Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06b6d4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF06b6d4).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF06b6d4)),
                    ),
                  ),
                ),
                error: (error, stack) => Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06b6d4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF06b6d4).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.redAccent.withOpacity(0.8),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Error loading messages',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => ref.invalidate(messagesProvider(widget.conversationId)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF06b6d4).withOpacity(0.8),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF06b6d4).withOpacity(0.1),
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFF06b6d4).withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF06b6d4).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF06b6d4).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                          textInputAction: TextInputAction.send,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF06b6d4),
                            Color(0xFF0891b2),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF06b6d4).withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 18),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarAvatar(String name, String? avatarUrl) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF06b6d4).withOpacity(0.5),
            width: 2,
          ),
        ),
        child: CircleAvatar(
          radius: 16,
          backgroundColor: const Color(0xFF1e293b),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: avatarUrl,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              placeholder: (context, url) => const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF06b6d4)),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: const Color(0xFF06b6d4).withOpacity(0.15),
                child: Center(
                  child: Text(
                    name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF06b6d4),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF06b6d4).withOpacity(0.5),
          width: 2,
        ),
      ),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: const Color(0xFF06b6d4).withOpacity(0.15),
        child: Text(
          name.substring(0, 1).toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF06b6d4),
          ),
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final DateTime timestamp;
  final bool isMe;
  final String? senderName;
  final String? senderAvatarUrl;

  const MessageBubble({
    super.key,
    required this.message,
    required this.timestamp,
    required this.isMe,
    this.senderName,
    this.senderAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isMe 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            _buildAvatar(),
            const SizedBox(width: 6),
          ],
          
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                color: isMe 
                    ? const Color(0xFF06b6d4).withOpacity(0.15)
                    : const Color(0xFF06b6d4).withOpacity(0.08),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                ),
                border: Border.all(
                  color: const Color(0xFF06b6d4).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isMe && senderName != null) ...[
                          Text(
                            senderName!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF06b6d4),
                            ),
                          ),
                          const SizedBox(height: 3),
                        ],
                        Text(
                          message,
                          style: TextStyle(
                            color: isMe 
                                ? Colors.white 
                                : Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          Formatters.relativeTime(timestamp),
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          if (isMe) ...[
            const SizedBox(width: 6),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF06b6d4).withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFF06b6d4).withOpacity(0.15),
                child: const Icon(
                  Icons.person,
                  size: 16,
                  color: Color(0xFF06b6d4),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (senderAvatarUrl != null && senderAvatarUrl!.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF06b6d4).withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: CircleAvatar(
          radius: 14,
          backgroundColor: const Color(0xFF1e293b),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: senderAvatarUrl!,
              width: 28,
              height: 28,
              fit: BoxFit.cover,
              placeholder: (context, url) => const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF06b6d4)),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: const Color(0xFF06b6d4).withOpacity(0.15),
                child: Center(
                  child: Text(
                    (senderName ?? 'C').substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF06b6d4),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF06b6d4).withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: CircleAvatar(
        radius: 14,
        backgroundColor: const Color(0xFF06b6d4).withOpacity(0.15),
        child: Text(
          (senderName ?? 'C').substring(0, 1).toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF06b6d4),
          ),
        ),
      ),
    );
  }
}