import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:snapgram/api_service.dart';
import 'package:snapgram/viewModels/post_view_model.dart';
import 'package:snapgram/views/components/post_item.dart';
import 'package:toastification/toastification.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        Navigator.pushReplacementNamed(
          context,
          '/explore',
        ).then((value) => {_refreshPost()});
      }
      if (index == 2) {
        Navigator.pushNamed(
          context,
          '/create_post',
        ).then((value) => {_refreshPost()});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    Provider.of<PostViewModel>(context, listen: false).fetchPosts();
  }

  _refreshPost() {
    Provider.of<PostViewModel>(context, listen: false).fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    final postViewModel = Provider.of<PostViewModel>(context);

    if (postViewModel.errorMessage.isNotEmpty) {
      if (postViewModel.errorMessage == 'Unauthorized') {
        // Go login page
        Navigator.pushReplacementNamed(context, '/');
      }

      // Show error message
      Future.microtask(
        () => toastification.show(
          title: Text(postViewModel.errorMessage),
          type: ToastificationType.error,
          autoCloseDuration: const Duration(seconds: 5),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SnapGram',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.favorite_border), onPressed: () {}),
          IconButton(icon: Icon(Icons.chat), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Story
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  _buildStoryItem('Your Story'),
                  for (var i = 0; i < 10; i++) _buildStoryItem('User $i'),
                ],
              ),
            ),
            postViewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: postViewModel.posts.length,
                  itemBuilder: (context, index) {
                    final post = postViewModel.posts[index];
                    print('${ApiService.baseUrl}${post.imageUrl}');
                    return PostItem(
                      context: context,
                      postViewModel: postViewModel,
                      username: post.username,
                      postId: post.id,
                      imagePath: '${ApiService.baseUrl}${post.imageUrl}',
                      initialLikes: post.likeCount,
                      initialLiked: post.liked,
                      date: post.createdAt,
                      caption: post.caption,
                    );
                  },
                ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }

  Widget _buildStoryItem(String name) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          CircleAvatar(
            radius: 30,
            backgroundColor: Color(Random().nextInt(0xffffffff)),
          ),
          Text(name),
        ],
      ),
    );
  }
}
