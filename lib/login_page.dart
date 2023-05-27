import 'package:camera_filter/constant.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.05,
                left: MediaQuery.of(context).size.width * 0.3),
            width: MediaQuery.of(context).size.width * 0.4,
            height: MediaQuery.of(context).size.height * 0.25,
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/selfieera.png')),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.34,
                left: MediaQuery.of(context).size.width * 0.03),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.05,
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 30),
            ),
          ),
          Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.4),
            child: TextFormField(
              cursorColor: Colors.black,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white70,
                // icon: Icon(
                //   Icons.mail_rounded,
                //   color: Colors.grey,
                // ),
                hintText: "Email Address",
                labelStyle:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.48),
            child: TextFormField(
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white70,
                // icon: Icon(
                //   Icons.remove_red_eye_rounded,
                //   color: Colors.grey,
                // ),
                hintText: "Password",
                labelStyle:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.6,
            ),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                onPressed: () {},
                child: Text('SignIn')),
          )
        ],
      ),
    );
  }
}
