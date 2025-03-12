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
  final int totalComments;
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
    required this.totalComments,
    required this.date,
    required this.caption,
  });

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  int selectedIndex = 0;
  late bool _liked;
  late int _likes;
  late int _comments;

  @override
  void initState() {
    super.initState();
    _liked = widget.initialLiked;
    _likes = widget.initialLikes;
    _comments = widget.totalComments;
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
          trailing: PopupMenuButton(
            onSelected: (value) async {
              print(value);
              await Provider.of<PostViewModel>(
                context,
                listen: false,
              ).deletePost(widget.postId);
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry>[
                  PopupMenuItem(child: const Text('Delete'), value: "tet"),
                  const PopupMenuItem(child: Text('Item 2')),
                  const PopupMenuItem(child: Text('Item 3')),
                ],
          ),
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
            Padding(
              padding: EdgeInsetsDirectional.only(end: 8),
              child: Text(_comments.toString()),
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
                          return Column(
                            children: [
                              ListTile(
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
                                trailing: IconButton(
                                  icon: Icon(Icons.reply, color: Colors.grey),
                                  onPressed: () {
                                    _showReplyDialog(
                                      context,
                                      comment.id,
                                      postId,
                                    );
                                  },
                                ),
                              ),

                              if (comment.replies.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(left: 40),
                                  child: Column(
                                    children:
                                        comment.replies.map((reply) {
                                          return ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: Color(
                                                Random().nextInt(0xffffffff),
                                              ),
                                            ),
                                            title: Text(reply.username),
                                            subtitle: Text(reply.content),
                                          );
                                        }).toList(),
                                  ),
                                ),
                            ],
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

void _showReplyDialog(BuildContext context, int commentId, int postId) {
  TextEditingController replyController = TextEditingController();
  final commentViewModel = Provider.of<CommentViewModel>(
    context,
    listen: false,
  );

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Reply"),
        content: TextField(
          controller: replyController,
          decoration: InputDecoration(hintText: "Write a reply..."),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              commentViewModel.addReply(commentId, replyController.text);
              Navigator.pop(context);
              commentViewModel.fetchComments(postId.toString());
            },
            child: Text("Reply"),
          ),
        ],
      );
    },
  );
}
