import 'package:flutter/material.dart';
import 'package:sudoku/sudoku_item.dart';
import 'package:sudoku_dart/sudoku_dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Sudoku'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
      ],
    );
  }

  Widget game() {
    List<int> currentPuzzle = sudoku!.puzzle;
    int emptyItems = 81;
    SudokuItemState? lastSelected;

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
      int row = index ~/ 9;
      int col = index % 9;

      for (int i = 0; i < 9; i++) {
        int currentIndex = (row * 9) + i;
        if (currentIndex != index && currentPuzzle[currentIndex] == value) {
          return false;
        }
      }

      for (int i = 0; i < 9; i++) {
        int currentIndex = i * 9 + col;
        if (currentIndex != index && currentPuzzle[currentIndex] == value) {
          return false;
        }
      }

      int boxRow = row - (row % 3);
      int boxCol = col - (col % 3);

      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          int currentIndex = (boxRow + i) * 9 + (boxCol + j);
          if (currentIndex != index && currentPuzzle[currentIndex] == value) {
            return false;
          }
        }
      }

      return true;
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
                int value = sudoku!.puzzle[index];

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

                        lastSelected?.resetColor();
                        lastSelected = state;

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

  void _showEndGameDialog(bool win) {
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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            // TRY THIS: Try changing the color here to a specific color (to
            // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
            // change color while the other colors stay the same.
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
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
