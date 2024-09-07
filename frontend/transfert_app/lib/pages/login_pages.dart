import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:transfert_app/pages/transaction_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _isLoading = false;

  // Function to handle login
  void _login(context) async {
    String id = "";
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      var url = Uri.parse('http://10.0.2.2:8000/login/');
      var response = await http.post(url, body: {
        'username': _username,
        'password': _password,
      });

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        print(jsonResponse);
        id = jsonResponse['id'];
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Connecté avec succès!'),
        ));

        // Navigate to another screen or do whatever you want after login
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> TransactionPage(userId: id)));
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Identifiants invalides'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Nom d\'utilisateur'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer votre nom d\'utilisateur';
                  }
                  return null;
                },
                onSaved: (value) {
                  _username = value!;
                },
              ),
              TextFormField(
                decoration:const  InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer votre mot de passe';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value!;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: (){
                        _login(context);
                      },
                      child:const  Text('Se connecter'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
