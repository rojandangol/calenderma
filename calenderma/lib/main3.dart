// ///This worked: extracting pdf : https://www.syncfusion.com/blogs/post/5-ways-to-extract-text-from-pdf-documents-in-flutter
// ///
// ///pdf_text: https://pub.dev/documentation/pdf_text/latest/ || did not work
// ///
// ///
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'dart:html' as html;
import 'dart:async' show Completer;
import 'dart:math' show min;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

class ThirdRoute extends StatelessWidget {
  const ThirdRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Text Extraction',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 152, 200, 239),
        ),
        useMaterial3: true,
      ),
      home: const MyWidget(),
    );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {

  //important variables to interact with user
  late DropzoneViewController controller1;

  String message1 = 'Drop a PDF file here';

  bool highlighted1 = false;

  String content = "";

  String storecontent= "";


///to store the syllabus content in json and send it to the server.
  void sendcontentopy(){

     var headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };

    var body = jsonEncode(<String, String>{'content': storecontent});

    http
    .post(Uri.parse('http://127.0.0.1:5000/postingcontent') 
    ,headers : headers , body:body)

    .then((r)=> {
      setState(() {
        content = storecontent;
        
      })
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("PDF Text Extractor"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () async {
                await controller1.pickFiles();
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 170),
                height: 100,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2.0),
                  color: highlighted1 ? Colors.red : Colors.green,
                ),
                child: Stack(
                  children: [
                    buildZone1(context),
                    Center(child: Text(message1)),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  message1 = 'Drop a PDF file here';
                  highlighted1 = false;
                });
              },
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }

//dropzone where users can drop in their pdf. From:  https://pub.dev/packages/flutter_dropzone 
  Widget buildZone1(BuildContext context) => Builder(
        builder: (context) => DropzoneView(
          operation: DragOperation.copy,
          cursor: CursorType.grab,
          onCreated: (ctrl) => controller1 = ctrl,
          onLoaded: () => print('Dropzone loaded'),
          onError: (error) => print('Dropzone error: $error'),
          onHover: () {
            setState(() => highlighted1 = true);
          },
          onLeave: () {
            setState(() => highlighted1 = false);
          },
          onDropFile: (file) async {
            print('Dropped file: ${file.name}');
            setState(() {
              message1 = '${file.name} dropped';
              highlighted1 = false;
            });

            await processPdf(file);
          },
        ),
      );


//Extracting pdf:  https://www.syncfusion.com/blogs/post/5-ways-to-extract-text-from-pdf-documents-in-flutter
  Future<void> processPdf(DropzoneFileInterface file) async {
  try {
    //get the file data as bytes
    Uint8List pdfData = await controller1.getFileData(file);

    //load the PDF document from bytes
    PdfDocument document = PdfDocument(inputBytes: pdfData);

    //extract text from all pages
    String extractedText = PdfTextExtractor(document).extractText();
    storecontent = extractedText;

    sendcontentopy();

    // print (storecontent);

    setState(() {
      message1 = 'Text extracted and printed';
    });

    //dispose the document
    document.dispose();
  } catch (e) {
    print('Error: $e');
    setState(() {
      message1 = 'Failed.';
    });
  }
}


}