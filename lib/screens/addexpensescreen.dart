import 'package:expense_tracker/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Addexpensescreen extends StatefulWidget {
  final String? docId;
  final dynamic existingData;

  Addexpensescreen({this.docId, this.existingData});

  @override
  State<Addexpensescreen> createState() => _AddexpensescreenState();
}

class _AddexpensescreenState extends State<Addexpensescreen> {
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  bool isLoading = false;

  String? selectedCategory;
  String? selectedPayment;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    if (widget.existingData != null) {
      final data = widget.existingData;

      amountController.text = (data['amount'] ?? "").toString();
      descriptionController.text = (data['description'] ?? "").toString();
      selectedCategory = data['category'];
      selectedPayment = data['paymentMethod'];
    }
  }

  // ---------------- SAVE ----------------
  Future<void> saveExpense() async {
    setState(() => isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final data = {
        "amount": int.tryParse(amountController.text.trim()) ?? 0,
        "description": descriptionController.text.trim(),
        "category": selectedCategory ?? "Other",
        "paymentMethod": selectedPayment ?? "Cash",
        "date": selectedDate,
      };

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("expenses")
          .add(data);

      NotificationService.showNotification(
        title: "Expense Added",
        body: "Saved successfully",
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ---------------- UPDATE ----------------
  Future<void> updateExpense() async {
    setState(() => isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("expenses")
          .doc(widget.docId)
          .update({
        "amount": int.tryParse(amountController.text.trim()) ?? 0,
        "description": descriptionController.text.trim(),
        "category": selectedCategory ?? "Other",
        "paymentMethod": selectedPayment ?? "Cash",
        "date": selectedDate,
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.docId == null ? "Add Expense" : "Edit Expense"),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              // AMOUNT
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Amount",
                  prefixIcon: Icon(Icons.money, color: Colors.blue),
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 15),

              // CATEGORY
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: "Category",
                  prefixIcon: Icon(Icons.category, color: Colors.blue),
                  border: OutlineInputBorder(),
                ),
                items: ["Food", "Transport", "Bills", "Shopping"]
                    .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedCategory = value);
                },
              ),

              SizedBox(height: 15),

              // PAYMENT
              DropdownButtonFormField<String>(
                value: selectedPayment,
                decoration: InputDecoration(
                  labelText: "Payment Method",
                  prefixIcon: Icon(Icons.payment, color: Colors.blue),
                  border: OutlineInputBorder(),
                ),
                items: ["Cash", "Card", "Online"]
                    .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedPayment = value);
                },
              ),

              SizedBox(height: 15),

              // DATE PICKER
              GestureDetector(
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );

                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.blue),
                      SizedBox(width: 10),
                      Text(
                        "Date: ${selectedDate.toLocal().toString().split(' ')[0]}",
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 15),

              // DESCRIPTION
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  prefixIcon: Icon(Icons.description, color: Colors.blue),
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 20),

              // BUTTON
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                  if (widget.docId == null) {
                    saveExpense();
                  } else {
                    updateExpense();
                  }
                },
                child: isLoading
                    ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text("Save Expense"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}