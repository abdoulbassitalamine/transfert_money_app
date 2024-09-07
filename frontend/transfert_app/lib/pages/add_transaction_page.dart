import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddTransactionPage extends StatefulWidget {
  final String userId;
  const AddTransactionPage({super.key, required this.userId});
  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final TextEditingController _receiverIdController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _apiUrl ="";

   @override
  void initState() {
    super.initState();
    // Initialization code here
    print('Widget is initialized');
    _apiUrl = 'http://10.0.2.2:8000/transaction/create/${widget.userId}';
  }



  Future<void> _addTransaction() async {
    final String receiverId = _receiverIdController.text;
    final String amount = _amountController.text;

    if (receiverId.isEmpty || amount.isEmpty) {
      _showErrorDialog('Please fill in all fields');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
  
        },
        body: jsonEncode({
          'receiver_id': receiverId,
          'amount': amount,
        }),
      );

      if (response.statusCode == 201) {
        _showSuccessDialog('Transaction created successfully');
      } else {
        final Map<String, dynamic> errorResponse = jsonDecode(response.body);
        _showErrorDialog(errorResponse['error'] ?? 'Unknown error');
      }
    } catch (e) {
      _showErrorDialog('Failed to add transaction');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Transaction'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _receiverIdController,
              decoration: InputDecoration(labelText: 'Receiver ID'),
              keyboardType: TextInputType.text
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addTransaction,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
