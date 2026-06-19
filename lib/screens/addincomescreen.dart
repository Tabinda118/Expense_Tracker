import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Addincomescreen extends StatefulWidget {
  final String? docId;
  final dynamic existingData;

  Addincomescreen({this.docId, this.existingData});

  @override
  State<Addincomescreen> createState() => _AddincomescreenState();
}

class _AddincomescreenState extends State<Addincomescreen> {
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  bool isLoading = false;

  String? selectedSource;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    if (widget.existingData != null) {
      amountController.text =
          (widget.existingData['amount'] ?? 0).toString();

      descriptionController.text =
      (widget.existingData['description'] ?? "");

      selectedSource =
          widget.existingData['source'] ?? "Salary";

      final ts = widget.existingData['date'];
      if (ts is Timestamp) {
        selectedDate = ts.toDate();
      }
    }
  }

  // ---------------- SAVE ----------------
  Future<void> saveIncome() async {
    setState(() => isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final data = {
        "amount": int.tryParse(amountController.text.trim()) ?? 0,
        "description": descriptionController.text.trim(),
        "source": selectedSource ?? "Salary",
        "date": selectedDate,
      };

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("income")
          .add(data);

      NotificationService.showNotification(
        title: "Income Added",
        body: "Saved successfully",
      );

      Navigator.pop(context);
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ---------------- UPDATE ----------------
  Future<void> updateIncome() async {
    setState(() => isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("income")
          .doc(widget.docId)
          .update({
        "amount": int.tryParse(amountController.text.trim()) ?? 0,
        "description": descriptionController.text.trim(),
        "source": selectedSource ?? "Salary",
        "date": selectedDate,
      });

      Navigator.pop(context);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.docId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Income" : "Add Income"),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              // ---------------- AMOUNT ----------------
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

              // ---------------- SOURCE ----------------
              DropdownButtonFormField<String>(
                value: selectedSource,
                decoration: InputDecoration(
                  labelText: "Income Source",
                  prefixIcon: Icon(Icons.account_balance_wallet,
                      color: Colors.blue),
                  border: OutlineInputBorder(),
                ),
                items: [
                  "Salary",
                  "Freelancing",
                  "Business",
                  "Bonus",
                  "Other"
                ]
                    .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedSource = value);
                },
              ),

              SizedBox(height: 15),

              // ---------------- DATE ----------------
              InkWell(
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
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
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

              // ---------------- DESCRIPTION ----------------
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  prefixIcon: Icon(Icons.description,
                      color: Colors.blue),
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 20),

              // ---------------- BUTTON ----------------
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                  if (isEdit) {
                    updateIncome();
                  } else {
                    saveIncome();
                  }
                },
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(isEdit ? "Update Income" : "Save Income"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}