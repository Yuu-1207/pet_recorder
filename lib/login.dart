//ログイン画面と新規登録画面

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';

//ログイン画面
class UserLoginPage extends StatefulWidget {@override
  @override
  State<UserLoginPage> createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final _auth = FirebaseAuth.instance;
  // 入力したメールアドレス・パスワード
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('ログイン画面'),
      ),
      body: Container(
        padding: const EdgeInsets.all(60),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'メールアドレス',
                  style: TextStyle(fontSize: 18),
                ),
                TextField(
                  style: const TextStyle(fontSize: 20),
                  onChanged: (value) {
                    email = value;
                  },
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.all(15)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'パスワード',
                  style: TextStyle(fontSize: 18),
                ),
                TextField(
                  style: const TextStyle(fontSize: 20),
                  onChanged: (value) {
                    password = value;
                  },
                  obscureText: true,
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.all(20)),
            ElevatedButton(
              child: const Text(
                'ログイン',
                style: TextStyle(fontSize: 15),
              ),
              onPressed: () async {
                try {
                  final newUser = await _auth.signInWithEmailAndPassword(
                    email: email, password: password);
                  if (newUser != null) {
                    if (!mounted) return;
                    Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => MyHomePage()));
                  }
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'invalid-email') {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ログインできません'),
                      ),
                    );
                    //print('メールアドレスのフォーマットが正しくありません');
                  } else if (e.code == 'user-disabled') {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('現在指定したメールアドレスは使用できません'),
                      ),
                    );
                    //print('現在指定したメールアドレスは使用できません');
                  } else if (e.code == 'user-not-found') {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('指定したメールアドレスは登録されていません'),
                      ),
                    );
                    //print('指定したメールアドレスは登録されていません');
                  } else if (e.code == 'wrong-password') {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('パスワードが間違っています'),
                      ),
                    );
                    //print('パスワードが間違っています');
                  }
                }
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Register()));
              },
              child: const Text('新規登録はこちらから')
            )
          ],
        ),
      ),
    );
  }
}

//新規登録画面
class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  //ステップ１
  final _auth = FirebaseAuth.instance;

  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新規登録'),
      ),
      body: Container(
        padding: const EdgeInsets.all(60),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'メールアドレス',
                  style: TextStyle(fontSize: 18),
                ),
                TextField(
                  style: const TextStyle(fontSize: 20),
                  onChanged: (value) {
                    email = value;
                  },
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.all(15)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'パスワード',
                  style: TextStyle(fontSize: 18),
                ),
                TextField(
                  style: const TextStyle(fontSize: 20),
                  onChanged: (value) {
                    password = value;
                  },
                  obscureText: true,
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.all(20)),
            ElevatedButton(
              child: const Text(
                '新規登録',
                style: TextStyle(fontSize: 15),
              ),
              onPressed: () async {
                try {
                  final newUser = await _auth.createUserWithEmailAndPassword(
                    email: email, password: password);
                  if (newUser != null) {
                    if (!mounted) return;
                    Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => MyHomePage()));
                  }
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'email-already-in-use') {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('指定したメールアドレスは登録済みです'),
                      ),
                    );
                    //print('指定したメールアドレスは登録済みです');
                  } else if (e.code == 'invalid-email') {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('メールアドレスのフォーマットが正しくありません'),
                      ),
                    );
                    //print('メールアドレスのフォーマットが正しくありません');
                  } else if (e.code == 'operation-not-allowed') {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('指定したメールアドレス・パスワードは現在使用できません'),
                      ),
                    );
                    //print('指定したメールアドレス・パスワードは現在使用できません');
                  } else if (e.code == 'weak-password') {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('パスワードは６文字以上にしてください'),
                      ),
                    );
                    //print('パスワードは６文字以上にしてください');
                  }
                }
              },
            ),
          ],
        )
      )
    );
  }
}