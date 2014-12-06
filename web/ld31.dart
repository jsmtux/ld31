import 'dart:html';

import 'package:game_loop/game_loop_html.dart';
import 'package:vector_math/vector_math.dart';

import 'renderer.dart';
import 'element.dart';
import 'base_geometry.dart';
import 'game_state.dart';

main() {
  CanvasElement canvas = querySelector(".game-element");
  GameLoopHtml gameLoop = new GameLoopHtml(canvas);

  Renderer renderer = new Renderer(canvas);
  GameState draw_state = new GameState(renderer);

  List<double> vertices = [
     0.0,  1.0,  0.0,
    -1.0, -1.0,  0.0,
     1.0, -1.0,  0.0
  ];
  List<double> colors = [
    1.0, 0.0, 0.0, 1.0,
    0.0, 1.0, 0.0, 1.0,
    0.0, 0.0, 1.0, 1.0
  ];
  BaseGeometry triangle = new ColoredGeometry(vertices, colors);

  vertices = [
                  1.0,  1.0,  0.0,
                 -1.0,  1.0,  0.0,
                  1.0, -1.0,  0.0,
                 -1.0,  1.0,  0.0,
                  1.0, -1.0,  0.0,
                  -1.0, -1.0,  0.0
             ];
  List<double> coords = [
    1.0, 1.0,
    0.0, 1.0,
    1.0, 0.0,
    0.0, 1.0,
    1.0, 0.0,
    0.0, 0.0
  ];

  BaseGeometry quad = new TexturedGeometry(vertices, coords, "nehe.gif");

  EngineElement e1 = draw_state.addElement(triangle);
  e1.drawable_.position_ = new Vector3(-1.5, 0.0, -7.0);
  Quaternion rotation1 = new Quaternion(0.0,0.0,0.0,1.0);
  rotation1.setAxisAngle(new Vector3(0.0,1.0,0.0), radians(20.0));
  e1.drawable_.rotation_ = rotation1;

  EngineElement e3 = draw_state.addElement(quad);
  e3.drawable_.position_ = new Vector3(1.5, 0.0, -7.0);

  gameLoop.state = new GameState(renderer);

  gameLoop.start();

  renderer.render();
}