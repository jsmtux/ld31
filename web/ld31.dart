import 'dart:html';

import 'package:game_loop/game_loop_html.dart';
import 'package:vector_math/vector_math.dart';

import 'renderer.dart';
import 'element.dart';
import 'top_terrain.dart';
import 'game_state.dart';
import 'terrain.dart';
import 'base_geometry.dart';
import 'geometry_data.dart';
import 'behaviour.dart';

main() {
  CanvasElement canvas = querySelector(".game-element");
  GameLoopHtml gameLoop = new GameLoopHtml(canvas);

  Renderer renderer = new Renderer(canvas);
  GameState draw_state = new GameState(renderer);

  renderer.m_worldview_.translate(-1.4, 2.0, -1.0);
  renderer.m_worldview_.rotate(new Vector3(1.0,0.0,0.0), radians(-45.0));

  Terrain terrain = createTopTerrain();
  BaseGeometry terrain_geometry = terrain.calculateBaseGeometry();
  EngineElement terrain_element = draw_state.addElement(terrain_geometry, new TerrainBehaviour(terrain_geometry));
  terrain_element.drawable_.position_ = new Vector3(.0, -0.7, -3.0);

  BaseGeometry quad = new TexturedGeometry(quad_vertices, quad_indices, quad_coords, "nehe.gif");
  EngineElement main_char = draw_state.addElement(quad, new MainCharacterBehaviour(terrain_element, gameLoop.keyboard));

  gameLoop.state = draw_state;

  gameLoop.start();
}