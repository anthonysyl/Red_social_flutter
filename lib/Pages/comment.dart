import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class Comments extends StatefulWidget {
  final postid;
  const Comments({Key? key,this.postid}): super(key: key);
  @override
  State<Comments>createState() => _CommentsState();

}
class _CommentsState extends State <Comments>
{
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final commentDecoration = InputDecoration(
    hintText: 'Write a comment',
    hintStyle: TextStyle(color: Colors.black),
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(vertical: 20.2),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(1),
      borderSide: BorderSide(color: Colors.transparent),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(1),
    ),
    prefixIcon: Icon(Icons.person_outline_outlined),
  );
  final commentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder(
                stream: _firestore.collection('Posts').doc(widget.postid).collection(
                    'Comments').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot>snapshot) {
                  List<Widget>cards = [];
                  if(snapshot.hasData)

                    {
                      snapshot.data?.docs.forEach((element) {
                        cards.add(
                            Card(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(backgroundImage: NetworkImage(
                                          element['uploaderImage']),),
                                      Text(element['Uploader'])

                                    ],
                                  ),
                                  Text(element ['Comments'])
                                ],
                              ),
                            )
                        );
                      });

                    }

                  return Column(
                    children: cards

                  );
                }),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onSubmitted: (a) async{
                var name = _auth.currentUser!.displayName;
                var uploaderImage = _auth.currentUser!.photoURL;
                await _firestore.collection('Comments').doc(widget.postid).collection('Comments').add({
                    'Uploader' : name,
                    'UploaderImage' : uploaderImage,
                    'Comment' : a
                  });
              },
              controller: commentController,
              decoration: commentDecoration,
            ),
          ),

          ],
        ),
      ),
    );
    }
  }
