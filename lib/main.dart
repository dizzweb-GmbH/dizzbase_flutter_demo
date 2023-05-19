// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:dizzbase_client/dizzbase_client.dart';
import 'dizzbase_demo_widget.dart';


void main() async {
  DizzbaseConnection.configureConnection("http://localhost:3000", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjowLCJ1c2VyX25hbWUiOiIiLCJ1c2VyX3JvbGUiOiJhcGkiLCJ1dWlkIjoiIiwiaWF0IjoxNjg0NTIxMzc5fQ.yL4YV9z_ajOuiH-ixBwPPCK8JDMl-szsOTSk7YHvFVE");
  await DizzbaseAuthentication.login(userName: "admin", password: "admin");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'dizzbase Flutter Demo Home Page'),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: DizzbaseDemoWidget(),
    );
  }
}
