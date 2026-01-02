import 'package:flutter/material.dart';
import 'news_posting_page.dart';


class AdminMessageCenterPage extends StatelessWidget {
  const AdminMessageCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.of(context).size.width >= 700;

    final List<_MessageItem> messages = [
      _MessageItem(
        title: 'Super Agent Messages',
        icon: Icons.supervisor_account,
        color1: Colors.blue,
        color2: Colors.blueAccent,
        description: 'View and manage messages from super agents.',
      ),
      _MessageItem(
        title: 'Agent Messages',
        icon: Icons.person,
        color1: Colors.teal,
        color2: Colors.tealAccent,
        description: 'Check messages sent by agents.',
      ),
      _MessageItem(
        title: 'Voter Messages',
        icon: Icons.people,
        color1: Colors.orange,
        color2: Colors.deepOrangeAccent,
        description: 'Read messages from voters.',
      ),
      _MessageItem(
        title: 'Campaign',
        icon: Icons.campaign,
        color1: Colors.purple,
        color2: Colors.purpleAccent,
        description: 'Manage ongoing campaign messages.',
      ),
      _MessageItem(
        title: 'Daily News',
        icon: Icons.newspaper,
        color1: Colors.red,
        color2: Colors.redAccent,
        description: 'Daily news updates for the admin.',
      ),
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: messages
                .map((msg) => _MessageCard(item: msg, wide: wide))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _MessageItem {
  final String title;
  final IconData icon;
  final Color color1;
  final Color color2;
  final String description;

  _MessageItem({
    required this.title,
    required this.icon,
    required this.color1,
    required this.color2,
    required this.description,
  });
}

class _MessageCard extends StatefulWidget {
  final _MessageItem item;
  final bool wide;

  const _MessageCard({required this.item, this.wide = false});

  @override
  State<_MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<_MessageCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.wide ? 260 : double.infinity,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.all(4), // ✅ BUFFER ZONE (IMPORTANT)
          transform: Matrix4.translationValues(
            0,
            _hovering ? -6 : 0, // ✅ lift instead of scale
            0,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.item.color1, widget.item.color2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: widget.item.color1.withOpacity(
                  _hovering ? 0.6 : 0.35,
                ),
                blurRadius: _hovering ? 20 : 12,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              splashColor: Colors.white24,
              highlightColor: Colors.white10,
              onTap: () {
                if (widget.item.title == 'Daily News') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewsPostingPage(),
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(widget.item.icon, size: 40, color: Colors.white),
                    const SizedBox(height: 12),
                    Text(
                      widget.item.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.item.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
