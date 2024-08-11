import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ridhaan_fashions/customer.dart';

import 'database_helper.dart';

class CustomerList extends StatelessWidget {
  final String searchText;

  CustomerList({super.key, required this.searchText});

  final db = DatabaseHelper();

  Future<List<Customer>> _getCustomers() async {
    return db.fetchCustomersByPhoneNumber(searchText);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getCustomers(),
      builder: (context, snapshot) {
        return ListView.builder(
          itemCount: snapshot.data?.length,
          itemBuilder: (context, index) {
            if (snapshot.data != null) {
              return CustomerCard(customer: snapshot.data![index]);
            }
            return null;
          },
        );
      },
    );
  }
}

class CustomerCard extends StatelessWidget {
  final Customer customer;

  const CustomerCard({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      customer.name,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      customer.phoneNumber,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "${customer.totalPurchase}",
                  style: Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.end,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchableCustomerList extends StatefulWidget {
  const SearchableCustomerList({super.key});

  @override
  State<SearchableCustomerList> createState() => _SearchableCustomerListState();
}

class _SearchableCustomerListState extends State<SearchableCustomerList> {
  String _query = '';
  Widget customerList = CustomerList(searchText: '');

  void search(String query) {
    setState(() {
      _query = query;
      customerList = CustomerList(searchText: _query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              search(value);
            },
            maxLength: 10,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Search...',
              prefixIcon: Icon(
                Icons.search_rounded,
              ),
            ),
          ),
        ),
        Expanded(
          child: customerList,
        ),
      ],
    );
  }
}
