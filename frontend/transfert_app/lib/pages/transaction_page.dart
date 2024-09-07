import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:transfert_app/pages/add_transaction_page.dart';

class TransactionPage extends StatefulWidget {
  final String userId;

  const TransactionPage({super.key, required this.userId});

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  double _walletBalance = 0.0;
  List<dynamic> _transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchWalletBalance();
    _fetchTransactions();
  }

  Future<void> _fetchWalletBalance() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/wallet/balance/${widget.userId}/'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      setState(() {
        _walletBalance = data['balance'];
      });
    } else {
      // Gérer les erreurs
      throw Exception('Erreur de chargement du solde du portefeuille');
    }
  }

  Future<void> _fetchTransactions() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/transaction/history/${widget.userId}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      setState(() {
        _transactions = data;
      });
    } else {
      // Gérer les erreurs
      throw Exception('Erreur de chargement des transactions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Portefeuille'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Solde: \$$_walletBalance',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _transactions.isEmpty
                ? const Center(
                    child: Text("Pas de transactions"),
                  )
                : _transactions.isNotEmpty
                    ? RefreshIndicator(
                        onRefresh: () async {
                          await _fetchTransactions();
                          await _fetchWalletBalance();
                        },
                        child: ListView.builder(
                          itemCount: _transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = _transactions[index];
                            return ListTile(
                              title:
                                  Text('Montant: \$${transaction['amount']}'),
                              subtitle:
                                  Text('Statut: ${transaction['status']}'),
                              trailing:
                                  Text('Date: ${transaction['created_at']}'),
                            );
                          },
                        ),
                      )
                    : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Naviguer vers la page d'ajout de transaction
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddTransactionPage(
                      userId: widget.userId,
                    )),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
