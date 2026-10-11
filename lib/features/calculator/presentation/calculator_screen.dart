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
    'AA [10]': 10.0,
    'AB [9]': 9.0,
    'BB [8]': 8.0,
    'BC [7]': 7.0,
    'CC [6]': 6.0,
    'CD [5]': 5.0,
    'DD [4]': 4.0,
    'FF (Fail) [0]': 0.0,
  };

  int _currentSemester = 1;
  bool _useSemesterWise = true;
  final List<TextEditingController> _prevSgpaControllers = [];

  @override
  void dispose() {
    _priorCgpaController.dispose();
    _priorCreditsController.dispose();
    for (var c in _prevSgpaControllers) {
      c.dispose();
    }
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

  double? _calculateCgpa(double currentSgpa, int currentCredits) {
    if (_useSemesterWise) {
      if (_currentSemester <= 1) return null;
      double totalSgpa = currentSgpa;
      int count = 1;
      for (var controller in _prevSgpaControllers) {
        final val = double.tryParse(controller.text.trim());
        if (val == null) {
          return null; // Return null if any of the fields are empty or invalid
        }
        totalSgpa += val;
        count++;
      }
      return totalSgpa / count;
    } else {
      final priorCgpa = double.tryParse(_priorCgpaController.text.trim());
      final priorCredits = int.tryParse(_priorCreditsController.text.trim());

      if (priorCgpa == null || priorCredits == null || priorCredits <= 0) return null;

      final totalPoints = (priorCgpa * priorCredits) + (currentSgpa * currentCredits);
      final totalCredits = priorCredits + currentCredits;

      return totalPoints / totalCredits;
    }
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
            // SGPA Card Summary with Gradient and positive vibes
            Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                  child: Column(
                    children: [
                      Text(
                        'SEMESTER SGPA',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sgpa.toStringAsFixed(2),
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Credits: $currentCredits',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
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
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: sub.name,
                                decoration: const InputDecoration(
                                  labelText: 'Subject Name',
                                  hintText: 'e.g. Mathematics II',
                                  border: UnderlineInputBorder(),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                                ),
                                onChanged: (val) {
                                  sub.name = val;
                                },
                              ),
                            ),
                            IconButton(
                              onPressed: () => _removeSubject(sub.id),
                              icon: const Icon(Icons.delete_outline),
                              color: theme.colorScheme.error,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: sub.credits,
                                decoration: const InputDecoration(
                                  labelText: 'Credits',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
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
                                    child: Text('$c Credits'),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<double>(
                                value: sub.gradeValue,
                                decoration: const InputDecoration(
                                  labelText: 'Grade',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
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
                          ],
                        ),
                      ],
                    ),
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
                  child: ChoiceChip(
                    label: const Center(child: Text('By Previous SGPAs')),
                    selected: _useSemesterWise,
                    onSelected: (val) => setState(() => _useSemesterWise = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('By Total Credits')),
                    selected: !_useSemesterWise,
                    onSelected: (val) => setState(() => _useSemesterWise = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_useSemesterWise) ...[
              DropdownButtonFormField<int>(
                value: _currentSemester,
                decoration: const InputDecoration(
                  labelText: 'Current Semester (Determines previous sem count)',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(8, (i) => i + 1).map((sem) {
                  return DropdownMenuItem(
                    value: sem,
                    child: Text('Semester $sem'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _currentSemester = val;
                      final targetCount = _currentSemester - 1;
                      while (_prevSgpaControllers.length < targetCount) {
                        _prevSgpaControllers.add(TextEditingController());
                      }
                      while (_prevSgpaControllers.length > targetCount) {
                        _prevSgpaControllers.last.dispose();
                        _prevSgpaControllers.removeLast();
                      }
                    });
                  }
                },
              ),
              if (_currentSemester > 1) ...[
                const SizedBox(height: 16),
                Text(
                  'Previous Semesters SGPAs',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _prevSgpaControllers.length,
                  itemBuilder: (context, idx) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: TextFormField(
                        controller: _prevSgpaControllers[idx],
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Semester ${idx + 1} SGPA',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onChanged: (val) => setState(() {}),
                      ),
                    );
                  },
                ),
              ],
            ] else ...[
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
            ],
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
