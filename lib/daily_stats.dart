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
        SizedBox.expand(
          child: DraggableScrollableSheet(
            initialChildSize: 0.58,
            builder: (context, scrollController) {
              return Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: DefaultTabController(
                  initialIndex: 1,
                  length: 3,
                  child: SafeArea(
                    child: Column(
                      children: [
                        SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          controller: scrollController,
                          child: Container(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            child: Column(
                              children: [
                                Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).hintColor,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                    ),
                                    height: 4,
                                    width: 40,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10),
                                  ),
                                ),
                                const TabBar(
                                  dividerHeight: 0.0,
                                  tabs: [
                                    Tab(
                                        text: "Daily",
                                        icon: Icon(Icons.calendar_month)),
                                    Tab(
                                        text: "Weekly",
                                        icon: Icon(Icons.calendar_month)),
                                    Tab(
                                        text: "Monthly",
                                        icon: Icon(Icons.calendar_month)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              showSales(
                                  db.dailySaleAndPurchase(), scrollController),
                              showSales(
                                  db.weeklySaleAndPurchase(), scrollController),
                              showSales(db.monthlySaleAndPurchase(),
                                  scrollController),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget showDailySales(ScrollController scrollController) {
    return showSales(db.dailySaleAndPurchase(), scrollController);
  }

  Future<List<Map<String, dynamic>>> dailyRandomSale() {
    return Future.value([
      {"period": "2024-08-12", "totalSales": 3000, "totalPurchases": 2000},
      {"period": "2024-08-13", "totalSales": 3000, "totalPurchases": 2000},
      {"period": "2024-08-14", "totalSales": 3000, "totalPurchases": 2000},
      {"period": "2024-08-15", "totalSales": 3000, "totalPurchases": 2000},
      {"period": "2024-08-16", "totalSales": 3000, "totalPurchases": 2000},
      {"period": "2024-08-17", "totalSales": 3000, "totalPurchases": 2000},
      {"period": "2024-08-18", "totalSales": 3000, "totalPurchases": 2000},
      {"period": "2024-08-19", "totalSales": 3000, "totalPurchases": 2000},
      {"period": "2024-08-11", "totalSales": 3000, "totalPurchases": 2000},
      {"period": "2024-08-10", "totalSales": 3000, "totalPurchases": 2000},
      {"period": "2024-08-09", "totalSales": 3000, "totalPurchases": 2000},
      {"period": "2024-08-08", "totalSales": 3000, "totalPurchases": 2000},
      {"period": "2024-08-07", "totalSales": 3000, "totalPurchases": 2000},
    ]);
  }

  Widget showSales(Future<List<Map<String, dynamic>>> future,
      ScrollController scrollController) {
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
            controller: scrollController,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return getListTile(snapshot.data![index]);
            },
          );
        }
      },
    );
  }

  Widget showSalesSliver(Future<List<Map<String, dynamic>>> future,
      ScrollController scrollController, String tabName) {
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
          return SafeArea(
            top: false,
            bottom: false,
            child: Builder(
              // This Builder is needed to provide a BuildContext that is
              // "inside" the NestedScrollView, so that
              // sliverOverlapAbsorberHandleFor() can find the
              // NestedScrollView.
              builder: (BuildContext context) {
                return CustomScrollView(
                  controller: scrollController,
                  // The "controller" and "primary" members should be left
                  // unset, so that the NestedScrollView can control this
                  // inner scroll view.
                  // If the "controller" property is set, then this scroll
                  // view will not be associated with the NestedScrollView.
                  // The PageStorageKey should be unique to this ScrollView;
                  // it allows the list to remember its scroll position when
                  // the tab view is not on the screen.
                  key: PageStorageKey<String>(tabName),
                  slivers: <Widget>[
                    /*SliverOverlapInjector(
                      // This is the flip side of the SliverOverlapAbsorber
                      // above.
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          context),
                    ),*/
                    SliverPadding(
                      padding: const EdgeInsets.all(8.0),
                      // In this example, the inner scroll view has
                      // fixed-height list items, hence the use of
                      // SliverFixedExtentList. However, one could use any
                      // sliver widget here, e.g. SliverList or SliverGrid.
                      sliver: SliverList.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return getListTile(snapshot.data![index]);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
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
