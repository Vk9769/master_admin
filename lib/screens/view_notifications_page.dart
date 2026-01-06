import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationModel {
  final String title;
  final String message;
  final String audience; // Admins, Super Agents, Voters
  final String priority; // Normal, High, Urgent
  final DateTime dateTime;

  NotificationModel({
    required this.title,
    required this.message,
    required this.audience,
    required this.priority,
    required this.dateTime,
  });
}

class ViewNotificationsPage extends StatefulWidget {
  const ViewNotificationsPage({super.key});

  @override
  State<ViewNotificationsPage> createState() => _ViewNotificationsPageState();
}

class _ViewNotificationsPageState extends State<ViewNotificationsPage> {
  String _selectedAudience = 'All';
  String _selectedPriority = 'All';

  final List<NotificationModel> _notifications = [
    NotificationModel(
      title: 'Election Schedule Updated',
      message: 'Polling date changed to 20th Nov due to administrative reasons.',
      audience: 'Admins',
      priority: 'Urgent',
      dateTime: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationModel(
      title: 'Booth Preparation Reminder',
      message: 'Ensure all booths are ready by 8 AM.',
      audience: 'Super Agents',
      priority: 'High',
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NotificationModel(
      title: 'Voting Day Announcement',
      message: 'Voting will start at 7 AM tomorrow.',
      audience: 'Voters',
      priority: 'Normal',
      dateTime: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  List<NotificationModel> get _filteredNotifications {
    return _notifications.where((n) {
      final audienceMatch =
          _selectedAudience == 'All' || n.audience == _selectedAudience;
      final priorityMatch =
          _selectedPriority == 'All' || n.priority == _selectedPriority;
      return audienceMatch && priorityMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: const Text(
          'Notification History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2563EB), // BLUE
        foregroundColor: Colors.white, // back button + icons
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _filteredNotifications.isEmpty
                ? _emptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredNotifications.length,
              itemBuilder: (context, index) {
                return _notificationCard(
                  _filteredNotifications[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= FILTERS =================

  Widget _buildFilters() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _dropdown(
            label: 'Audience',
            value: _selectedAudience,
            items: const ['All', 'Admins', 'Super Agents', 'Voters'],
            onChanged: (v) => setState(() => _selectedAudience = v),
          ),
          const SizedBox(width: 12),
          _dropdown(
            label: 'Priority',
            value: _selectedPriority,
            items: const ['All', 'Normal', 'High', 'Urgent'],
            onChanged: (v) => setState(() => _selectedPriority = v),
          ),
        ],
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: value,
            items: items
                .map(
                  (e) => DropdownMenuItem(
                value: e,
                child: Text(e),
              ),
            )
                .toList(),
            onChanged: (v) => onChanged(v!),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF1F5FF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ================= CARD =================

  Widget _notificationCard(NotificationModel n) {
    final color = _priorityColor(n.priority);
    final date = DateFormat('dd MMM yyyy • hh:mm a').format(n.dateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _badge(
                text: n.priority.toUpperCase(),
                color: color,
              ),
              const SizedBox(width: 8),
              _badge(
                text: n.audience,
                color: const Color(0xFF2563EB),
                light: true,
              ),
              const Spacer(),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            n.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            n.message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge({
    required String text,
    required Color color,
    bool light = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: light ? color.withOpacity(0.1) : color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  // ================= HELPERS =================

  Color _priorityColor(String p) {
    switch (p) {
      case 'Urgent':
        return const Color(0xFFDC2626);
      case 'High':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none,
              size: 72, color: Colors.blue.shade200),
          const SizedBox(height: 16),
          const Text(
            'No notifications found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}
