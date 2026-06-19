import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {

  final uid = FirebaseAuth.instance.currentUser!.uid;

  // ---------------- TOTAL INCOME ----------------
  Future<int> getTotalIncome() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("income")
        .get();

    int total = 0;

    for (var doc in snapshot.docs) {
      total += (doc['amount'] ?? 0) as int;
    }
    return total;
  }


  Future<int> getTotalExpense() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("expenses")
        .get();

    int total = 0;

    for (var doc in snapshot.docs) {
      total += (doc['amount'] ?? 0) as int;
    }
    return total;
  }


  Future<Map<String, int>> getCategoryWise() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("expenses")
        .get();

    Map<String, int> map = {};

    for (var doc in snapshot.docs) {
      String category = (doc['category'] ?? "Other").toString();
      int amount = (doc['amount'] ?? 0);

      map[category] = (map[category] ?? 0) + amount;
    }

    return map;
  }



  Future<Map<String, int>> getMonthlyExpense() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("expenses")
        .get();

    Map<String, int> monthly = {};

    for (var doc in snapshot.docs) {
      DateTime date = (doc['date'] as Timestamp).toDate();

      String month = "${date.year}-${date.month.toString().padLeft(2, '0')}";

      int amount = (doc['amount'] ?? 0);

      monthly[month] = (monthly[month] ?? 0) + amount;
    }

    var sortedKeys = monthly.keys.toList()..sort();

    return {
      for (var k in sortedKeys) k: monthly[k]!
    };
  }

















  Widget buildPie(int income, int expense) {
    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: income == 0 ? 1 : income.toDouble(),
              color: Colors.green,
              title: "Income",
              radius: 60,
            ),
            PieChartSectionData(
              value: expense == 0 ? 1 : expense.toDouble(),
              color: Colors.red,
              title: "Expense",
              radius: 60,
            ),
          ],
        ),
      ),
    );
  }


  Widget buildBar(Map<String, int> data) {
    if (data.isEmpty) {
      return Center(child: Text("No Category Data"));
    }

    final keys = data.keys.toList();

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < keys.length) {
                    return Text(keys[value.toInt()]);
                  }
                  return Text("");
                },
              ),
            ),
          ),
          barGroups: data.entries.map((e) {
            return BarChartGroupData(
              x: keys.indexOf(e.key),
              barRods: [
                BarChartRodData(
                  toY: e.value.toDouble(),
                  color: Colors.blue,
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }



  Widget buildLineChart(Map<String, int> data) {
    if (data.isEmpty) return SizedBox();

    final keys = data.keys.toList();

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < keys.length) {
                    return Text(keys[value.toInt()]);
                  }
                  return Text("");
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: data.entries.map((e) {
                return FlSpot(
                  keys.indexOf(e.key).toDouble(),
                  e.value.toDouble(),
                );
              }).toList(),
              isCurved: true,
              color: Colors.orange,
              barWidth: 3,
            ),
          ],
        ),
      ),
    );
  }















  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Analytics Dashboard")),
      body: FutureBuilder(
        future: Future.wait([
          getTotalIncome(),
          getTotalExpense(),
          getCategoryWise(),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final income = snapshot.data![0] as int;
          final expense = snapshot.data![1] as int;
          final categoryData = snapshot.data![2] as Map<String, int>;

          final savings = income - expense;

          return ListView(
            padding: EdgeInsets.all(16),
            children: [

              // ---------------- CARDS ----------------
              Card(child: ListTile(title: Text("Income"), trailing: Text("$income"))),
              Card(child: ListTile(title: Text("Expense"), trailing: Text("$expense"))),
              Card(child: ListTile(title: Text("Savings"), trailing: Text("$savings"))),

              SizedBox(height: 20),

              Text("Income vs Expense",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              buildPie(income, expense),

              SizedBox(height: 20),

              Text("Category Wise Expense",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              buildBar(categoryData),




              SizedBox(height: 20),

              Text(
                "Monthly Expenses",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              FutureBuilder(
                future: getMonthlyExpense(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return SizedBox();

                  return buildLineChart(snapshot.data!);
                },
              ),
              
              
              
              
              
              
              
              
              
              
            ],
            
            
            
            
            
            
            
            
          );
        },
      ),
    );
  }
}