///the signup page
///
import 'package:flutter/material.dart';
import 'package:calenderma/main.dart';
import 'package:calenderma/main3.dart';


import 'dart:convert';
import 'package:http/http.dart' as http;



class Signup extends StatelessWidget{

const Signup({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LM3',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 152, 200, 239)),
        useMaterial3: true,
      ),
      home: const MyWidget(),
    );
  
  }

}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MynewState();
}

class _MynewState extends State<MyWidget>{

String username =" ";
String email =" ";
String password =" ";
int userid =0;


///for username 
  final TextEditingController userncontroller = TextEditingController();
  
  //for password
  final TextEditingController pwercontroller = TextEditingController();

  //for email
  final TextEditingController emailzcontroller = TextEditingController();


//sending user data to the backend so that we have record of them and they can log in
void senddata(){
 var headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };

    var body = jsonEncode(<String, String>{'username': userncontroller.value.text,
                            'password' : pwercontroller.value.text,
                            'email': emailzcontroller.value.text});

       http
        .post(Uri.parse('http://127.0.0.1:5000/enteruserdetail'),
            headers: headers, body: body)
        .then((r) => {

              setState(() {
                username = userncontroller.value.text;
                email = emailzcontroller.value.text;
                password = pwercontroller.value.text;
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
Widget build (BuildContext context){
return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('CALENDER MA'),
      ),
      body: Container(

        //testing: to decorate the boarder of the form? But did not work.
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
            // key: _formkey,
            // autovalidateMode:AutovalidateMode.onUserInteraction ,

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
                    _maketextformfield('Username',userncontroller),
                   

                    const SizedBox(height: 16),

                    _maketextformfield('Email', emailzcontroller),

                    const SizedBox(height: 16),


                   
                    _maketextformfield('Password', pwercontroller),

                

              

                    const SizedBox(height: 16),
                   

                    SizedBox(height: 20),
                    ElevatedButton(
  onPressed: (){
    // Call the checkuserdetail function
    senddata();
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
  onPressed: () {
                        ///links to main1
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MyApp()),
                        );
                      },
   
  child: const Text("Go Back to login page"),
  style: ElevatedButton.styleFrom(
    backgroundColor: Color.fromARGB(255, 152, 200, 239),
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
  ),
),

SizedBox(height: 20),
              
  
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
