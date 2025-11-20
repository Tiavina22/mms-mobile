import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String content;
  final bool isMe;
  final String time;
  final bool isDeleted;
  final bool isEdited;
  final String? previousContent;
  final VoidCallback? onLongPress;

  const MessageBubble({
    super.key,
    required this.content,
    required this.isMe,
    required this.time,
    this.isDeleted = false,
    this.isEdited = false,
    this.previousContent,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isDeleted
        ? Colors.grey[600]
        : (isMe ? Theme.of(context).primaryColor : Colors.grey[300]);
    final textColor = isDeleted
        ? Colors.white70
        : (isMe ? Colors.white : Colors.black87);
    final displayText = isDeleted ? 'Message deleted' : content;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
              bottomRight: isMe ? Radius.zero : const Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayText,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontStyle: isDeleted ? FontStyle.italic : FontStyle.normal,
                ),
              ),
              if (isEdited && !isDeleted)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    (previousContent != null && previousContent!.isNotEmpty)
                        ? 'Edited • Previous: $previousContent'
                        : 'Edited',
                    style: TextStyle(
                      color: textColor.withOpacity(0.8),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  color: textColor.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
