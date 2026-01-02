import 'package:flutter/material.dart';
import 'package:nostr_mail/nostr_mail.dart';

class EmailTile extends StatelessWidget {
  final Email email;
  final VoidCallback onTap;

  const EmailTile({super.key, required this.email, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: Colors.deepPurple.shade100,
            child: Text(
              _getInitial(email.from),
              style: TextStyle(
                color: Colors.deepPurple.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            email.subject.isEmpty ? '(No subject)' : email.subject,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                email.from,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                email.body,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ],
          ),
          trailing: Text(
            _formatDate(email.date),
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
          ),
          isThreeLine: true,
        ),
        const Divider(height: 1),
      ],
    );
  }

  String _getInitial(String from) {
    if (from.isEmpty) return '?';
    final name = from.split('@').first;
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[date.weekday - 1];
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
