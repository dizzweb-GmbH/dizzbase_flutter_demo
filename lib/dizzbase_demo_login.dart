// ignore_for_file: prefer_const_constructors, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:dizzbase_client/dizzbase_client.dart';

class DizzbaseLogin extends StatefulWidget {
  const DizzbaseLogin({super.key});

  static void showLoginDialog (BuildContext context)
  {
    showDialog(context: context, builder: ((context) {
      return DizzbaseLogin();
    }));
  }

  @override
  State<DizzbaseLogin> createState() => _DizzbaseLoginState();
}

class _DizzbaseLoginState extends State<DizzbaseLogin> {
  String loginError = "";
  TextEditingController _ctrlUname = TextEditingController(text: 'admin');
  TextEditingController _ctrlPwd = TextEditingController(text: 'admin');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(title: Text ("Login to dizzbase"), 
      content: SizedBox(
        height: 120,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row (children: [
            Text ("User Name or Email:"), SizedBox (width: 20), SizedBox(width: 200, child: TextField(controller: _ctrlUname,)), SizedBox(width: 50,),
            Text ("Password:"), SizedBox (width: 20), SizedBox(width: 200, child: TextField(controller: _ctrlPwd,)),
          ],),
          SizedBox(height: 10,),
          SizedBox(height: 30, child: (loginError!="")?Text ("Login failed: $loginError", style: TextStyle(color: Colors.red),):Container()),
        ],),
      ),
      actions: [
        ElevatedButton(onPressed: (){Navigator.of(context).pop();}, child: Text ('     Cancel     ')),
        ElevatedButton(onPressed: (){
          String uName = ""; String uEmail = "";
          if (_ctrlUname.text.contains("@")) {uEmail = _ctrlUname.text;} else {uName = _ctrlUname.text;}
          DizzbaseAuthentication.login(userName: uName, email: uEmail, password: _ctrlPwd.text).then((loginResult) {
            if (loginResult.loginSuccessful)
            {
              Navigator.of(context).pop();
            } else {
              setState(() {
                loginError = loginResult.error;
              });
            }
          });
        }, child: Text ('     Login     ')),        
      ],    
    );
  }
}
