import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uni_connect_clone/Pages/DBHelper/Login_auth.dart';
import 'package:uni_connect_clone/Pages/Landing.dart';
import 'package:image_picker/image_picker.dart';

class UpdateProfile extends StatefulWidget {
  UpdateProfile({Key? key}) : super(key: key);

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile>
    with SingleTickerProviderStateMixin {
  final nameDecoration = InputDecoration(
    hintText: 'Ingresa tu nombre',
    hintStyle: GoogleFonts.poppins(color: Colors.black),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.white),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.white),
    ),
    filled: true,
    fillColor: Colors.white,
  );
  final controller = TextEditingController();

  var image;
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
            .drive(Tween<double>(begin: 0, end: 1));

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[100],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 50),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isLoading = true;
                    });

                    LogIn.uploadProfilePick().then((value) {
                      setState(() {
                        image = value;
                      });
                    });
                    setState(() {
                      isLoading = false;
                    });
                  },
                  child: CircleAvatar(
                    backgroundImage: image != null ? NetworkImage(image) : null,
                    backgroundColor: Colors.transparent,
                    radius: 70,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: CircleAvatar(
                          backgroundImage:
                          image != null ? NetworkImage(image) : null,
                          radius: 60,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: controller,
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      shadows: [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.white.withOpacity(0.5),
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                    decoration: nameDecoration,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 10 * _animation.value),
                        child: MaterialButton(
                          minWidth: double.infinity,
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                            });
                            LogIn.updateProfile(
                                name: controller.text.trim(),
                                context: context,
                                image: image);
                            setState(() {
                              isLoading = false;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              'Siguiente',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 2,
                                    color: Colors.black.withOpacity(0.3),
                                    offset: Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: Colors.cyanAccent,
                          elevation: 5,
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Nota: Para agregar una foto, presiona el botón "Siguiente".',
                    style: GoogleFonts.poppins(color: Colors.black),
                  ),
                ),
              ],
            ),
            Center(
              child: Visibility(
                visible: isLoading,
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
