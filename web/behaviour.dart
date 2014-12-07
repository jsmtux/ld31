library behaviour;

import 'dart:math';

import 'package:vector_math/vector_math.dart';
import 'package:game_loop/game_loop_html.dart';

import 'drawable.dart';
import 'element.dart';
import 'base_geometry.dart';
import 'game_state.dart';

abstract class Behaviour
{
  void init(Drawable drawable);
  void update(GameState state);
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
  void update(GameState state){}

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

class SceneElementBehaviour extends Behaviour
{
  Drawable drawable_;
  EngineElement terrain_;
  Vector2 relative_position_ = new Vector2(0.0,0.0);

  SceneElementBehaviour(this.terrain_);

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
    drawable.size = 0.08;
    Quaternion rot1 = new Quaternion(0.0, 0.0, 0.0, 1.0);
    rot1.setAxisAngle(new Vector3(1.0,0.0,0.0), radians(90.0));
    drawable.rotation_ = rot1;
  }

  void update(GameState state){}

}

double calculateVectorLength(Vector2 vec)
{
  return vec.x * vec.x + vec.y * vec.y;
}

class FollowableBehaviour extends SceneElementBehaviour
{
  FollowableBehaviour(EngineElement terrain) : super(terrain);
  FollowerBehaviour followed_;
}

class FollowerBehaviour extends FollowableBehaviour
{
  FollowerBehaviour(EngineElement terrain, this.following_, this.speed_, SceneElementBehaviour previous)
  :super(terrain)
  {
    drawable_ = previous.drawable_;
    relative_position_ = previous.relative_position_;

    while(following_.followed_!=null)
    {
      following_ = following_.followed_;
    }
    following_.followed_ = this;
  }

  void remove()
  {
    following_.followed_ = null;
  }

  FollowableBehaviour following_;
  double speed_;
  bool walking_ = false;

  void update(GameState state)
  {
    Vector2 diff = following_.relative_position_ - relative_position_;
    var len = calculateVectorLength(diff);

    if (walking_)
    {
      if (len > 0.01)
      {
        relative_position_ += diff.normalize() * speed_;
        updatePos();
      }
      else
      {
        walking_ = false;
      }
    }
    else
    {
      if (len > 0.02)
      {
        walking_ = true;
      }
    }
  }
}

class DeadSheepBehaviour extends SceneElementBehaviour
{
  DeadSheepBehaviour() : super (null);

  void update(GameState state)
  {
    drawable_.position_ = new Vector3(0.0, 0.0, 0.0);
  }
}

class SheepBehaviour extends SceneElementBehaviour
{
  Vector2 initial_position_;
  Vector2 walk_initial_position_ = new Vector2(0.0,0.0);
  Random rng = new Random();
  Vector2 random_position_;
  int wait_time_;
  SheepBehaviour(EngineElement terrain, Vector2 initial_position)
  : super(terrain)
  {
    initial_position_ = initial_position / 5.0;
  }

  void init(Drawable drawable)
  {
    super.init(drawable);
    relative_position_.xy = initial_position_.xy;
    wait_time_ = rng.nextInt(300);
    updatePos();
  }

  void update(GameState state)
  {
    if(random_position_ == null)
    {
      if(wait_time_ == 300)
      {
        random_position_ = new Vector2(rng.nextDouble()/10, rng.nextDouble()/10);
        random_position_ = initial_position_ + random_position_;
        walk_initial_position_.xy = relative_position_.xy;
        wait_time_ = rng.nextInt(150);
      }
      else
      {
        wait_time_ = wait_time_ + 1;
      }
    }
    else
    {
      Vector2 diff = relative_position_ - random_position_;
      if (diff.x.abs() < 0.001 && diff.y.abs() < 0.001)
      {
        random_position_ = null;
      }
      else
      {
        Vector2 diff = (random_position_ - walk_initial_position_)/100.0;
        relative_position_ += diff;
        updatePos();
      }
    }
  }
}

EngineElement getClosestSheep(GameState state, Vector2 relative_position)
{
  EngineElement sheep_found;

  double min_distance = 100.0;
  for(EngineElement e in state.elements_)
  {
    if (e.behaviour_ is SheepBehaviour)
    {
      SheepBehaviour sheep = e.behaviour_;
      Vector2 diff = sheep.relative_position_ - relative_position;
      double dist = calculateVectorLength(diff);
      if(dist < min_distance)
      {
        min_distance = dist;
        sheep_found = e;
      }
    }
  }

  return sheep_found;
}

class MainCharacterBehaviour extends FollowableBehaviour
{
  Keyboard keyboard_;
  bool space_key_released_ = true;
  MainCharacterBehaviour(EngineElement terrain, this.keyboard_) : super(terrain);

