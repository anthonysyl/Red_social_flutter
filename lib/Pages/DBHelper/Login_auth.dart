
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uni_connect_clone/Pages/Landing.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uni_connect_clone/Pages/updateProfile.dart';

class LogIn {
  static Future login(email, password, BuildContext context) async {
    final _auth = FirebaseAuth.instance;
    try {
      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LandingPage()));
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  static Future signUp(email, password, BuildContext context) async {
    final _auth = FirebaseAuth.instance;
    try {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => UpdateProfile()));
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }
  signInWithGoogle()async
  {
    final GoogleSignInAccount? googleUser = await GoogleSignIn(
      scopes: <String>["email"]).signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);



  }

  static Future<String?> uploadProfilePick() async {
    final _storage = FirebaseStorage.instance;
    try {
      var image = await ImagePicker().pickImage(source: ImageSource.gallery);
      var uploadTask = _storage.ref(image!.name).putFile(File(image.path));
      var snapshot = await uploadTask;
      var downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      return null;
    }
  }

  static Future updateProfile({name ,context, image}) async {
    final _auth = FirebaseAuth.instance;
    var image = await uploadProfilePick();
    if (image == null) {
      Fluttertoast.showToast(msg: 'Error al cargar la imagen');
      return;
    }
    try {
      await _auth.currentUser!.updateDisplayName(name);
      await _auth.currentUser!.updatePhotoURL(image);
      Navigator.push(context, MaterialPageRoute(builder: (context)=>LandingPage()));
      Fluttertoast.showToast(msg: 'Perfil actualizado con éxito');
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }
}
