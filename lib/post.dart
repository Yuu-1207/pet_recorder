//投稿閲覧画面,投稿追加画面

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'main.dart';

//投稿閲覧画面
class PostPage extends StatefulWidget {
  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  // 入力した投稿メッセージ
  String messageText = '';
  DateFormat outputFormat = DateFormat('yyyy/MM/dd H:m');
  String petName =
      petInfoArguments?.petName != null ? petInfoArguments.petName : '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('投稿閲覧画面'),
      ),
      body: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            children: [
              Expanded(
                // StreamBuilder(リアルタイム更新)
                // 非同期処理の結果を元にWidgetを作れる
                child: StreamBuilder<QuerySnapshot>(
                  // 投稿メッセージ一覧を取得（非同期処理）
                  // 投稿日時でソート
                  stream: FirebaseFirestore.instance
                      .collection('user')
                      .doc(email)
                      .collection('posts')
                      .orderBy('date', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    // データが取得できた場合
                    if (snapshot.hasData) {
                      final List<DocumentSnapshot> documents =
                          snapshot.data!.docs;
                      // 取得した投稿メッセージ一覧を元にリスト表示
                      return ListView(
                        children: documents.map((document) {
                          DateTime postDate = DateTime.now();
                          if (document['date'] is Timestamp) {
                            postDate = document['date'].toDate();
                          }
                          return Card(
                            child: ListTile(
                              isThreeLine: true,
                              title: Text('${petName}\n${document['text']}'),
                              subtitle: Text(
                                  '${outputFormat.format(postDate)}'),
                              // 自分の投稿メッセージの場合は削除ボタンを表示
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  // 投稿メッセージのドキュメントを削除
                                  await FirebaseFirestore.instance
                                      .collection('user')
                                      .doc(email)
                                      .collection('posts')
                                      .doc(document.id)
                                      .delete();
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }
                    // データが読込中の場合
                    return const Center(
                      child: Text('読込中...'),
                    );
                  },
                ),
              ),
            ],
          )),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          //投稿画面に遷移
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return AddPostPage();
          }));
        },
      ),
    );
  }
}

//投稿追加画面
class AddPostPage extends StatefulWidget {
  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  // 入力した投稿メッセージ
  String messageText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ペットの近況を共有'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: '投稿を入力...',
                alignLabelWithHint: true,
              ),
              // 複数行のテキスト入力
              keyboardType: TextInputType.multiline,
              // 最大3行
              maxLines: 5,

              onChanged: (String value) {
                setState(() {
                  messageText = value;
                });
              },
            ),
            const Padding(padding: EdgeInsets.all(12)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize:
                    const Size.fromWidth(double.maxFinite), //横幅にmaxFiniteを指定
              ),
              onPressed: () async {
                final date = DateTime.now().toLocal(); // 現在の日時
                // 投稿メッセージ用ドキュメント作成
                await FirebaseFirestore.instance
                    .collection('user')
                    .doc(email)
                    .collection('posts') // コレクションID指定
                    .doc() // ドキュメントID自動生成
                    .set({'text': messageText, 'date': date});
                // 1つ前の画面に戻る
                Navigator.of(context).pop();
              },
              child: const Text(
                '投稿',
                style: TextStyle(fontSize: 20),
              ),
            )
          ],
        ),
      ),
    );
  }
}
