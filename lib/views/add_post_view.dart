import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapgram/viewModels/add_post_view_model.dart';
import 'package:toastification/toastification.dart';

class AddPostView extends StatefulWidget {
  const AddPostView({super.key});

  @override
  State<AddPostView> createState() => _AddPostViewState();
}

class _AddPostViewState extends State<AddPostView> {
  final TextEditingController _captionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AddPostViewModel(),
      child: Consumer<AddPostViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isSuccess) {
            // Go back
            Navigator.pop(context, true);

            // Show success message
            Future.microtask(
              () => toastification.show(
                title: Text('Post added'),
                autoCloseDuration: const Duration(seconds: 5),
              ),
            );
          } else if (viewModel.errorMessage.isNotEmpty) {
            if (viewModel.errorMessage == 'Unauthorized') {
              // Go login page
              Navigator.pushReplacementNamed(context, '/');
            }

            // Show error message
            Future.microtask(
              () => toastification.show(
                title: Text(viewModel.errorMessage),
                type: ToastificationType.error,
                autoCloseDuration: const Duration(seconds: 5),
              ),
            );
          }

          return viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Scaffold(
                appBar: AppBar(
                  title: const Text('Add Post'),
                  actions: [
                    IconButton(
                      onPressed: () {
                        if (viewModel.selectedImage != null) {
                          viewModel.addPost(
                            viewModel.caption,
                            viewModel.selectedImage!,
                          );
                        } else {
                          // Show error if image is missing or form is invalid
                          if (viewModel.selectedImage == null) {
                            toastification.show(
                              title: const Text('Please select an image.'),
                              type: ToastificationType.error,
                              autoCloseDuration: const Duration(seconds: 5),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.check),
                    ),
                  ],
                ),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => viewModel.selectImage(),
                        child: Container(
                          height: 300,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child:
                              viewModel.selectedImage != null
                                  ? Image.file(
                                    viewModel.selectedImage!,
                                    fit: BoxFit.cover,
                                  )
                                  : const Center(
                                    child: Icon(Icons.add_a_photo),
                                  ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          controller: _captionController,
                          onChanged: (text) => viewModel.updateCaption(text),
                          maxLines: null,
                          decoration: const InputDecoration(
                            hintText: 'Write a caption...',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
        },
      ),
    );
  }
}
