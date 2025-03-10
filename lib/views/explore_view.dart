import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapgram/viewModels/post_view_model.dart';
import 'package:toastification/toastification.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({super.key});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  int _selectedIndex = 1;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushReplacementNamed(context, '/home');
      }
      if (index == 2) {
        Navigator.pushNamed(context, '/create_post');
      }
    });
  }

  @override
  void initState() {
    super.initState();
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
      appBar: AppBar(title: Text('Explore')),
      body:
          postViewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                ),
                itemCount: postViewModel.posts.length,
                itemBuilder: (context, index) {
                  final post = postViewModel.posts[index];
                  return Image.network(
                    'http://10.0.2.2:8080${post.imageUrl}',
                    fit: BoxFit.cover,
                  );
                },
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
}
