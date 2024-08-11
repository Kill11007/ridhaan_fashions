import 'package:flutter/material.dart';
import 'package:ridhaan_fashions/custom_form.dart';
import 'package:ridhaan_fashions/customers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static String title = "Ridhaan Fashions";

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 58, 104, 183)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Ridhaan Fashions'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;
  final Widget customerBillForm = const CustomerBillForm();

  @override
  State<MyHomePage> createState() => _MyHomePageState(customerBillForm);
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;
  final Widget homePage;
  late Widget currentWidget;
  _MyHomePageState(this.homePage) {
    currentWidget = homePage;
  }
  void _onDestinationChange(int index) {
    setState(() {
      if (currentPageIndex == index) return;
      currentPageIndex = index;
      print("Destination Index Selected: $currentPageIndex");
      switch (currentPageIndex) {
        case 0:
          {
            currentWidget = homePage;
            break;
          }
        case 1:
          {
            currentWidget = const SearchableCustomerList();
            break;
          }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(child: Text(widget.title)),
      ),
      body: currentWidget,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        onDestinationSelected: (index) => _onDestinationChange(index),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.people),
            icon: Icon(Icons.people_outline),
            label: "Customers",
          ),
        ],
      ),
    );
  }
}
