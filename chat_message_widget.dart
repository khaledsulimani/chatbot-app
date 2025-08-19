import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../models/chat_message.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final Function(String)? onSpeak;

  const ChatMessageWidget({
    super.key,
    required this.message,
    this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.type == MessageType.user;
    final isSystem = message.type == MessageType.system;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(context, isSystem),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: _buildMessageBubble(context, theme, isUser, isSystem),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser) _buildAvatar(context, false),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, bool isSystem) {
    final theme = Theme.of(context);
    
    return CircleAvatar(
      radius: 16,
      backgroundColor: isSystem 
          ? theme.colorScheme.tertiary
          : theme.colorScheme.primary,
      child: Icon(
        isSystem ? Icons.info_outline : Icons.smart_toy,
        size: 16,
        color: theme.colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ThemeData theme, bool isUser, bool isSystem) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getBubbleColor(theme, isUser, isSystem),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isUser ? 16 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMessageContent(context, theme, isUser),
          const SizedBox(height: 4),
          _buildMessageFooter(context, theme, isUser),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, ThemeData theme, bool isUser) {
    return SelectableText(
      message.content,
      style: TextStyle(
        color: _getTextColor(theme, isUser),
        fontSize: 16,
      ),
    );
  }

  Widget _buildMessageFooter(BuildContext context, ThemeData theme, bool isUser) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Message indicators
        if (message.isAudio)
          Icon(
            Icons.mic,
            size: 12,
            color: _getTextColor(theme, isUser).withOpacity(0.6),
          ),
        if (message.isAudio) const SizedBox(width: 4),
        
        // Status indicator
        if (message.status == MessageStatus.sending)
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getTextColor(theme, isUser).withOpacity(0.6),
              ),
            ),
          ),
        if (message.status == MessageStatus.error)
          Icon(
            Icons.error_outline,
            size: 12,
            color: theme.colorScheme.error,
          ),
        
        const Spacer(),
        
        // Timestamp
        Text(
          _formatTime(message.timestamp),
          style: TextStyle(
            color: _getTextColor(theme, isUser).withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Action buttons
        _buildActionButtons(context, theme, isUser),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme, bool isUser) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Copy button
        InkWell(
          onTap: () => _copyToClipboard(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.copy,
              size: 14,
              color: _getTextColor(theme, isUser).withOpacity(0.6),
            ),
          ),
        ),
        
        // Speak button (only for assistant messages)
        if (!isUser && onSpeak != null)
          InkWell(
            onTap: () => onSpeak!(message.content),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.volume_up,
                size: 14,
                color: _getTextColor(theme, isUser).withOpacity(0.6),
              ),
            ),
          ),
      ],
    );
  }

  Color _getBubbleColor(ThemeData theme, bool isUser, bool isSystem) {
    if (isSystem) {
      return theme.colorScheme.tertiaryContainer;
    } else if (isUser) {
      return theme.colorScheme.primary;
    } else {
      return theme.colorScheme.surfaceContainerHighest;
    }
  }

  Color _getTextColor(ThemeData theme, bool isUser) {
    if (isUser) {
      return theme.colorScheme.onPrimary;
    } else {
      return theme.colorScheme.onSurface;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${timestamp.day}/${timestamp.month}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message copied to clipboard'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
