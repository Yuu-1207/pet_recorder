import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'firebase_options.dart';
import 'package:image_picker/image_picker.dart';
import 'petAdd.dart';
import 'setting.dart';
import 'login.dart';
import 'post.dart';
import 'petEdit.dart';
import 'petInfoArguments.dart';

final db = FirebaseFirestore.instance;

PetInfoArguments petInfoArguments = PetInfoArguments('', 0, 0, 0, '', 0, 0);
var petImage;

String email = '';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: UserLoginPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String petName = petInfoArguments.petName;
  int year = petInfoArguments.year;
  int month = petInfoArguments.month;
  int day = petInfoArguments.day;
  String foodName = petInfoArguments.foodName;
  int content = petInfoArguments.content;
  double daily = petInfoArguments.daily;

  final imagePicker = ImagePicker();

  RegExp reg = RegExp(r'\.0+$');

  //画像を取得
  Future<Image> getImage() async {
    final Reference ref = FirebaseStorage.instance.ref();
    //.getDownloadURL()回数制限あり
    final imageUrl = await ref.child('${email}/pet.jpeg').getDownloadURL();
    petImage = (await NetworkAssetBundle(Uri.parse(imageUrl)).load(imageUrl))
        .buffer
        .asUint8List();
    return Image.network(imageUrl);
  }
  
  //データベースからペットのデータを取得
  void getPetData(int petNumber) {
    print('getpetdata');
    final docRef = db
        .collection('user')
        .doc(email)
        .collection('petInfo')
        .doc('${petNumber}');
    docRef.get().then(
      (DocumentSnapshot document) {
        if (document.exists) {
          setState(() {
          petName = document['petName'];
          year = document['year'];
          month = document['month'];
          day = document['day'];
          foodName = document['foodName'];
          content = document['content'];
          daily = document['daily'];
          });
        }
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(petName),
        actions: [
          IconButton(
              onPressed: () {
                petInfoArguments = PetInfoArguments(
                    petName, year, month, day, foodName, content, daily);
                //投稿画面に遷移
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return PostPage();
                }));
              },
              icon: const Icon(Icons.view_list))
        ],
      ),
      //メニュー表示
      drawer: Drawer(
        child: ListView(
          children: [
            const SizedBox(
                height: 70,
                child: DrawerHeader(
                  child: Text('メニュー'),
                )),
            ListTile(
              title: const Text('ペット登録'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return PetAddPage();
                }));
              },
            ),
            ListTile(
              title: const Text('ユーザー情報'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return UserInfoPage();
                }));
              },
            )
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 50),
        child: RefreshIndicator(
          onRefresh: () async {
            getPetData(0);
          },
          child: ListView(
            children: [
              SizedBox(
                width: 250,
                height: 180,
                child: FutureBuilder(
                  future: getImage(),
                  builder: (BuildContext context,
                      AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData) {
                      return FittedBox(
                        fit: BoxFit.contain, child: snapshot.data);
                    } else {
                      return const FittedBox(
                        fit: BoxFit.contain,
                          child: Image(image: AssetImage('assets/petImage.png')));
                              }
                            })),
                    //エサ情報
                    const Padding(padding: EdgeInsets.all(10)),
                    const Text(
                      '1日に食べるフード量',
                      style: TextStyle(fontSize: 25),
                      textAlign: TextAlign.center,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 3, horizontal: 15),
                            child: Text(
                              '${daily}'.replaceAll(reg, ''),
                              style: const TextStyle(fontSize: 30),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const Text(
                          'g',
                          style: TextStyle(fontSize: 20),
                        )
                      ],
                    ),
                    const Padding(padding: EdgeInsets.all(10)),
                    for (int i = 2; i < 5; i++)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${i}回分け',
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 25),
                          SizedBox(
                            width: 80,
                            height: 50,
                            child: Card(
                                child: Center(
                              child: Text(
                                '${(daily / i).toStringAsFixed(1)}'
                                    .replaceAll(reg, ''),
                                style: const TextStyle(fontSize: 25),
                              ),
                            )),
                          ),
                          const Text(
                            'g',
                            style: TextStyle(fontSize: 18),
                          )
                        ],
                      ),

                    const Padding(padding: EdgeInsets.all(17)),
                    Column(
                      children: [
                        const Text(
                          '食べているフード',
                          style: TextStyle(fontSize: 20),
                        ),
                        Center(
                            child: Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 15),
                            child: Text(
                              foodName,
                              style: const TextStyle(fontSize: 24),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ))
                      ],
                    ),

                    const Padding(padding: EdgeInsets.all(8)),
                    TextButton(
                      onPressed: () {
                        petInfoArguments = PetInfoArguments(petName, year,
                            month, day, foodName, content, daily);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return PetEditPage();
                        }));
                      },
                      child: const Text(
                        'ペット情報を編集',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const Padding(padding: EdgeInsets.all(8)),
                  ],
                ),
              )),
    );
  }
}
