import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'profile.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final controller = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final decorationTextField = InputDecoration(
    hintText: '¿Qué deseas comentar?.... ',
    hintStyle: GoogleFonts.alice(color: Colors.grey),
  );

  XFile? _image;

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
    }
  }

  Future<void> _createPost(String comment, XFile? image) async {
    final user = _firestore.collection('Posts').doc();

    if (image != null) {
      final imageStorageRef =
      FirebaseStorage.instance.ref().child('post_images/${user.id}.jpg');
      final uploadTask = imageStorageRef.putFile(File(image.path));
      final TaskSnapshot uploadSnapshot = await uploadTask.whenComplete(() {});

      final imageUrl = await uploadSnapshot.ref.getDownloadURL();

      await user.set({
        'comment': comment,
        'uploader': currentUser?.displayName ?? 'Unknown',
        'imageUrl': imageUrl,
        'likes': 0, // Initialize likes count to 0
      });
    } else {
      await user.set({
        'comment': comment,
        'uploader': currentUser?.displayName ?? 'Unknown',
        'likes': 0, // Initialize likes count to 0
      });
    }
  }

  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Welcome',
                        style: GoogleFonts.ubuntu(
                          color: Colors.blueAccent,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Profile()),
                          );
                          // Navegar a la página de perfil
                          // Implementa la navegación a la página de perfil aquí
                        },
                        icon: Icon(
                          Icons.person,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.grey),
                SizedBox(height: 10),
                Container(
                  height: 50,
                  child: TextField(
                    onSubmitted: (s) {
                      _createPost(s, _image);
                    },
                    controller: controller,
                    decoration: decorationTextField,
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Seleccionar foto'),
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Nuevas publicaciones',
                      style: GoogleFonts.alice(
                        color: Colors.blueAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('Posts').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final cards = snapshot.data!.docs.map((element) {
                        final postId = element.id;
                        final uploader = element['uploader'] ?? '';
                        final comment = element['comment'] ?? '';
                        final imageUrl = element['imageUrl'] ?? '';

                        return PostCard(
                          postId: postId,
                          comment: comment,
                          uploader: uploader,
                          imageUrl: imageUrl,
                        );
                      }).toList();

                      return cards.isNotEmpty
                          ? Column(
                        children: cards,
                      )
                          : Container();
                    } else {
                      return Container();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final String postId;
  final String comment;
  final String uploader;
  final String imageUrl;

  const PostCard({
    required this.postId,
    required this.comment,
    required this.uploader,
    required this.imageUrl,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool _isLiked = false;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchLikeCount();
  }

  Future<void> _fetchLikeCount() async {
    final postDoc = await _firestore.collection('Posts').doc(widget.postId).get();
    final likes = postDoc.data()?['likes'] ?? 0;

    setState(() {
      _likeCount = likes;
    });
  }

  Future<void> _toggleLike() async {
    final userId = _auth.currentUser?.uid;

    if (userId != null) {
      final postDoc = _firestore.collection('Posts').doc(widget.postId);

      final likeRef = postDoc.collection('likes').doc(userId);
      final likeDoc = await likeRef.get();

      if (likeDoc.exists) {
        await likeRef.delete();
        setState(() {
          _isLiked = false;
          _likeCount -= 1;
        });
      } else {
        await likeRef.set({});
        setState(() {
          _isLiked = true;
          _likeCount += 1;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.uploader,
              style: GoogleFonts.alice(color: Colors.grey),
            ),
            Divider(),
            Text(
              widget.comment,
              style: GoogleFonts.alice(),
              textAlign: TextAlign.left,
            ),
            if (widget.imageUrl.isNotEmpty) SizedBox(height: 10),
            if (widget.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity, // Asegura que la imagen ocupe todo el ancho disponible
                  height: 200, // Establece una altura fija para evitar cambios en la relación de aspecto
                ),
              ),
            SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  onPressed: _toggleLike,
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : null,
                  ),
                ),
                Text(_likeCount.toString()),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommentPage(
                          postId: widget.postId,
                          comments: _firestore
                              .collection('Posts')
                              .doc(widget.postId)
                              .collection('comments'),
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.comment),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class CommentPage extends StatefulWidget {
  final String postId;
  final CollectionReference comments;

  const CommentPage({
    Key? key,
    required this.postId,
    required this.comments,
  }) : super(key: key);

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: widget.comments.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final comments = snapshot.data!.docs.map((element) {
                    final comment = element['comment'] ?? '';

                    return ListTile(
                      title: Text(comment),
                    );
                  }).toList();

                  return comments.isNotEmpty
                      ? ListView(
                    children: comments,
                  )
                      : Container();
                } else {
                  return Container();
                }
              },
            ),
          ),
          Divider(),
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final comment = controller.text.trim();

                    if (comment.isNotEmpty) {
                      final name = _auth.currentUser?.displayName;

                      await widget.comments.add({
                        'comment': comment,
                        'user': name,
                      });

                      controller.clear();
                    }
                  },
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PostService {
  final _firestore = FirebaseFirestore.instance;
  late User? currentUser;

  Future<void> createPost(String title, XFile? image) async {
    final user = _firestore.collection('Posts').doc();

    if (image != null) {
      final imageStorageRef =
      FirebaseStorage.instance.ref().child('post_images/${user.id}.jpg');
      final uploadTask = imageStorageRef.putFile(File(image.path));
      final TaskSnapshot uploadSnapshot = await uploadTask.whenComplete(() {});

      final imageUrl = await uploadSnapshot.ref.getDownloadURL();

      await user.set({
        'title': title,
        'uploader': currentUser?.displayName ?? 'Unknown',
        'imageUrl': imageUrl,
        'likes': 0, // Initialize likes count to 0
      });
    } else {
      await user.set({
        'title': title,
        'uploader': currentUser?.displayName ?? 'Unknown',
        'likes': 0, // Initialize likes count to 0
      });
    }
  }
}
