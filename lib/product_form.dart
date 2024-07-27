
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ridhaan_fashions/product.dart';

class ProductForm extends StatelessWidget {
  const ProductForm(
      {required this.product,
        required this.onRemove,
        required this.onPriceChange,
        super.key});

  final Product product;
  final VoidCallback onRemove;
  final VoidCallback onPriceChange;

  void _changePrice(String price){
    price = price.isEmpty ? "0" : price;
    product.price = int.parse(price);
    onPriceChange.call();
  }

  void _changeName(String name) {
    product.name = name;
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
                labelText: 'Name',
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter product name';
                }
                return null;
              },
              onSaved: (newValue) => _changeName(newValue!),
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
