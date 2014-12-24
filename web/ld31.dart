import 'dart:html';
import 'dart:math';

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

  window.location.assign("#initMenu");

  Renderer renderer = new Renderer(canvas);
  GameState draw_state = new GameState(renderer);

  renderer.m_worldview_.translate(-1.5, 2.0, -1.0);
  renderer.m_worldview_.rotate(new Vector3(1.0,0.0,0.0), radians(-45.0));

  Terrain terrain = createTopTerrain();
  BaseGeometry terrain_geometry = terrain.calculateBaseGeometry();
  EngineElement terrain_element = draw_state.addElement(terrain_geometry, new TerrainBehaviour(terrain_geometry));
  terrain_element.drawable_.position_ = new Vector3(.0, -0.7, -3.0);

  BaseGeometry quad = new TexturedGeometry(quad_vertices, quad_indices, quad_coords, "nehe.gif");
  EngineElement main_char = draw_state.addElement(quad, new MainCharacterBehaviour(terrain_element, gameLoop.keyboard));

  BaseGeometry wolf_quad = new TexturedGeometry(quad_vertices, quad_indices, quad_coords, "wolf.gif");
  draw_state.addElement(wolf_quad, new WolfBehaviour(terrain_element, new Vector2(6.5,0.5), new Vector2(1.5,2.0), 0.005));
  draw_state.addElement(wolf_quad, new WolfBehaviour(terrain_element, new Vector2(9.5,0.5), new Vector2(1.5,4.5), 0.007));
  draw_state.addElement(wolf_quad, new WolfBehaviour(terrain_element, new Vector2(8.0,5.5), new Vector2(1.5,2.0), 0.002));
  draw_state.addElement(wolf_quad, new WolfBehaviour(terrain_element, new Vector2(11.0,4.5), new Vector2(1.5,2.0), 0.004));

  BaseGeometry sheep_quad = new TexturedGeometry(quad_vertices, quad_indices, quad_coords, "sheep.gif");
  for (int i = 0; i < 40; i++)
  {
    Random rng = new Random();
    draw_state.addElement(sheep_quad, new SheepBehaviour(terrain_element, new Vector2(rng.nextDouble()*3.0+0.5,rng.nextDouble()*3.0+0.5), 1));
  }

  BaseGeometry sheep_cool_quad = new TexturedGeometry(quad_vertices, quad_indices, quad_coords, "sheep_cool.gif");
  for (int i = 0; i < 3; i++)
  {
    Random rng = new Random();
    draw_state.addElement(sheep_cool_quad, new SheepBehaviour(terrain_element, new Vector2(rng.nextDouble()*1.0+0.5,rng.nextDouble()*1.0+12.0),3));
  }

  BaseGeometry sheep_gold_quad = new TexturedGeometry(quad_vertices, quad_indices, quad_coords, "sheep_gold.gif");
  for (int i = 0; i < 5; i++)
  {
    Random rng = new Random();
    draw_state.addElement(sheep_gold_quad, new SheepBehaviour(terrain_element, new Vector2(rng.nextDouble()*1.0+0.5,rng.nextDouble()*1.0+6.0),2));
  }

  BaseGeometry tree_quad = new TexturedGeometry(quad_vertices, quad_indices, quad_coords, "tree.gif");
  draw_state.addElement(tree_quad, new ObstacleBehaviour(terrain_element, new Vector2(1.59,0.67)));
  draw_state.addElement(tree_quad, new ObstacleBehaviour(terrain_element, new Vector2(1.33,0.65)));
  draw_state.addElement(tree_quad, new ObstacleBehaviour(terrain_element, new Vector2(2.27,1.06)));
  draw_state.addElement(tree_quad, new ObstacleBehaviour(terrain_element, new Vector2(1.57,1.74)));
  draw_state.addElement(tree_quad, new ObstacleBehaviour(terrain_element, new Vector2(1.12,1.68)));
  draw_state.addElement(tree_quad, new ObstacleBehaviour(terrain_element, new Vector2(1.95,2.17)));
  draw_state.addElement(tree_quad, new ObstacleBehaviour(terrain_element, new Vector2(0.45,1.464)));
  draw_state.addElement(tree_quad, new ObstacleBehaviour(terrain_element, new Vector2(0.25,1.464)));
  draw_state.addElement(tree_quad, new ObstacleBehaviour(terrain_element, new Vector2(0.05,1.464)));
  draw_state.addElement(tree_quad, new ObstacleBehaviour(terrain_element, new Vector2(0.94,1.76)));

  for (int i = 0; i < 9; i++)
  {
    draw_state.addElement(tree_quad, new ObstacleBehaviour(terrain_element, new Vector2(0.08 + i*0.2,0.9)));
  }
  for (int i = 0; i < 3; i++)
  {
    draw_state.addElement(tree_quad, new ObstacleBehaviour(terrain_element, new Vector2(1.08,0.7 - i*0.2)));
  }
  for (int i = 0; i < 2; i++)
  {
    draw_state.addElement(tree_quad, new ObstacleBehaviour(terrain_element, new Vector2(2.32 + i*0.2,0.51)));
  }
  for (int i = 0; i < 4; i++)
  {
    draw_state.addElement(tree_quad, new ObstacleBehaviour(terrain_element, new Vector2(1.75 + i *0.2,1.67)));
  }
  for (int i = 0; i < 4; i++)
  {
    draw_state.addElement(tree_quad, new ObstacleBehaviour(terrain_element, new Vector2(1.75 - i *0.2,2.0)));
  }

  for (int i = 0; i < 5; i++)
  {
    draw_state.addElement(tree_quad, new ObstacleBehaviour(terrain_element, new Vector2(0.74,1.76 + i * 0.2)));
  }

  gameLoop.state = draw_state;

  gameLoop.start();
}