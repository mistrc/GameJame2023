import 'package:flame/game.dart';
import 'package:flame01/game/tunnel_game.dart';
import 'package:flutter/widgets.dart';

void main() {
  final game = TunnelGame();
  runApp(GameWidget(game: game));
}
