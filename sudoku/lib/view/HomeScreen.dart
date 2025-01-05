import 'package:flutter/material.dart';
import 'package:sudoku/database/db.dart';
import 'package:sudoku/sudoku_item.dart';
import 'package:sudoku_dart/sudoku_dart.dart';
import 'package:intl/intl.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool playing = false;
  String username = '';
  Map<String, Level> difficulty = {
    "easy": Level.easy,
    "medium": Level.medium,
    "hard": Level.hard,
    "expert": Level.expert
  };
  String selectedDifficulty = "easy";
  Sudoku? sudoku;

  Color getCellColor(int index) {
    int row = index ~/ 9;
    int columnInRow = index % 9;
    Color cellColor;

    if (row < 3 || row > 5) {
      if (columnInRow < 3) {
        cellColor = Colors.blue[100]!;
      } else if (columnInRow < 6) {
        cellColor = Colors.blue[300]!;
      } else {
        cellColor = Colors.blue[100]!;
      }
    } else {
      if (columnInRow < 3) {
        cellColor = Colors.blue[300]!;
      } else if (columnInRow < 6) {
        cellColor = Colors.blue[100]!;
      } else {
        cellColor = Colors.blue[300]!;
      }
    }
    return cellColor;
  }

  Widget _home() {
    TextEditingController controller = TextEditingController();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          'Digite o nome de usuário:',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 50),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nome de usuário',
              ),
              controller: controller,
            )),
        const SizedBox(height: 50),
        DropdownButton<String>(
          value: selectedDifficulty,
          onChanged: (String? newValue) {
            setState(() {
              selectedDifficulty = newValue!;
            });
          },
          items: difficulty.keys
              .map<DropdownMenuItem<String>>(
                (String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 50),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).clearSnackBars();

            if (controller.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Digite o nome do usuário")),
              );
              return;
            }

            setState(() {
              username = controller.text;
              sudoku = Sudoku.generate(difficulty[selectedDifficulty]!);
              playing = true;
            });
          },
          child: const Text('Jogar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/history', );
          },
          child: const Text('Histórico'),
        ),
      ],
    );
  }

  Widget game() {
    List<int> currentPuzzle = sudoku!.puzzle;
    List<int> solution = sudoku!.solution;
    int emptyItems = currentPuzzle.length;

    void updateEmptyItems() {    
      emptyItems = currentPuzzle.where((element) => element == -1).length;
    }

    Future<int?> getNumber(BuildContext context, int value) {
      return Future.any([
        showDialog<int>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Escolha um número'),
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    10,
                    (index) => ListTile(
                      title: (index != 9)
                          ? Center(child: Text((index + 1).toString()))
                          : const Center(child: Text("Remover valor")),
                      onTap: () {
                        Navigator.of(context)
                            .pop((index != 9) ? index + 1 : -1);
                      },
                    ),
                  )),
            );
          },
        ),
      ]);
    }

    bool isValidMove(int index, int value) {
      if (value == solution[index]) return true;
      return false;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Bem vindo, $username!',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 9,
                crossAxisSpacing: 0.5,
                mainAxisSpacing: 0.5,
                childAspectRatio: 1,
              ),
              itemCount: 81,
              itemBuilder: (context, index) {
                Color cellColor = getCellColor(index);
                int value = currentPuzzle[index];

                return SudokuItem(
                    index: index,
                    value: value,
                    defaultColor: cellColor,
                    onPressed: (state) {
                      if (value != -1) {
                        return;
                      }

                      getNumber(context, value).then((newValue) {
                        if (newValue == null) return;

                        if (newValue == -1) {
                          state.removeValue();
                          currentPuzzle[index] = -1;
                          updateEmptyItems();
                          return;
                        }

                        Color newColor = (isValidMove(index, newValue))
                            ? Colors.green
                            : Colors.red;
                        state.updateCell(newValue, newColor);
                        currentPuzzle[index] = newValue;
                        updateEmptyItems();

                        if (emptyItems == 0) {
                          for (int i = 0; i < 81; i++) {
                            if (currentPuzzle[i] != sudoku!.solution[i]) {
                              _showEndGameDialog(false);
                              return;
                            }
                          }
                          _showEndGameDialog(true);
                        }
                      });
                    });
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showEndGameDialog(bool win) async {
    final Map<String, int> difficulties = {
                            "easy":1,
                            "medium":2,
                            "hard":3,
                            "expert":4
                          };
    final String formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

    SudokuDatabase db = SudokuDatabase.instance;
    await db.insert(SudokuSchema(name: username, result: win ? 1 : 0, date: formattedDate, level: difficulties[selectedDifficulty]!));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(win ? 'Parabéns!' : 'Que pena!'),
          content: Text(
              win ? 'Você completou o jogo!' : 'Você perdeu. Tente novamente!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  playing = false;
                });
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            leading: playing
                ? IconButton(
                    onPressed: () => setState(() {
                      playing = false;
                    }),
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                  )
                : null,
            title: Text(widget.title),
            centerTitle: true,
          ),
          body: playing ? game() : _home(),
          floatingActionButton: playing
              ? FloatingActionButton(
                  onPressed: () {
                    var tempUsername = username;
                    var tempDifficulty = difficulty[selectedDifficulty];
                    setState(() {
                      playing = false;
                    });
                    setState(() {
                      sudoku = Sudoku.generate(tempDifficulty!);
                      username = tempUsername;
                      playing = true;
                    });
                  },
                  tooltip: 'Reiniciar',
                  child: const Icon(Icons.refresh),
                )
              : null,
        ),
        onWillPop: () async {
          if (playing) {
            setState(() {
              playing = false;
            });
            return false;
          }
          return true;
        });
  }
}
