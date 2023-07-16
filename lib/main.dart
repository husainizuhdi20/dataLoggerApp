import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/src/material/dropdown.dart';

import 'package:engdatalogger/login.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import './splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
      );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Download File",
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      theme: ThemeData(accentColor: Colors.white70),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late SharedPreferences sharedPreferences;
  TextEditingController dateC = TextEditingController();
  GlobalKey<FormState> formKey =
      GlobalKey<FormState>(); //untuk menghandle/validasi sebuah form
  String tahun = '';
  // String value = '';
  String bulan = '';

  final listTahun = ['2022', '2023', '2024', '2025', '2026'];
  String? year;

  final listBulan = [
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12'
  ];
  String? month;

  // Login Status check
  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("token") == null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  LoginPage())); //after logout remove change to null
    }
  }

  // Function async download
  Future download(String tahunFilter, String bulanFilter) async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      if (Platform.isAndroid) {
        final baseStorage = await getExternalStorageDirectory();
        await FlutterDownloader.enqueue(
          url: 'http://192.168.8.120:8081/?filename=' +
              tahunFilter +
              '-' +
              bulanFilter,
          savedDir: baseStorage!.path,
          showNotification:
              true, // show download progress in status bar (for Android)
          openFileFromNotification:
              true, // click on notification to open downloaded file (for Android)
          saveInPublicStorage: true,
        );
      }
    }
  }

  // Function increment and reset _counter
  int date = 07012021;
  int _counter = 0;
  void _incrementCounter() {
    _counter++;
    setState(() {});
  }

  void _resetCounter() {
    _counter = 0;
    setState(() {});
  }

  ReceivePort _port = ReceivePort();
  @override
  void initState() {
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      if (status == DownloadTaskStatus.complete) {
        print("Download Complete !");
      } else if (status == DownloadTaskStatus.failed) {
        print("Download Failed!");
      }
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
    super.initState();
    checkLoginStatus();
  }

  // Function downloader callback
  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  //Function main app
  @override
  Widget build(BuildContext context) {
    // var urk = 'http://192.168.1.28:8081/?filename=' + '$date' + 'datalog' + '$_counter' + '.txt';
    // var urk =
    //     'http://192.168.8.120:8081/?filename=datalog' + '$_counter' + '.txt';

    return Scaffold(
      appBar: AppBar(
        title: Text("Download File", style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              _resetCounter();
              sharedPreferences.clear();
              sharedPreferences.commit();
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (BuildContext context) => LoginPage()),
                  (Route<dynamic> route) => false);
            },
            child: Text("Log Out", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue, width: 3),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: Text('Pilih Tahun'),
                  value: year,
                  iconSize: 36,
                  icon: Icon(Icons.arrow_drop_down,
                      color: Color.fromARGB(255, 173, 157, 5)),
                  isExpanded: true,
                  items: listTahun.map(buildMenuItem).toList(),
                  onChanged: (year) => setState(() => this.year = year),
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue, width: 3),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: Text('Pilih Bulan'),
                  value: month,
                  iconSize: 36,
                  icon: Icon(Icons.arrow_drop_down,
                      color: Color.fromARGB(255, 173, 157, 5)),
                  isExpanded: true,
                  items: listBulan.map(buildMenuItem).toList(),
                  onChanged: (month) => setState(() => this.month = month),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _incrementCounter();
          download('$year', '$month');
        },
        tooltip: 'Download',
        child: Icon(
          Icons.file_download,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(),
    );
  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      );
}
