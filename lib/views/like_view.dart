import 'dart:math';

import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapgram/viewModels/like_view_model.dart';

class LikeView extends StatefulWidget {
  const LikeView({super.key});

  @override
  State<LikeView> createState() => _LikeViewState();
}

class _LikeViewState extends State<LikeView> {
  @override
  void initState() {
    super.initState();
    Provider.of<LikeViewModel>(context, listen: false).fetchLikes();
  }

  @override
  Widget build(BuildContext context) {
    final likeViewModel = Provider.of<LikeViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Likes")),
      body:
          likeViewModel.isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: likeViewModel.likes.length,
                      itemBuilder: (context, index) {
                        final like = likeViewModel.likes[index];
                        return Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Color(
                                  Random().nextInt(0xffffffff),
                                ),
                              ),
                              title: Text("${like.username} like your post"),
                              trailing: IconButton(
                                icon: Icon(Icons.reply, color: Colors.grey),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
