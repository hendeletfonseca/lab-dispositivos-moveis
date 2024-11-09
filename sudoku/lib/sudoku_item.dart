import 'package:flutter/material.dart';

class SudokuItem extends StatefulWidget {
  final int index;
  int value;
  final Color defaultColor;
  Color? cellColor;
  final void Function(SudokuItemState state)? onPressed;

  SudokuItem({
    super.key,
    required this.index,
    required this.value,
    required this.defaultColor,
    this.onPressed,
  });

  @override
  State<SudokuItem> createState() => SudokuItemState();
}

class SudokuItemState extends State<SudokuItem> {
  @override
  Widget build(BuildContext context) {
    widget.cellColor ??= widget.defaultColor;
    return GestureDetector(
      onTap: () {
        if (widget.onPressed != null) {
          widget.onPressed!(this);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: widget.cellColor,
          border: Border.all(color: Colors.black),
        ),
        child: Center(
          child: Text(
            widget.value == -1 ? '' : widget.value.toString(),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  // Método para atualizar o valor e a cor da célula
  void updateCell(int newValue, Color newColor) {
    setState(() {
      widget.value = newValue;
      widget.cellColor = newColor;
    });
  }

  void removeValue() {
    setState(() {
      widget.value = -1;
      widget.cellColor = widget.defaultColor;
    });
  }

  void resetColor() {
    setState(() {
      widget.cellColor = widget.defaultColor;
    });
  }
}
