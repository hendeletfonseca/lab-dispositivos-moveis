import 'package:flutter/material.dart';
import 'package:sudoku/database/db.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<int> selectedLevels = [];
  Map<int, int> levelCounts = {1: 0, 2: 0, 3: 0, 4: 0};

  @override
  void initState() {
    super.initState();
    _updateLevelCounts();
  }

  Future<void> _updateLevelCounts() async {
    final allSudokus = await SudokuDatabase.instance.getAll();
    final counts = {1: 0, 2: 0, 3: 0, 4: 0};

    for (var sudoku in allSudokus) {
      counts[sudoku.level] = (counts[sudoku.level] ?? 0) + 1;
    }

    setState(() {
      levelCounts = counts;
    });
  }

  Future<List<SudokuSchema>> _fetchSudokuList() async {
    final allSudokus = await SudokuDatabase.instance.getAll();
    if (selectedLevels.isEmpty) {
      return allSudokus;
    }
    return allSudokus.where((sudoku) => selectedLevels.contains(sudoku.level)).toList();
  }

  void _toggleLevelFilter(int level) {
    setState(() {
      if (selectedLevels.contains(level)) {
        selectedLevels.remove(level);
      } else {
        selectedLevels.add(level);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 4.0,
              runSpacing: 4.0,
              children: [
                FilterChip(
                  label: const Text('Easy'),
                  selected: selectedLevels.contains(1),
                  onSelected: (_) => _toggleLevelFilter(1),
                ),
                FilterChip(
                  label: const Text('Medium'),
                  selected: selectedLevels.contains(2),
                  onSelected: (_) => _toggleLevelFilter(2),
                ),
                FilterChip(
                  label: const Text('Hard'),
                  selected: selectedLevels.contains(3),
                  onSelected: (_) => _toggleLevelFilter(3),
                ),
                FilterChip(
                  label: const Text('Expert'),
                  selected: selectedLevels.contains(4),
                  onSelected: (_) => _toggleLevelFilter(4),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<SudokuSchema>>(
              future: _fetchSudokuList(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Sem partidas salvas'),
                  );
                }

                final sudokuList = snapshot.data!;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Exibindo ${sudokuList.length} partidas',
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: sudokuList.length,
                        itemBuilder: (context, index) {
                          final sudoku = sudokuList[index];
                          final Map<int, String> difficulties = {
                            1: "Easy",
                            2: "Medium",
                            3: "Hard",
                            4: "Expert"
                          };
                          final String difficulty = difficulties[sudoku.level]!;
                          final String result =
                              sudoku.result == 1 ? 'Vitória' : 'Derrota';
                          return Card(
                            margin: const EdgeInsets.all(8.0),
                            elevation: 4.0,
                            child: ListTile(
                              title: Text(sudoku.name),
                              subtitle: Text(
                                  'Level: $difficulty\nResultado: $result'),
                              trailing: Text(sudoku.date),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
