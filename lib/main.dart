import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ridhaan_fashions/product.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ridhaan Fashions',
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

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(child: Text(widget.title)),
      ),
      body: const CustomerForm(),
    );
  }
}

class CustomerForm extends StatefulWidget {
  const CustomerForm({super.key});

  @override
  State<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  int _total = 0;

  final _formKey = GlobalKey<FormState>();
  final inputPriceController = TextEditingController();
  final inputDiscountController = TextEditingController();

  void _calculateTotal() {
    _total = 0;
    setState(() {
      for (Product p in _products) {
        _total += p.price;
      }
      String discount;
      if (inputDiscountController.text.isEmpty) {
        discount = "0";
      } else {
        discount = inputDiscountController.text;
      }
      _total -= int.parse(discount);
    });
    print('total: $_total');
  }

  final List<Product> _products = [Product(id: UniqueKey().toString())];

  void _addProduct() {
    setState(() {
      _products.add(Product(id: UniqueKey().toString()));
    });
  }

  void _removeProduct(int index) {
    Product p = _products[index];
    print('Removed Index:  $index, Product: ${p.price}, ${p.name}');
    setState(() {
      _products.removeAt(index);
      _calculateTotal();
    });
  }

  @override
  void dispose() {
    inputDiscountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Add TextFormFields and ElevatedButton here.
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                maxLength: 10,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Phone Number',
                ),
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  } else if (value.length != 10) {
                    return 'Enter correct phone number with 10 digits only';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name',
                ),
                // The validator receives the text that the user has entered.
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Product",
                      style: theme.textTheme.headlineSmall!
                          .copyWith(color: theme.colorScheme.inverseSurface)),
                  const SizedBox(
                    width: 10,
                  ),
                  FilledButton(
                    onPressed: _addProduct,
                    child: Text(
                      "+",
                      style: theme.textTheme.headlineSmall!
                          .copyWith(color: theme.colorScheme.onPrimary),
                    ),
                  ),
                ],
              ),
            ),
            for (int i = 0; i < _products.length; i++)
              ProductForm(
                product: _products[i],
                onRemove: () => _removeProduct(i),
                onPriceChange: _calculateTotal,
                key: ValueKey(_products[i].id),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                onChanged: (text) => _calculateTotal(),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: inputDiscountController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Discount',
                ),
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Price';
                  }
                  return null;
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Total: ",
                    textAlign: TextAlign.left,
                    style: theme.textTheme.displaySmall!
                        .copyWith(color: theme.colorScheme.inverseSurface),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '$_total',
                    textAlign: TextAlign.right,
                    style: theme.textTheme.displaySmall!
                        .copyWith(color: theme.colorScheme.inverseSurface),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Processing Data')),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductForm extends StatelessWidget {
  const ProductForm(
      {required this.product,
      required this.onRemove,
      required this.onPriceChange,
      super.key});

  final Product product;
  final VoidCallback onRemove;
  final VoidCallback onPriceChange;

  void _changePrice(String text){
    text = text.isEmpty ? "0" : text;
    product.price = int.parse(text);
    onPriceChange.call();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Product Name',
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter product name';
                }
                return null;
              },
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              onChanged: (text) => _changePrice(text),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Price',
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Price';
                }
                return null;
              },
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
        ),
        Expanded(
          flex: 0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FilledButton(
              onPressed: onRemove,
              child: Text(
                "-",
                style: theme.textTheme.headlineLarge!
                    .copyWith(color: theme.colorScheme.onPrimary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
