//All the necessary imports
//For:Final Project. Build on files from LM3 onwards.
//Author: Rojan Dangol
//Resources: DROP DOWN MENU FROM: https://www.geeksforgeeks.org/flutter-dropdownbutton-widget/ 
//linking to the next page FROM: https://www.geeksforgeeks.org/flutter-navigate-from-one-screen-to-another/#
import 'package:flutter/material.dart';
import 'package:calenderma/main3.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:calenderma/signup.dart';


void main() {
  runApp(const MyApp());
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calender Ma',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 152, 200, 239)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'CALENDER MA'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  //need to store important details
  String username = " ";
  String password = " ";
  String email = " ";
  int userid =0 ;

  ///for username 
  final TextEditingController controller1 = TextEditingController();
  
  //for password
  final TextEditingController pwcontroller = TextEditingController();

  //for email
  final TextEditingController emailcontroller = TextEditingController();

  //checks if usename and password matched and are in the database
  void checkuserdetail(){
      var headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };

    var body = jsonEncode(<String, String>{'username': controller1.value.text,
                            'password' : pwcontroller.value.text});

       http
        .post(Uri.parse('http://127.0.0.1:5000/checkuserdetails'),
            headers: headers, body: body)
        .then((r) => {
              setState(() {
                username = controller1.value.text;
                var resp = jsonDecode(r.body) as Map<String,dynamic>;
                userid = resp['userid'];
              })
            });


  } 

  //function that makes a text form field
  Widget _maketextformfield(String ye,TextEditingController controller) {
    return TextFormField(
      decoration: InputDecoration(labelText: ye),
      controller: controller,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Container(

        decoration: const BoxDecoration(

          ///setting the background image
          image: DecorationImage( 
                image: AssetImage('bg.png'), fit: BoxFit.cover),
            // Border.all(width: 2.0,color:Color.fromARGB(255, 152, 200, 239.)),
            border: Border(
          top: BorderSide(color: Color.fromARGB(255, 237, 128, 26)),
         )
          ),
        child: Center(

          ///MAKING A FROM
          child: Form(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 300, // Limit the width of the form box
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 16),
                    _maketextformfield('Username',controller1),
                    const SizedBox(height: 16),
                    _maketextformfield('Password', pwcontroller),
                    ///to increase distance between the two boxes
                    const SizedBox(height: 16),

                    const SizedBox(height: 16),
                    SizedBox(height: 20),
                    ElevatedButton(
  onPressed: (){
    // Call the checkuserdetail function
    checkuserdetail();
  },
  child: const Text("Submit"),
  style: ElevatedButton.styleFrom(
    backgroundColor: Color.fromARGB(255, 152, 200, 239),
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
  ),
),

//add spacing between the two buttons
const SizedBox(height: 16),

///disable the button : https://sarunw.com/posts/how-to-disable-button-in-flutter/ 
ElevatedButton(
  onPressed: (userid != 0)
      ? () {
          // go to next page if id is not null
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ThirdRoute(),
            ),
          );
        }
      : null, //disable the button if id =0
   
  child: const Text("Next page"),
  style: ElevatedButton.styleFrom(
    backgroundColor: Color.fromARGB(255, 152, 200, 239),
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
  ),
),

SizedBox(height: 20),
Text('The userid is $userid', style: Theme.of(context).textTheme.headlineMedium, ),

const SizedBox(height: 16),

///disable the button : https://sarunw.com/posts/how-to-disable-button-in-flutter/ 
ElevatedButton(
  onPressed: () {
                        ///links to signup page where users can Sign up
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Signup()),
                        );
                      },
   
  child: const Text("Go To signup page"),
  style: ElevatedButton.styleFrom(
    backgroundColor: Color.fromARGB(255, 152, 200, 239),
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
  ),
),

          
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    
  }

 
}


