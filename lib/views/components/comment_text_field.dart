import 'package:flutter/material.dart';

class CommentTextField extends StatefulWidget {
  final Function(String) onSend;

  const CommentTextField({super.key, required this.onSend});

  @override
  State<CommentTextField> createState() => _CommentTextFieldState();
}

class _CommentTextFieldState extends State<CommentTextField> {
  final _formKey = GlobalKey<FormState>();
  String text = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Form(
        key: _formKey,
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    text = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a comment';
                  }
                  return null;
                },
                onSaved: (newValue) {
                  text = newValue ?? "";
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  widget.onSend(text);
                  setState(() {
                    text = '';
                  });
                  _formKey.currentState!.reset();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
