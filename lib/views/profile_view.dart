import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapgram/viewModels/profile_view_model.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    Provider.of<ProfileViewModel>(context, listen: false).fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body:
          profileViewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Row(children: [Text(profileViewModel.profile!.username)]),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0,
                      ),
                      itemCount: profileViewModel.profile?.posts.length,
                      itemBuilder: (context, index) {
                        final post = profileViewModel.profile?.posts[index];
                        return Image.network(
                          'http://10.0.2.2:8080${post?.imageUrl}',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
