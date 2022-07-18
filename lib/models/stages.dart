import 'dart:math';

enum Type { greenCovid, redCovid, wall, spray, doctor, empty }

enum Direction { right, left, up, down, stay }

class Stages {
  late List<List<Type>> gameMap;
  final Point<int> doctor;
  final int row;
  final int col;
  final Map<Type, int> randomObjects;
  final List<Map<String, dynamic>> walls;
  final int timeInSeconds;
  int onLevel;

  Stages(
      {required this.onLevel,
      required this.doctor,
      required this.row,
      required this.col,
      required this.randomObjects,
      required this.walls,
      required this.timeInSeconds}) {
    gameMap = List.generate(
        row,
        (r) => List.generate(col, (c) {
              if (r == 0 || r == row - 1 || c == 0 || c == col - 1) {
                return Type.wall;
              }
              return Type.empty;
            }),
        growable: false);
    updateMap();
  }

  updateMap() {
    for (var wall in walls) {
      gameMap[wall['y']][wall['x']] = Type.wall;
    }
    gameMap[doctor.y][doctor.x] = Type.doctor;

    Random random = Random();

    int posX;
    int posY;
    randomObjects.forEach((type, count) {
      for (int i = 0; i < count;) {
        posX = random.nextInt(col);
        posY = random.nextInt(row);

        if (gameMap[posY][posX] == Type.empty) {
          gameMap[posY][posX] = type;
          i++;
        }
      }
    });
  }
}
