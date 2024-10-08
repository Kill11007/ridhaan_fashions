import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ridhaan_fashions/bill.dart';
import 'package:ridhaan_fashions/customer.dart';
import 'package:ridhaan_fashions/database_helper.dart';
import 'package:ridhaan_fashions/invoice.dart';
import 'package:ridhaan_fashions/pdf_invoice_api.dart';
import 'package:ridhaan_fashions/product.dart';
import 'package:ridhaan_fashions/product_form.dart';
import 'package:ridhaan_fashions/send_pdf.dart';
import 'package:ridhaan_fashions/supplier.dart';

class CustomerBillForm extends StatefulWidget {
  const CustomerBillForm({super.key});

  @override
  State<CustomerBillForm> createState() => _CustomerBillFormState();
}

class _CustomerBillFormState extends State<CustomerBillForm> {
  static const String messageTemplate = '''
Thank you for shopping on Ridhaan Fashions.
Please find attached your bill for the recent purchase.''';
  static const rfSupplier = Supplier(
      name: 'Ridhaan Fashions',
      address: 'Kasba Road Modinagar Gaziabad',
      contactNumber: '9625612771');

  /*static final INVOICE = Invoice(
    supplier: const Supplier(
      name: 'Ridhaan Fashions',
      address: 'Kasba Road Modinagar Gaziabad',
    ),
    customer: Customer(
      name: 'Mayank',
      phoneNumber: '9717011122',
      totalPurchase: 0,
    ),
    info: InvoiceInfo(
      date: TODAY_DATE,
      number:
          '${DateTime.now().year}-9999',
    ),
    items: const [
      InvoiceItem(
        description: 'Coffee',
        price: 500,
      ),
      InvoiceItem(
        description: 'Water',
        price: 300,
      ),
      InvoiceItem(
        description: 'Orange',
        price: 350,
      ),
      InvoiceItem(
        description: 'Apple',
        price: 399,
      ),
      InvoiceItem(
        description: 'Mango',
        price: 159,
      ),
      InvoiceItem(
        description: 'Blue Berries',
        price: 99,
      ),
      InvoiceItem(
        description: 'Lemon',
        price: 129,
      ),
    ],
  );*/

  int _total = 0;
  final db = DatabaseHelper();
  final pdfHelper = SendPDF();
  final _formKey = GlobalKey<FormState>();
  final inputPriceController = TextEditingController();
  final inputDiscountController = TextEditingController();

  void _calculateTotal() {
    _total = 0;
    setState(() {
      for (Product p in _products) {
        _total += p.price;
      }
      String discount = inputDiscountController.text;
      if (discount.isEmpty) {
        discount = "0";
      }
      _total -= int.parse(discount);
    });
    print('total: $_total');
  }

  final List<Product> _products = [Product(id: UniqueKey().toString())];
  late String phoneNumber;
  late String customerName = '';
  late int discount = 0;

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

  void _setDiscount(String? newValue) {
    if (newValue == null || newValue.isEmpty) {
      newValue = '0';
    }
    discount = int.parse(newValue);
  }

  @override
  void dispose() {
    inputDiscountController.dispose();
    super.dispose();
  }

  String whatsAppPhoneNumber = rfSupplier.contactNumber;

  void _saveForm() async {
    print("Save Form");

    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sending Bill')),
      );
      _formKey.currentState!.save();
      var bill = Bill(
        phoneNumber: phoneNumber,
        customerName: customerName,
        products: _products,
        discount: discount,
      );
      int billId = await db.addBill(bill);
      /*db.fetchBills().then(
            (value) => {
              for (Bill bill in value) print(bill),
            },
          );
      db.fetchCustomers().then(
            (customers) => {
              for (Customer c in customers) print(c),
            },
          );*/
      sendPDF(bill, billId).then(
        (value) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Bill Saved $value',
            ),
          ),
        ),
      );

      _formKey.currentState?.reset();
    }
  }

  Future<String> sendPDF(Bill bill, int billId) async {
    final String fileName = '${bill.phoneNumber}_BILL$billId.pdf';
    final pdfFile = await PdfInvoiceApi.generate(
      Invoice(
        info: InvoiceInfo(
            number: '$billId${bill.phoneNumber}', date: DateTime.now()),
        supplier: rfSupplier,
        customer: Customer(
            phoneNumber: bill.phoneNumber,
            name: bill.customerName,
            totalPurchase: bill.total),
        items: [
          for (Product p in bill.products)
            InvoiceItem(description: p.name, price: p.price)
        ],
        discount: bill.discount,
      ),
      fileName,
    );
    //pdfHelper.sendPDF(pdfFile, bill.phoneNumber);
    //pdfHelper.sendPDFWithMediaId('1194368978429982', bill.phoneNumber);

    try {
      pdfHelper.launchWhatsappWithMobileNumber(
          bill.phoneNumber, messageTemplate);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error in launching the whatsapp.')),
      );
    }
    return fileName;
  }

  void _sendForm() async {
    print("Send Form");
    _saveForm();
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
                onSaved: (newValue) => phoneNumber = newValue!,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name',
                ),
                onSaved: (newValue) => {
                  if (newValue != null) {customerName = newValue}
                },
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
                onSaved: (newValue) => _setDiscount(newValue),
                onChanged: (text) => _calculateTotal(),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: inputDiscountController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Discount',
                ),
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
                    style: theme.textTheme.headlineMedium!
                        .copyWith(color: theme.colorScheme.inverseSurface),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '$_total',
                    textAlign: TextAlign.right,
                    style: theme.textTheme.headlineLarge!
                        .copyWith(color: theme.colorScheme.inverseSurface),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
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
                    child: const Text('Save'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      _sendForm();
                    },
                    child: const Text('Send'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
