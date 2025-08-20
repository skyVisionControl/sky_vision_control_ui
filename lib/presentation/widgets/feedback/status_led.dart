import 'package:flutter/material.dart';

class StatusLed extends StatelessWidget {
  const StatusLed({
    super.key,
    required this.title,
    required this.on,
    this.onColor = Colors.green,
  });

  final String title;
  final bool on;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    final c = on ? onColor : Colors.grey.shade400;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: c, shape: BoxShape.circle,
            boxShadow: on ? [BoxShadow(color: c.withOpacity(.5), blurRadius: 8)] : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 14))),
      ],
    );
  }
}