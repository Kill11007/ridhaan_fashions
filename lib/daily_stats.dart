import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ridhaan_fashions/daily_sale.dart';
import 'package:ridhaan_fashions/purchase.dart';

import 'database_helper.dart';

class DailyStats extends StatefulWidget {
  const DailyStats({super.key});

  @override
  State<DailyStats> createState() => _DailyStatsState();
}

class _DailyStatsState extends State<DailyStats> {
  final dailySaleController = TextEditingController();

  final dailyPurchaseController = TextEditingController();

  final db = DatabaseHelper();

  final _saleFormKey = GlobalKey<FormState>();

  final _purchaseFormKey = GlobalKey<FormState>();

  void _saveDailyPurchase() {
    if (_purchaseFormKey.currentState!.validate()) {
      _purchaseFormKey.currentState!.save();
      db.addDailyPurchase(
          Purchase(purchase: int.parse(dailyPurchaseController.text)));
      db.fetchDailyPurchase().then(
            (value) => {
              for (Purchase p in value) print(p),
            },
          );
      _purchaseFormKey.currentState!.reset();
    }
  }

  void _saveDailySale() async {
    if (_saleFormKey.currentState!.validate()) {
      _saleFormKey.currentState!.save();
      await db.addDailySale(Sale(sale: int.parse(dailySaleController.text)));
      db.fetchDailySale().then(
            (value) => {
              for (Sale s in value) print(s),
            },
          );
      _saleFormKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Form(
              key: _saleFormKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: dailySaleController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Daily Sale',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter daily sale';
                        }
                        return null;
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _saveDailySale(),
                    child: const Text("Add Sale"),
                  ),
                ],
              ),
            ),
            Form(
              key: _purchaseFormKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter daily purchase';
                        }
                        return null;
                      },
                      controller: dailyPurchaseController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Stock Purchase',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _saveDailyPurchase(),
                    child: const Text("Add Purchase"),
                  ),
                ],
              ),
            ),
          ],
        ),
        DraggableScrollableSheet(
          initialChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inversePrimary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: DefaultTabController(
                initialIndex: 1,
                length: 3,
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).hintColor,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                          ),
                          height: 4,
                          width: 40,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SliverAppBar(
                      title: TabBar(
                        dividerHeight: 0.0,
                        tabs: [
                          Tab(text: "Daily", icon: Icon(Icons.calendar_month)),
                          Tab(text: "Weekly", icon: Icon(Icons.calendar_month)),
                          Tab(
                              text: "Monthly",
                              icon: Icon(Icons.calendar_month)),
                        ],
                      ),
                      primary: false,
                      pinned: true,
                      centerTitle: false,
                    ),
                    SliverFillRemaining(
                      child: TabBarView(
                        children: [
                          showDailySales(),
                          showSales(db.weeklySaleAndPurchase()),
                          showSales(db.monthlySaleAndPurchase()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        )
      ],
    );
  }

  Widget showDailySales() {
    return showSales(db.dailySaleAndPurchase());
  }

  Widget showSales(Future<List<Map<String, dynamic>>> future) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While waiting for the data to load
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // If an error occurs
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // If the data is empty
          return const Center(child: Text('No data available'));
        } else {
          // If data is successfully loaded
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return getListTile(snapshot.data![index]);
            },
          );
        }
      },
    );
  }

  Widget getListTile(Map<String, dynamic> map) {
    String day = map['period'].toString();
    String sales = map['totalSales'].toString();
    String purchase = map['totalPurchases'].toString();
    return ListTile(
      leading: Text(day),
      title: Text(sales),
      subtitle: Text(purchase),
      trailing: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Text(
          '${int.parse(sales) - int.parse(purchase)}',
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ),
    );
  }
}
