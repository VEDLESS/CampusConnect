import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class SubjectRow {
  SubjectRow({
    required this.id,
    this.name = '',
    this.credits = 3,
    this.gradeValue = 10.0,
  });

  final String id;
  String name;
  int credits;
  double gradeValue;
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final List<SubjectRow> _subjects = [
    SubjectRow(id: '1', name: 'Subject 1', credits: 4, gradeValue: 10.0),
    SubjectRow(id: '2', name: 'Subject 2', credits: 3, gradeValue: 9.0),
    SubjectRow(id: '3', name: 'Subject 3', credits: 3, gradeValue: 8.0),
  ];

  final _priorCgpaController = TextEditingController();
  final _priorCreditsController = TextEditingController();

  final Map<String, double> _gradePoints = {
    'O (Outstanding) [10]': 10.0,
    'A+ (Excellent) [9]': 9.0,
    'A (Very Good) [8]': 8.0,
    'B+ (Good) [7]': 7.0,
    'B (Above Average) [6]': 6.0,
    'C (Average) [5]': 5.0,
    'F (Fail) [0]': 0.0,
  };

  @override
  void dispose() {
    _priorCgpaController.dispose();
    _priorCreditsController.dispose();
    super.dispose();
  }

  void _addSubject() {
    setState(() {
      final newId = DateTime.now().millisecondsSinceEpoch.toString();
      _subjects.add(SubjectRow(id: newId, name: 'Subject ${_subjects.length + 1}', credits: 3, gradeValue: 9.0));
    });
  }

  void _removeSubject(String id) {
    if (_subjects.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one subject is required.')),
      );
      return;
    }
    setState(() {
      _subjects.removeWhere((sub) => sub.id == id);
    });
  }

  double _calculateSgpa() {
    double totalPoints = 0.0;
    int totalCredits = 0;

    for (var sub in _subjects) {
      totalPoints += (sub.gradeValue * sub.credits);
      totalCredits += sub.credits;
    }

    if (totalCredits == 0) return 0.0;
    return totalPoints / totalCredits;
  }

  int _getTotalCredits() {
    return _subjects.fold(0, (sum, sub) => sum + sub.credits);
  }

  double? _calculateCgpa(double sgpa, int currentCredits) {
    final priorCgpa = double.tryParse(_priorCgpaController.text.trim());
    final priorCredits = int.tryParse(_priorCreditsController.text.trim());

    if (priorCgpa == null || priorCredits == null || priorCredits <= 0) return null;

    final totalPoints = (priorCgpa * priorCredits) + (sgpa * currentCredits);
    final totalCredits = priorCredits + currentCredits;

    return totalPoints / totalCredits;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sgpa = _calculateSgpa();
    final currentCredits = _getTotalCredits();
    final cgpa = _calculateCgpa(sgpa, currentCredits);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GPA / CGPA Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // SGPA Card Summary
            Card(
              color: theme.colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                child: Column(
                  children: [
                    Text(
                      'SEMESTER SGPA',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sgpa.toStringAsFixed(2),
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Credits: $currentCredits',
                      style: TextStyle(color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Subject Rows
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subjects & Grades',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _addSubject,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Subject'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _subjects.length,
              itemBuilder: (context, index) {
                final sub = _subjects[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      // Credits dropdown
                      Container(
                        width: 70,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.colorScheme.outlineVariant),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: sub.credits,
                            isExpanded: true,
                            alignment: Alignment.center,
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  sub.credits = val;
                                });
                              }
                            },
                            items: List.generate(6, (i) => i).map((c) {
                              return DropdownMenuItem(
                                value: c,
                                child: Center(child: Text('$c Cr')),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Grade Dropdown
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.colorScheme.outlineVariant),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<double>(
                              value: sub.gradeValue,
                              isExpanded: true,
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    sub.gradeValue = val;
                                  });
                                }
                              },
                              items: _gradePoints.entries.map((entry) {
                                return DropdownMenuItem(
                                  value: entry.value,
                                  child: Text(entry.key),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Remove Button
                      IconButton(
                        onPressed: () => _removeSubject(sub.id),
                        icon: const Icon(Icons.delete_outline),
                        color: theme.colorScheme.error,
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(height: 32),

            // CGPA Calculation Section
            Text(
              'Calculate Cumulative CGPA (Optional)',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priorCgpaController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Prior CGPA',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _priorCreditsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Prior Total Credits',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (cgpa != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ESTIMATED CUMULATIVE CGPA:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                    Text(
                      cgpa.toStringAsFixed(2),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
