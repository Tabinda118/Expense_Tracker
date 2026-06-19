import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Budgetscreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("Budget Tracker"),
        backgroundColor: Colors.blue,
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .collection("budgets")
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final budgets = snapshot.data!.docs;

          if (budgets.isEmpty) {
            return Center(
              child: Text("No Budget Added"),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: budgets.length,

            itemBuilder: (context, index) {
              final data =
              budgets[index].data() as Map<String, dynamic>;

              // ---------------- SAFE VALUES ----------------
              int budget = (data['budget'] ?? 0).toInt();
              int spent = (data['spent'] ?? 0).toInt();
              String category = (data['category'] ?? "Other").toString();

              int remaining = budget - spent;
              bool budgetExceeded = spent >= budget;

              double percent = 0;

              if (budget > 0) {
                percent = spent / budget;
              }

              if (percent.isNaN || percent.isInfinite) {
                percent = 0;
              }

              if (percent > 1) percent = 1;

              // ---------------- CARD UI ----------------
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 10),

                      LinearProgressIndicator(
                        value: percent,
                        backgroundColor: Colors.grey.shade300,
                        color: budgetExceeded
                            ? Colors.red
                            : Colors.blue,
                        minHeight: 10,
                      ),

                      SizedBox(height: 10),

                      Text("Spent: $spent / $budget"),
                      Text("Remaining: $remaining"),

                      if (budgetExceeded)
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            "⚠ Budget Limit Exceeded!",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}