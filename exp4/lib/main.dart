
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ExpenseManagerApp());
}

// MAIN APPLICATION
class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Manager',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F6FA),
      ),
      home: const ExpenseHomePage(),
    );
  }
}

// EXPENSE MODEL
class Expense {
  String id;
  double amount;
  String category;
  String description;
  String date;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
  });

  // Convert expense into JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date,
    };
  }

  // Convert JSON into expense
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      category: json['category'],
      description: json['description'],
      date: json['date'],
    );
  }
}

// HOME PAGE
class ExpenseHomePage extends StatefulWidget {
  const ExpenseHomePage({super.key});

  @override
  State<ExpenseHomePage> createState() =>
      _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {

  List<Expense> expenses = [];

  bool isLoading = true;

  final String storageKey = 'expenses';

  // LOAD SAVED EXPENSES
  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();

    final savedData = prefs.getString(storageKey);

    if (savedData != null) {
      final List decodedData = jsonDecode(savedData);

      expenses = decodedData.map((item) {v

        return Expense.fromJson(item);
      }).toList();
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  // SAVE EXPENSES
  Future<void> saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();

    final encodedData = jsonEncode(
      expenses.map((expense) => expense.toJson()).toList(),
    );

    await prefs.setString(storageKey, encodedData);
  }

  // CALCULATE TOTAL EXPENDITURE
  double get totalExpense {
    return expenses.fold(
      0,
      (sum, expense) => sum + expense.amount,
    );
  }

  // ADD EXPENSE
  void addExpense(Expense expense) {
    setState(() {
      expenses.add(expense);
    });

    saveExpenses();
  }

  // EDIT EXPENSE
  void editExpense(Expense updatedExpense) {
    setState(() {
      int index = expenses.indexWhere(
        (e) => e.id == updatedExpense.id,
      );

      if (index != -1) {
        expenses[index] = updatedExpense;
      }
    });

    saveExpenses();
  }

  // DELETE EXPENSE
  void deleteExpense(String id) {
    setState(() {
      expenses.removeWhere((expense) => expense.id == id);
    });

    saveExpenses();
  }

  // SHOW ADD / EDIT FORM
  void showExpenseForm({Expense? expense}) {
    final isEditing = expense != null;

    final amountController = TextEditingController(
      text: expense?.amount.toString() ?? '',
    );

    final descriptionController = TextEditingController(
      text: expense?.description ?? '',
    );

    String selectedCategory =
        expense?.category ?? 'Food';

    DateTime selectedDate = expense != null
        ? DateTime.parse(expense.date)
        : DateTime.now();

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 25,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),

              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        isEditing ? 'Edit Expense' : 'Add Expense',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // AMOUNT
                      TextFormField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Amount (₹)',
                          prefixIcon: Icon(Icons.currency_rupee),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final amount = double.tryParse(value ?? '');

                          if (amount == null || amount <= 0) {
                            return 'Enter a valid amount';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      // CATEGORY
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          'Food',
                          'Travel',
                          'Shopping',
                          'Education',
                          'Entertainment',
                          'Bills',
                          'Health',
                          'Other',
                        ].map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            modalSetState(() {
                              selectedCategory = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 15),

                      // DESCRIPTION
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter a description';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      // DATE PICKER
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.calendar_month,
                          color: Colors.indigo,
                        ),
                        title: const Text('Expense Date'),
                        subtitle: Text(
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        ),
                        trailing: const Icon(Icons.edit_calendar),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );

                          if (picked != null) {
                            modalSetState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      // SAVE BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {

                              final newExpense = Expense(
                                id: expense?.id ??
                                    DateTime.now().microsecondsSinceEpoch.toString(),
                                amount: double.parse(
                                  amountController.text,
                                ),
                                category: selectedCategory,
                                description: descriptionController.text.trim(),
                                date: selectedDate.toIso8601String(),
                              );

                              if (isEditing) {
                                editExpense(newExpense);
                              } else {
                                addExpense(newExpense);
                              }

                              Navigator.pop(context);
                            }
                          },
                          child: Text(
                            isEditing ? 'Update Expense' : 'Save Expense',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      amountController.dispose();
      descriptionController.dispose();
    });
  }

  // DELETE CONFIRMATION
  void confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Expense?'),
          content: const Text(
            'Are you sure you want to delete this expense?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteExpense(id);
                Navigator.pop(context);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // MAIN UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Personal Expense Manager',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showExpenseForm(),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),

      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [

                  // TOTAL EXPENSE CARD
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Total Expenditure',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '₹ ${totalExpense.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${expenses.length} Expenses Recorded',
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // EXPENSE LIST HEADING
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 5,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Recent Expenses',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // LIST VIEW
                  Expanded(
                    child: expenses.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 70,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'No expenses yet!',
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  'Tap Add Expense to get started.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              12, 5, 12, 90,
                            ),
                            itemCount: expenses.length,
                            itemBuilder: (context, index) {

                              final expense = expenses[index];

                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 7,
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.indigo.shade50,
                                    child: Icon(
                                      getCategoryIcon(expense.category),
                                      color: Colors.indigo,
                                    ),
                                  ),

                                  title: Text(
                                    expense.description,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  subtitle: Text(
                                    '${expense.category} • ${expense.date.substring(0, 10)}',
                                  ),

                                  trailing: SizedBox(
                                    width: 125,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            '₹${expense.amount.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              showExpenseForm(
                                                expense: expense,
                                              );
                                            } else if (value == 'delete') {
                                              confirmDelete(expense.id);
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit),
                                                  SizedBox(width: 10),
                                                  Text('Edit'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text('Delete'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  // CATEGORY ICON
  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Travel':
        return Icons.directions_bus;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Education':
        return Icons.school;
      case 'Entertainment':
        return Icons.movie;
      case 'Bills':
        return Icons.receipt;
      case 'Health':
        return Icons.local_hospital;
      default:
        return Icons.money;
    }
  }
}
