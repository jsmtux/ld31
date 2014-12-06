library behaviour;

import 'dart:math';

import 'package:vector_math/vector_math.dart';
import 'package:game_loop/game_loop_html.dart';

import 'drawable.dart';
import 'element.dart';
import 'base_geometry.dart';

abstract class Behaviour
{
  void init(Drawable drawable);
  void update();
}

class TerrainBehaviour extends Behaviour
{
  Drawable drawable_;
  int num_coords_;
  BaseGeometry terrain_geometry;

  TerrainBehaviour(this.terrain_geometry);

  void init(Drawable drawable)
  {
    drawable_ = drawable;
    num_coords_ = sqrt(terrain_geometry.vertices_.length/3)~/1;
  }
  void update(){}

  Vector3 getAbsolutePos(Vector2 relative)
  {
    Vector3 ret = new Vector3(0.0, 0.0, 0.0);
    ret.xyz = drawable_.position_.xyz;
    ret.xy += relative.xy;

    int int_x = relative.x * 5 ~/ 1;
    int int_y = relative.y * 5 ~/ 1;

    double v_0 = getVertex(int_x, int_y).z;
    double v_1 = getVertex(int_x + 1, int_y).z;
    double v_2 = getVertex(int_x, int_y).z;
    double v_3 = getVertex(int_x, int_y + 1).z;

    double diff_x = relative.x*5 - int_x;
    double diff_y = relative.y*5 - int_y;

    print('diff is $diff_x, $diff_y');

    double inc_x = v_0 * (1 - diff_x) + v_1 * (diff_x);
    double inc_y = v_2 * (1 - diff_y) + v_3 * (diff_y);

    if (v_0 != v_1)
    {
      ret.z += inc_x;
    }
    else
    {
      ret.z += inc_y;
    }

    return ret;
  }

  Vector3 getVertex(int x, int y)
  {
    int number = x * num_coords_ + y;
    int pos = number*3;
    return new Vector3(terrain_geometry.vertices_[pos], terrain_geometry.vertices_[pos+1], terrain_geometry.vertices_[pos+2]);
  }
}

class MainCharacterBehaviour extends Behaviour
{
  Drawable drawable_;
  EngineElement terrain_;
  Keyboard keyboard_;
  Vector2 relative_position_ = new Vector2(0.0,0.0);

  MainCharacterBehaviour(this.terrain_, this.keyboard_);

  void updatePos()
  {
    TerrainBehaviour terrain_behaviour = terrain_.behaviour_;
    drawable_.position_ = terrain_behaviour.getAbsolutePos(relative_position_);
    drawable_.position_.x -= 0.08;
  }

  void init(Drawable drawable)
  {
    drawable_ = drawable;
    updatePos();
    var cur_pos = drawable.position_;
    drawable.size = 0.05;
    Quaternion rot1 = new Quaternion(0.0, 0.0, 0.0, 1.0);
    rot1.setAxisAngle(new Vector3(1.0,0.0,0.0), radians(90.0));
    drawable.rotation_ = rot1;
  }

  void update()
  {
    if(keyboard_.isDown(Keyboard.UP))
    {
      relative_position_ += new Vector2(0.0, 0.01);
    }
    if(keyboard_.isDown(Keyboard.DOWN))
    {
      relative_position_ += new Vector2(0.0, -0.01);
    }
    if(keyboard_.isDown(Keyboard.LEFT))
    {
      relative_position_ += new Vector2(-0.01, 0.0);
    }
    if(keyboard_.isDown(Keyboard.RIGHT))
    {
      relative_position_ += new Vector2(0.01, 0.0);
    }
    updatePos();
  }
}