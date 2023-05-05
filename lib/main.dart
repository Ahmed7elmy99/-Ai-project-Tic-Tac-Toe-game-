import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      home: TicTacToeScreen(),
    );
  }
}

class TicTacToeScreen extends StatefulWidget {
  @override
  _TicTacToeScreenState createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  static const int BOARD_SIZE = 9;
  static const String EMPTY_CELL = '';

  List<String> board = List.filled(BOARD_SIZE, EMPTY_CELL);
  String currentPlayer = 'X';
  bool gameEnded = false;
  bool twoPlayersMode = false;
  String winner = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic Tac Toe'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
              ),
              itemCount: BOARD_SIZE,
              itemBuilder: (BuildContext context, int index) {
                return _buildGridCell(index);
              },
            ),
            SizedBox(height: 20),
            winner.isEmpty && !gameEnded
                ? Text('$currentPlayer\'s turn')
                : winner.isNotEmpty
                    ? Text('Winner: $winner')
                    : Text('Draw!'),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: twoPlayersMode,
                  onChanged: (value) {
                    setState(() {
                      twoPlayersMode = value!;
                      _resetGame();
                    });
                  },
                ),
                Text('Two Players mode'),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: gameEnded ? _resetGame : null,
              child: Text(gameEnded ? 'Play again' : 'Reset'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCell(int index) {
    return GestureDetector(
      onTap: () {
        if (board[index] == EMPTY_CELL && !gameEnded) {
          setState(() {
            board[index] = currentPlayer;
            _checkWinner();
            if (winner.isEmpty) {
              if (twoPlayersMode) {
                currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
              } else {
                _aiMove();
                _checkWinner();
              }
            }
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
        ),
        child: Center(
          child: Text(
            board[index],
            style: TextStyle(fontSize: 50),
          ),
        ),
      ),
    );
  }

  void _checkWinner() {
    for (int i = 0; i < BOARD_SIZE; i += 3) {
      if (board[i] == board[i + 1] && board[i + 1] == board[i + 2] && board[i] != EMPTY_CELL) {
        _endGame(board[i]);
        return;
      }
    }
    for (int i = 0; i < 3; i++) {
      if (board[i] == board[i + 3] && board[i + 3] == board[i + 6] && board[i] != EMPTY_CELL) {
        _endGame(board[i]);
        return;
      }
    }
    if (board[0] == board[4] && board[4] == board[8] && board[0] != EMPTY_CELL) {
      _endGame(board[0]);
      return;
    }
    if (board[2] == board[4] && board[4] == board[6] && board[2] != EMPTY_CELL) {
      _endGame(board[2]);
      return;
    }
    if (board.every((cell) => cell != EMPTY_CELL)) {
      _endGame('');
      return;
    }
  }

  void _endGame(String winner) {
    setState(() {
      gameEnded = true;
      this.winner = winner;
    });
  }

  void _resetGame() {
    setState(() {
      board = List.filled(BOARD_SIZE, EMPTY_CELL);
      currentPlayer = 'X';
      gameEnded = false;
      winner = '';
    });
  }

  void _aiMove() {
    int bestScore = -1000;
    int move = -1;
    for (int i = 0; i < BOARD_SIZE; i++) {
      if (board[i] == EMPTY_CELL) {
        board[i] = 'O';
        int score = _minimax(board, 0, false);
        board[i] = EMPTY_CELL;
        if (score > bestScore) {
          bestScore = score;
          move = i;
        }
      }
    }
    board[move] = 'O';
    currentPlayer = 'X';
  }

  int _minimax(List<String> board, int depth, bool isMaximizing) {
    String winner = _checkBoard(board);
    if (winner.isNotEmpty) {
      return winner == 'O' ? 10 - depth : depth - 10;
    }
    if (board.every((cell) => cell != EMPTY_CELL)) {
      return 0;
    }
    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < BOARD_SIZE; i++) {
        if (board[i] == EMPTY_CELL) {
          board[i] = 'O';
          int score = _minimax(board, depth + 1, false);
          board[i] = EMPTY_CELL;
          bestScore = max(bestScore, score);
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < BOARD_SIZE; i++) {
        if (board[i] == EMPTY_CELL) {
          board[i] = 'X';
          int score = _minimax(board, depth + 1, true);
          board[i] = EMPTY_CELL;
          bestScore = min(bestScore, score);
        }
      }
      return bestScore;
    }
  }

  String _checkBoard(List<String> board) {
    for (int i = 0; i < BOARD_SIZE; i += 3) {
      if (board[i] == board[i + 1] && board[i + 1] == board[i + 2] && board[i] != EMPTY_CELL) {
        return board[i];
      }
    }
    for (int i = 0; i < 3; i++) {
      if (board[i] == board[i + 3] && board[i + 3] == board[i + 6] && board[i] != EMPTY_CELL) {
        return board[i];
      }
    }
    if (board[0] == board[4] && board[4] == board[8] && board[0] != EMPTY_CELL) {
      return board[0];
    }
    if (board[2] == board[4] && board[4] == board[6] && board[2] != EMPTY_CELL) {
      return board[2];
    }
    return '';
  }
}