  void update(GameState state)
  {
    if(keyboard_.isDown(Keyboard.UP))
    {
      relative_position_ += new Vector2(0.0, 0.005);
    }
    if(keyboard_.isDown(Keyboard.DOWN))
    {
      relative_position_ += new Vector2(0.0, -0.005);
    }
    if(keyboard_.isDown(Keyboard.LEFT))
    {
      relative_position_ += new Vector2(-0.005, 0.0);
    }
    if(keyboard_.isDown(Keyboard.RIGHT))
    {
      relative_position_ += new Vector2(0.005, 0.0);
    }
    if(keyboard_.isDown(Keyboard.SPACE))
    {
      if (space_key_released_)
      {
        EngineElement sheep_found = getClosestSheep(state, relative_position_);
        if (sheep_found != null)
        {
          SheepBehaviour previous_behaviour = sheep_found.behaviour_;
          Vector2 diff = relative_position_ - previous_behaviour.relative_position_;
          if(calculateVectorLength(diff) < 0.1)
          {
            FollowerBehaviour sheep_behaviour = new FollowerBehaviour(terrain_ ,this, 0.005, sheep_found.behaviour_);
            sheep_found.behaviour_ = sheep_behaviour;
          }
        }
        else
        {
          print('no sheep found');
        }
      }
      space_key_released_ = false;
    }
    else
    {
      space_key_released_ = true;
    }
    updatePos();
  }
}

class WolfBehaviour extends SceneElementBehaviour
{
  WolfBehaviour(EngineElement terrain, Vector2 initial_position, Vector2 movement, this.speed_)
    : super(terrain)
  {
    initial_position_ = initial_position / 5.0;
    movement_ = movement / 5.0;
  }
  int dir = 0;
  Vector2 initial_position_;
  Vector2 movement_;
  double speed_;
  Vector2 initial_run_position_;
  SceneElementBehaviour chasing_sheep_;
  EngineElement sheep_element_;
  int sleep_time_ = 0;

  void init(Drawable drawable)
  {
    super.init(drawable);
    relative_position_.xy = initial_position_.xy;
    updatePos();
  }

  void updateNormalWalk()
  {
    switch(dir)
    {
      case 0:
        relative_position_.x += speed_;
        if (relative_position_.x > initial_position_.x + movement_.x)
          dir = 1;
        break;
      case 1:
        relative_position_.y += speed_;
        if (relative_position_.y > initial_position_.y +  movement_.y)
          dir = 2;
        break;
      case 2:
        relative_position_.x -= speed_;
        if (relative_position_.x < initial_position_.x)
          dir = 3;
        break;
      case 3:
        relative_position_.y -= speed_;
        if (relative_position_.y < initial_position_.y)
        {
          dir = 0;
        }
        break;
    }
  }

  void update(GameState state)
  {
    EngineElement sheep_found;

    double min_distance = 100.0;

    if (sleep_time_ != 0)
    {
      sleep_time_ -= 1;
    }
    else
    {
      for(EngineElement e in state.elements_)
      {
        if (e.behaviour_ is SheepBehaviour || e.behaviour_ is FollowerBehaviour)
        {
          SceneElementBehaviour sheep = e.behaviour_;
          Vector2 diff = sheep.relative_position_ - relative_position_;
          double dist = calculateVectorLength(diff);
          if(dist < min_distance)
          {
            min_distance = dist;
            sheep_found = e;
          }
        }
      }

      if (sheep_found != null)
      {
        SceneElementBehaviour sheep_behaviour = sheep_found.behaviour_;
        Vector2 diff = relative_position_ - sheep_behaviour.relative_position_;
        if(calculateVectorLength(diff) < 0.05)
        {
          initial_run_position_ = relative_position_;
          chasing_sheep_ = sheep_behaviour;
          sheep_element_ = sheep_found;
        }
      }

      if (chasing_sheep_ != null)
      {
        Vector2 dir = chasing_sheep_.relative_position_ - relative_position_;
        double distance = calculateVectorLength(dir);
        dir.normalize();
        relative_position_ += dir * speed_;
        if(distance < 0.001)
        {
          if (chasing_sheep_ is FollowerBehaviour)
          {
            FollowerBehaviour current = chasing_sheep_;
            current.following_.followed_ = null;
          }
          SceneElementBehaviour behaviour =new DeadSheepBehaviour();
          sheep_element_.behaviour_ = behaviour;
          behaviour.drawable_ = sheep_element_.drawable_;
          chasing_sheep_ = null;
          sleep_time_ = 100;
        }
      }
      else
      {
        updateNormalWalk();
      }
      updatePos();
    }
  }
}