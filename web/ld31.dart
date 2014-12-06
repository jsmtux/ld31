import 'dart:html';

import 'package:game_loop/game_loop_html.dart';
import 'package:vector_math/vector_math.dart';

import 'renderer.dart';
import 'element.dart';
import 'top_terrain.dart';
import 'game_state.dart';
import 'terrain.dart';

main() {
  CanvasElement canvas = querySelector(".game-element");
  GameLoopHtml gameLoop = new GameLoopHtml(canvas);

  Renderer renderer = new Renderer(canvas);
  GameState draw_state = new GameState(renderer);

  Terrain terrain = createTopTerrain();
  EngineElement e2 = draw_state.addElement(terrain.calculateBaseGeometry());
  e2.drawable_.position_ = new Vector3(.0, -1.0, -3.0);

  Quaternion rotation1 = new Quaternion(0.0,0.0,0.0,1.0);
  rotation1.setEuler(radians(0.0), radians(-40.0), radians(45.0));
  e2.drawable_.rotation_ = rotation1;

  gameLoop.state = new GameState(renderer);

  gameLoop.start();

  renderer.render();
}