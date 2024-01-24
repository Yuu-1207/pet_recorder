//ペット登録画面

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'main.dart';

class PetAddPage extends StatefulWidget {
  @override
  State<PetAddPage> createState() => _PetAddPageState();
}

class _PetAddPageState extends State<PetAddPage> {
  final TextEditingController dateController = TextEditingController();
  String petName = '';
  int year = 0;
  int month = 0;
  int day = 0;
  String weight = '';
  String foodName = '';
  String content = '';
  String daily = '';

  var image;
  final imagePicker = ImagePicker();
  // ギャラリーから写真を取得
  Future getImageFromGarally() async {
      final XFile? pickedFile =
          await imagePicker.pickImage(source: ImageSource.gallery);
      if(pickedFile != null) {
        final Uint8List uint8list = await XFile(pickedFile.path).readAsBytes();
        setState(() {
          image = uint8list;
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ペット登録'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 60),
        child: SingleChildScrollView(
        child: Column(
          children: [
            //写真(タップすると写真変更)
            GestureDetector(
              onTap: getImageFromGarally,
              child: SizedBox(
                width: 250,
                height: 180,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: image == null
                      ? const Image(image: AssetImage('assets/petImage.png'))
                      : Image.memory(image),
                ),
              ),
            ),
            const Text('犬をタップすると画像を登録できます'),
            const Padding(padding: EdgeInsets.all(5)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '名前',
                  style: TextStyle(fontSize: 18),
                ),
                TextField(
                  style: const TextStyle(fontSize: 20),
                  onChanged: (value) {
                    setState(() {
                      petName = value;
                    });
                  },
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.all(15)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '生年月日',
                  style: TextStyle(fontSize: 18),
                ),
                TextField(
                  style: const TextStyle(fontSize: 20),
                  controller: dateController,
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    DatePicker.showDatePicker(context,
                        showTitleActions: true,
                        minTime: DateTime(1950, 1, 1),
                        maxTime: DateTime.now(), onConfirm: (date) {
                      dateController.value = TextEditingValue(
                        text: '${date.year}/${date.month}/${date.day}',
                      );
                      setState(() {
                        year = date.year;
                        month = date.month;
                        day = date.day;
                      });
                    }, locale: LocaleType.jp);
                  },
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.all(15)),
            const Text(
              '食べているフードについて',
              style: TextStyle(fontSize: 20),
            ),
            const Padding(padding: EdgeInsets.all(5)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '名前',
                  style: TextStyle(fontSize: 18),
                ),
                TextField(
                  style: const TextStyle(fontSize: 20),
                  onChanged: (value) {
                    setState(() {
                      foodName = value;
                    });
                  },
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.all(15)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '内容量(g)',
                  style: TextStyle(fontSize: 18),
                ),
                TextField(
                  style: const TextStyle(fontSize: 20),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      content = value;
                    });
                  },
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.all(15)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '1日に食べる量(g)',
                  style: TextStyle(fontSize: 18),
                ),
                TextField(
                  style: const TextStyle(fontSize: 20),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+(\.\d*)?')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      daily = value;
                    });
                  },
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.all(20)),
            ElevatedButton(
                onPressed: () async {
                  if(image != null) {
                    var metadata = SettableMetadata(contentType: "image/jpeg",);
                    FirebaseStorage.instance.ref('${email}/pet.jpeg').putData(image, metadata);
                  }
                  final snapshot = await db.collection('petInfo').count().get();
                  final petInfoLength = snapshot.count;
                  //ペット登録用ドキュメント作成
                  await FirebaseFirestore.instance
                      .collection('user')
                      .doc(email)
                      .collection('petInfo')
                      .doc('${petInfoLength}') //ドキュメントのインデックスをドキュメント名にする(削除すると順番狂う)
                      .set({
                    'petName': petName,
                    'year': year,
                    'month': month,
                    'day': day,
                    'foodName': foodName,
                    'content': int.parse(content),
                    'daily': double.parse(daily),
                  });
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return MyHomePage();
                  }));
                },
                child: const Text(
                  '登録',
                  style: TextStyle(fontSize: 20),
                )),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('キャンセル')),
          ],
        ),
        ),
      ),
    );
  }
}
