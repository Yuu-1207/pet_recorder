//ペット編集画面

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'main.dart';
import 'petInfoArguments.dart';

class PetEditPage extends StatefulWidget {
  @override
  State<PetEditPage> createState() => _PetEditPageState();
}

class _PetEditPageState extends State<PetEditPage> {
  String petName =
      petInfoArguments?.petName != null ? petInfoArguments!.petName : '';
  int year = petInfoArguments?.year != null ? petInfoArguments!.year : 0;
  int month = petInfoArguments?.month != null ? petInfoArguments!.month : 0;
  int day = petInfoArguments?.day != null ? petInfoArguments!.day : 0;
  final TextEditingController dateController = TextEditingController(
      text:
          '${petInfoArguments?.year}/${petInfoArguments?.month}/${petInfoArguments?.day}');
  //String weight = '';
  String foodName =
      petInfoArguments?.foodName != null ? petInfoArguments!.foodName : '';
  String content =
      petInfoArguments?.content != null ? '${petInfoArguments!.content}' : '';
  String daily =
      petInfoArguments?.daily != null ? '${petInfoArguments!.daily}' : '';

  var image = petImage;
  final imagePicker = ImagePicker();
  // ギャラリーから写真を取得
  Future getImageFromGarally() async {
    final XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
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
        title: const Text('ペット情報を編集'),
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
              const Text('画像をタップすると変更できます'),
              const Padding(padding: EdgeInsets.all(5)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '名前',
                    style: TextStyle(fontSize: 18),
                  ),
                  TextFormField(
                    style: const TextStyle(fontSize: 20),
                    initialValue: petName,
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
                  TextFormField(
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
                  TextFormField(
                    style: const TextStyle(fontSize: 20),
                    initialValue: foodName,
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
                  TextFormField(
                    style: const TextStyle(fontSize: 20),
                    initialValue: content,
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
                  TextFormField(
                    style: const TextStyle(fontSize: 20),
                    initialValue: daily,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+(\.\d*)?')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        daily = value;
                      });
                    },
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.all(17)),
              ElevatedButton(
                  onPressed: () async {
                    //ペット登録用ドキュメント作成
                    await FirebaseFirestore.instance
                        .collection('user')
                        .doc(email)
                        .collection('petInfo')
                        .doc('0')
                        .update({
                      'petName': petName,
                      'year': year,
                      'month': month,
                      'day': day,
                      'foodName': foodName,
                      'content': int.parse(content),
                      'daily': double.parse(daily),
                    });
                    petInfoArguments = PetInfoArguments(petName, year, month, day, foodName, int.parse(content), double.parse(daily));

                    await FirebaseStorage.instance
                        .ref('${email}/pet.jpeg')
                        .delete();
                    if (image != null) {
                      var metadata = SettableMetadata(
                        contentType: "image/jpeg",
                      );
                      FirebaseStorage.instance
                          .ref('${email}/pet.jpeg')
                          .putData(image, metadata);
                    }
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return MyHomePage();
                    }));
                  },
                  child: const Text(
                    '登録',
                    style: TextStyle(fontSize: 20),
                  )),
              const Padding(padding: EdgeInsets.all(5)),
              ElevatedButton(
                  onPressed: () async {
                    petInfoArguments = PetInfoArguments('', 0, 0, 0, '', 0, 0);
                    await FirebaseFirestore.instance
                        .collection('user')
                        .doc(email)
                        .collection('petInfo')
                        .doc('0')
                        .delete();

                    await FirebaseStorage.instance
                        .ref('${email}/pet.jpeg')
                        .delete();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return MyHomePage();
                    }));
                  },
                  child: const Text(
                    'ペットを削除',
                    style: TextStyle(color: Colors.red, fontSize: 20),
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
