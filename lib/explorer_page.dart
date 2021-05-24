import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:test_firebase/home_page.dart';

class ExplorerPage extends StatefulWidget {
  @override
  _ExplorerPageState createState() => _ExplorerPageState();
}

class _ExplorerPageState extends State<ExplorerPage> {
   getUser()  {
    return  FirebaseFirestore.instance.collection('users').snapshots();
  }

  @override
  void initState() {
    getUser();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: TextButton(
            child: Text(
              'back',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (c) => HomePage()));
            },
          ),
        ),
        body: Container(
          padding: EdgeInsets.only(top: 50),
          child: Column(children: [
            Center(
              child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder:
                    (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                  Random random = Random();
                  int randomNumber =
                      random.nextInt(streamSnapshot.data.docs.length);

                  if (streamSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else
                    return streamSnapshot.hasData
                        ? Column(children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(streamSnapshot.data
                                          .docs[randomNumber]['pictureUrl'] ==
                                      null
                                  ? null
                                  : streamSnapshot.data.docs[randomNumber]
                                      ['pictureUrl']),
                              radius: 100,
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(streamSnapshot.data.docs[randomNumber]['bio']),
                            SizedBox(
                              height: 25,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FloatingActionButton(
                                  backgroundColor: Colors.green.shade300,
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(streamSnapshot.data
                                            .docs[randomNumber]['username'])
                                        .update({'likeStatus': 'liked'});
                                    setState(() {});
                                  },
                                  child: Text('Like'),
                                ),
                                SizedBox(
                                  width: 16,
                                ),
                                FloatingActionButton(
                                  backgroundColor: Colors.red.shade300,
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(streamSnapshot.data
                                            .docs[randomNumber]['username'])
                                        .update({'likeStatus': 'No one'});
                                    setState(() {});
                                  },
                                  child: Text('No'),
                                ),
                              ],
                            )
                          ])
                        : CircularProgressIndicator();
                },
              ),
            ),
          ]),
        ));
  }
}
