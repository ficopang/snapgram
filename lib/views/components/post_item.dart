import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapgram/viewModels/comment_view_model.dart';
import 'package:snapgram/viewModels/post_view_model.dart';
import 'package:snapgram/views/components/comment_text_field.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:toastification/toastification.dart';

class PostItem extends StatefulWidget {
  final BuildContext context;
  final PostViewModel postViewModel;
  final String username;
  final int postId;
  final String imagePath;
  final int initialLikes;
  final bool initialLiked;
  final String date;
  final String caption;

  const PostItem({
    super.key,
    required this.context,
    required this.postViewModel,
    required this.username,
    required this.postId,
    required this.imagePath,
    required this.initialLikes,
    required this.initialLiked,
    required this.date,
    required this.caption,
  });

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  late bool _liked;
  late int _likes;

  @override
  void initState() {
    super.initState();
    _liked = widget.initialLiked;
    _likes = widget.initialLikes;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Color(Random().nextInt(0xffffffff)),
          ),
          title: Text(widget.username),
          trailing: Icon(Icons.more_vert),
        ),
        Image.network(widget.imagePath),
        Row(
          children: <Widget>[
            IconButton(
              icon: Icon(_liked ? Icons.favorite : Icons.favorite_border),
              color: _liked ? Colors.red : null,
              onPressed: () async {
                setState(() {
                  _liked = !_liked;
                  _likes = _liked ? _likes + 1 : _likes - 1;
                });
                try {
                  await widget.postViewModel.likePost(widget.postId.toString());
                } catch (e) {
                  setState(() {
                    _liked = !_liked;
                    _likes = _liked ? _likes - 1 : _likes + 1;
                  });
                  print('Error liking post: $e');
                }
              },
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(end: 8),
              child: Text(_likes.toString()),
            ),
            IconButton(
              icon: Icon(Icons.chat_bubble_outline),
              onPressed: () {
                Provider.of<CommentViewModel>(
                  context,
                  listen: false,
                ).fetchComments(widget.postId.toString());
                _showCommentDrawer(context, widget.postId);
              },
            ),
            IconButton(icon: Icon(Icons.send), onPressed: () {}),
            Expanded(child: SizedBox()),
            IconButton(icon: Icon(Icons.bookmark_border), onPressed: () {}),
          ],
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ExpandableText(
            widget.caption,
            expandText: 'show more',
            collapseText: 'show less',
            maxLines: 1,
            linkColor: Colors.grey,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(widget.date, style: TextStyle(color: Colors.grey)),
        ),

        SizedBox(height: 16),
      ],
    );
  }
}

void _showCommentDrawer(BuildContext context, int postId) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      final commentViewModel = Provider.of<CommentViewModel>(context);

      if (commentViewModel.errorMessage.isNotEmpty) {
        if (commentViewModel.errorMessage == 'Unauthorized') {
          // Go login page
          Navigator.pushReplacementNamed(context, '/');
        }

        // Show error message
        Future.microtask(
          () => toastification.show(
            title: Text(commentViewModel.errorMessage),
            type: ToastificationType.error,
            autoCloseDuration: const Duration(seconds: 5),
          ),
        );
      }

      if (commentViewModel.errorMessage.isNotEmpty) {
        // Show error message
        Future.microtask(
          () => toastification.show(
            title: Text(commentViewModel.errorMessage),
            type: ToastificationType.error,
            autoCloseDuration: const Duration(seconds: 5),
          ),
        );
      }

      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child:
            commentViewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Expanded(
                      child: ListView.builder(
                        itemCount: commentViewModel.comments.length,
                        itemBuilder: (context, index) {
                          final comment = commentViewModel.comments[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Color(
                                Random().nextInt(0xffffffff),
                              ),
                            ),
                            title: Text(comment.username),
                            subtitle: ExpandableText(
                              comment.text,
                              expandText: 'show more',
                              collapseText: 'show less',
                              maxLines: 2,
                              linkColor: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                    CommentTextField(
                      onSend: (text) {
                        commentViewModel.addComment(postId, text);
                        Provider.of<CommentViewModel>(
                          context,
                          listen: false,
                        ).fetchComments(postId.toString());
                      },
                    ),
                  ],
                ),
      );
    },
  );
}
