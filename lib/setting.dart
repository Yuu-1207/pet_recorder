//ユーザー情報画面

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';
import 'login.dart';

/*
class settingPage extends StatefulWidget {
  @override
  State<settingPage> createState() => _settingPageState();
}

class _settingPageState extends State<settingPage> {
  /*
  String selectedValue = '色変更';
  final lists = ['紫', '白', '赤', 'ピンク', '青', '緑', '黄色', '黒'];
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ユーザー情報'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Card(
              child: ListTile(
                title: const Text('ユーザー情報'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return UserInfoPage();
                  }));
                },
              )
            ),
            /*
            PopupMenuButton<String>(
              child: Card(
                child: ListTile(
                  title: Text(selectedValue),
                )
              ),
              itemBuilder: (BuildContext context) {
                return lists.map((String list) {
                  return PopupMenuItem(
                    value: list,
                    child: Text(list),
                  );
                }).toList();
              },
              onSelected: (String list) {
                setState(() {
                  selectedValue = list;
                });
              },
            ),
            */
          ],
        ),
      ),
    );
  }
}
*/

//ユーザー情報画面
class UserInfoPage extends StatefulWidget {
  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final _auth = FirebaseAuth.instance;
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ユーザー情報'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'メールアドレス',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              email,
              style: TextStyle(fontSize: 20),
            ),
            const Padding(padding: EdgeInsets.all(10)),
            Card(
              child: ListTile(
                title: const Text(
                  'ログアウト',
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
                onTap: () async {
                  await _auth.signOut();
                  if (_auth.currentUser == null) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ログアウトしました'),
                      ),
                    );
                  }
                  if (!mounted) return;
                  Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => UserLoginPage()));
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}