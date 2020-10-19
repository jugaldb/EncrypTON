import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cryptography/cryptography.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PlatformFile file;
  String filetext;
  bool fileUploaded = false;
  Future<String> _read(String path) async {
    String text;
    try {
      final File file = File(path);
      text = await file.readAsString();
    } catch (e) {
      print("Couldn't read file");
    }
    return text;
  }

  List encrypted;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "EncrypTON",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: size.height * 3 / 100,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: size.width * 5 / 100),
            child: Text(
              'Encode',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: size.height * 1 / 100,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.pink,
              borderRadius: BorderRadius.all(
                Radius.circular(size.width * 2 / 100),
              ),
            ),
            margin: EdgeInsets.symmetric(horizontal: size.width * 5 / 100),
            child: FlatButton(
              onPressed: () async {
                FilePickerResult result = await FilePicker.platform.pickFiles();

                if (result != null) {
                  PlatformFile file = result.files.first;
                  filetext = await _read(file.path);
                  if (filetext != null) {
                    setState(() {
                      fileUploaded = true;
                    });
                  }
                }
                final cipher = chacha20Poly1305Aead;

                final secretKey = SecretKey.randomBytes(32);

                final nonce = Nonce.randomBytes(12);

                // Our message
                final message = utf8.encode(filetext);

                // Encrypt
                encrypted = await cipher.encrypt(
                  message,
                  secretKey: secretKey,
                  nonce: nonce,
                );

                print('Encrypted: $encrypted');

                // Decrypt
                final decrypted = await cipher.decrypt(
                  encrypted,
                  secretKey: secretKey,
                  nonce: nonce,
                );
                print(utf8.decode(decrypted));
                print('Decrypted: $decrypted');
              },
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                child: Text(
                  "Upload File",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
            ),
          ),
          fileUploaded
              ? SizedBox(
                  height: size.height * 2 / 100,
                )
              : Container(),
          fileUploaded
              ? Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: size.width * 5 / 100),
                  child: Text(
                    'Here is your encoded output',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Container(),
          fileUploaded
              ? SizedBox(
                  height: size.height * 1 / 100,
                )
              : Container(),
          fileUploaded
              ? Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: size.width * 5 / 100),
                  child: Text(
                    encrypted.toString(),
                    style: TextStyle(
                      color: Colors.pink,
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
