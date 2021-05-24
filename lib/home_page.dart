import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_firebase/explorer_page.dart';
import 'package:universal_io/io.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController bioController = TextEditingController();
  TextEditingController userController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;

  File _pickedImage;
  void _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(
        source: ImageSource.camera, imageQuality: 50, maxWidth: 150);
    final pickedImageFile = File(pickedImage.path);
    setState(() {
      _pickedImage = pickedImageFile;
    });
  }

  uploadUser() async {
    if (formKey.currentState.validate()) {
      if (_pickedImage == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('choose picture')));
      } else {
        try {
          final ref = FirebaseStorage.instance
              .ref()
              .child('user_image')
              .child(userController.text + '.jpg');
          await ref.putFile(_pickedImage);
          String url = await ref.getDownloadURL();
          FirebaseFirestore.instance
              .collection('users')
              .doc(userController.text)
              .set({
            'bio': bioController.text,
            'username': userController.text,
            'pictureUrl': url,
            'likeStatus': 'No One'
          });
        } catch (e) {
          print(e);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 170),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CircleAvatar(
                radius: 80,
                backgroundImage:
                    _pickedImage == null ? null : FileImage(_pickedImage),
              ),
              SizedBox(
                height: 10,
              ),
              TextButton(onPressed: _pickImage, child: Text('Choose picture')),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: userController,
                      onChanged: (val) {
                        val = userController.text;
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        labelText: 'UserName',
                      ),
                      validator: (value) {
                        return value.length > 4
                            ? null
                            : "Enter username 4+ characters";
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      controller: bioController,
                      decoration: InputDecoration(
                        labelText: 'Bio',
                      ),
                      validator: (value) {
                        return value.length > 3
                            ? null
                            : "Enter username 3+ characters";
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextButton(onPressed: uploadUser, child: Text('Upload')),
                    TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => ExplorerPage()));
                        },
                        child: Text('Go to Explorer Page'))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
