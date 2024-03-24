import 'package:flutter/material.dart';

Future<void> showOkDialog({
  required BuildContext context,
  required String title,
  required String message,
  Map<String, int>? reportCounts, // Use a map for report counts
}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            SizedBox(height: 8),
            if (reportCounts != null)
              ...reportCounts.entries.map(
                (entry) => Text('${entry.key}: ${entry.value}'),
              ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      );
    },
  );
}
