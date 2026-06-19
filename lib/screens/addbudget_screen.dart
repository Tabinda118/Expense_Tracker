import 'package:expense_tracker/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddbudgetScreen extends StatefulWidget {
  @override
  State<AddbudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddbudgetScreen> {
  final amountController = TextEditingController();

  String? selectedCategory;

  List<String> categories = [
    "Food",
    "Transport",
    "Bills",
    "Shopping"
  ];

  bool isLoading = false;




  Future<void> saveBudget() async {
    setState(() => isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final data = {
        "category": selectedCategory,
        "amount": int.parse(amountController.text.trim()),
        "spent": 0,
      };


      Navigator.pop(context);


      NotificationService.showNotification(
        title: "Budget Added",
        body: "Saved successfully",
      );


      FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("budgets")
          .doc(selectedCategory)
          .set(data);

    } finally {
      setState(() => isLoading = false);
    }
  }











  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Budget")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [

            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
              items: categories.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),

            SizedBox(height: 15),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Budget Amount",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: isLoading ? null : saveBudget,
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Save Budget"),
            ),
          ],
        ),
      ),
    );
  }
}