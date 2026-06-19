import 'package:expense_tracker/providers/theme_provider.dart';
import 'package:expense_tracker/screens/addbudget_screen.dart';
import 'package:expense_tracker/screens/addexpensescreen.dart';
import 'package:expense_tracker/screens/addincomescreen.dart';
import 'package:expense_tracker/screens/analytics_screen.dart';
import 'package:expense_tracker/screens/budgetscreen.dart';
import 'package:expense_tracker/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilterCategory = "All";

  String searchQuery = "";
  int currentIndex = 0;
  DateTime? selectedDate;

  /*List<Widget> pages = [];

  @override
  void initState() {
    super.initState();

    pages = [
      historyPage(),
      Budgetscreen(),
      AnalyticsScreen(),
    ];
  }*/






  Widget historyPage() {
    return ListView(
      padding: EdgeInsets.all(12),
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: "Search transactions...",
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value.toLowerCase();
            });
          },
        ),


        SizedBox(height: 10),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 18, color: Colors.blue),

              SizedBox(width: 10),

              Expanded(
                child: Text(
                  selectedDate == null
                      ? "No Date Selected"
                      : "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              if (selectedDate != null)
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      selectedDate = null;
                    });
                  },
                ),

              IconButton(
                icon: Icon(Icons.date_range, color: Colors.blue),
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );

                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
              ),
            ],
          ),
        ),

        SizedBox(height: 10),

        DropdownButtonFormField<String>(
          value: selectedFilterCategory,
          hint: Text("Filter by Category"),
          items: ["All", "Food", "Transport", "Bills", "Shopping"]
              .map((e) => DropdownMenuItem(
            value: e,
            child: Text(e),
          ))
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedFilterCategory = value!;
            });
          },
        ),






        SizedBox(height: 20),

        Text("Expenses", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection("expenses")
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return SizedBox();

            final expenses = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;

              final category = (data['category'] ?? "").toString();
              final description = (data['description'] ?? "").toString();
              final dateValue = data['date'];

              final dataDate = dateValue is Timestamp
                  ? dateValue.toDate()
                  : DateTime.now();

              bool matchSearch =
                  category.toLowerCase().contains(searchQuery) ||
                      description.toLowerCase().contains(searchQuery);

              bool matchCategory =
                  selectedFilterCategory == "All" ||
                      doc['category'] == selectedFilterCategory;

              bool matchDate = selectedDate == null
                  ? true
                  : dataDate.year == selectedDate!.year &&
                  dataDate.month == selectedDate!.month &&
                  dataDate.day == selectedDate!.day;

              return matchSearch && matchCategory && matchDate;
            }).toList();

            return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  var doc = expenses[index];
                  final data = doc.data() as Map<String, dynamic>;

                  final category = (data['category'] ?? "").toString();
                  final description = (data['description'] ?? "").toString();

                  return Card(
                    child: ListTile(
                      title: Text(category),
                      subtitle: Text(description),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text((data['amount'] ?? 0).toString()),

                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => Addexpensescreen(
                                    docId: doc.id,
                                    existingData: data,
                                  ),
                                ),
                              );
                            },
                          ),

                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection("expenses")
                                  .doc(doc.id)
                                  .delete();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }
            );
          },
        ),

        SizedBox(height: 20),

        Text("Income", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection("income")
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return SizedBox();


            final incomes = snapshot.data!.docs.where((doc) {
              final dataDate = (doc['date'] as Timestamp).toDate();
              final description = doc['description'].toString().toLowerCase();

              bool matchSearch = description.contains(searchQuery);


              bool matchCategory = true;
              bool matchDate = selectedDate == null
                  ? true
                  : dataDate.year == selectedDate!.year &&
                  dataDate.month == selectedDate!.month &&
                  dataDate.day == selectedDate!.day;

              return matchSearch && matchCategory && matchDate;
            }).toList();

            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: incomes.length,
              itemBuilder: (context, index) {
                var data = incomes[index];

                return Card(
                  child: ListTile(

                    title: Text(
                      data.data().toString().contains('description')
                          ? data['description']
                          : "",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text((data['amount'] ?? 0).toString()),

                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Addincomescreen(
                                  docId: incomes[index].id,
                                  existingData: data,
                                ),
                              ),
                            );
                          },
                        ),

                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            bool? confirm = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Delete Income"),
                                content: Text("Are you sure you want to delete this income?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text("Delete"),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection("income")
                                  .doc(incomes[index].id)
                                  .delete();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      historyPage(),
      Budgetscreen(),
      AnalyticsScreen(),
    ];
    return Scaffold(

      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Smart Expense Tracker"),
        actions: [
          IconButton(
            icon: Icon(Icons.dark_mode),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false)
                  .toggleTheme();
            },
          ),

          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => Loginscreen()),
              );
            },
          ),
        ],
      ),

      body: pages[currentIndex],

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            builder: (context) {
              return SafeArea(
                child: Wrap(
                  children: [

                    ListTile(
                      leading: Icon(Icons.arrow_downward, color: Colors.green),
                      title: Text("Add Income"),
                      onTap: () async {
                        Navigator.pop(context);

                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Addincomescreen(),
                          ),
                        );

                        if (mounted) setState(() {});
                      },
                    ),

                    ListTile(
                      leading: Icon(Icons.arrow_upward, color: Colors.red),
                      title: Text("Add Expense"),
                      onTap: () async {
                        Navigator.pop(context);

                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Addexpensescreen(),
                          ),
                        );

                        if (mounted) setState(() {});
                      },
                    ),

                    ListTile(
                      leading: Icon(Icons.account_balance_wallet, color: Colors.purple),
                      title: Text("Add Budget"),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddbudgetScreen(),
                          ),
                        );
                      },
                    ),

                  ],
                ),
              );
            },
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: "Budget",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Analytics",
          ),
        ],
      ),
    );
  }
}