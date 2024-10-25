// Event Creation Dialog
import 'package:flutter/material.dart';

class CreateEventDialog extends StatefulWidget {
  final Function(String, String) onSubmit;
  const CreateEventDialog({super.key, required this.onSubmit});

  @override
  CreateEventDialogState createState() => CreateEventDialogState();
}

class CreateEventDialogState extends State<CreateEventDialog> {
  String title = '', description = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Event'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
              onChanged: (val) => title = val,
              decoration: const InputDecoration(labelText: 'Title')),
          TextField(
              onChanged: (val) => description = val,
              decoration: const InputDecoration(labelText: 'Description')),
        ],
      ),
      actions: [
        ElevatedButton(
            onPressed: () {
              widget.onSubmit(title, description);
              Navigator.pop(context);
            },
            child: const Text('Create'))
      ],
    );
  }
}