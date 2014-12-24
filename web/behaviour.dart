library behaviour;

import 'dart:html';
import 'dart:math';

import 'package:vector_math/vector_math.dart';
import 'package:game_loop/game_loop_html.dart';

import 'drawable.dart';
import 'element.dart';
import 'base_geometry.dart';
import 'game_state.dart';

abstract class Behaviour
{
  void init(EngineElement parent);
  void update(GameState state);
}

double calculateVectorLength(Vector2 vec)
{
  return vec.x * vec.x + vec.y * vec.y;
}

class TerrainBehaviour extends Behaviour
{
  Drawable drawable_;
  int num_coords_;
  BaseGeometry terrain_geometry;

  TerrainBehaviour(this.terrain_geometry);
  List<Vector2> obstacles_ = new List<Vector2>();

  void init(EngineElement parent)
  {
    drawable_ = parent.drawable_;
    num_coords_ = sqrt(terrain_geometry.vertices_.length/3)~/1;
  }
  void update(GameState state){}

  Vector2 fixPosition(Vector2 current, Vector2 end)
  {
    Vector2 ret = end;
    double obstacle_size = 0.01;

    for(Vector2 pos in obstacles_)
    {
      Vector2 diff = end - pos;
      if (calculateVectorLength(diff) < obstacle_size)
      {
         ret = current;
      }
    }
    return ret;
  }

  Vector3 getAbsolutePos(Vector2 current, Vector2 relative)
  {
    Vector3 ret;

    if (relative.x < 0 || relative.y < 0 || relative.x > 2.75 || relative.y > 2.75)
    {

    }
    else
    {
      ret = new Vector3(0.0, 0.0, 0.0);
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
  EngineElement parent_;
  Drawable drawable_;
  EngineElement terrain_;
  Vector2 relative_position_ = new Vector2(0.0,0.0);

  SceneElementBehaviour(this.terrain_);

  bool move(Vector2 to)
  {
    TerrainBehaviour terrain_behaviour = terrain_.behaviour_;
    Vector2 fixed = terrain_behaviour.fixPosition(relative_position_, to);
    setPos(fixed);
    return fixed == to;
  }
  bool setPos(Vector2 to)
  {
    bool ret = false;
    TerrainBehaviour terrain_behaviour = terrain_.behaviour_;
    Vector3 new_pos = terrain_behaviour.getAbsolutePos(relative_position_, to);
    if (new_pos != null)
    {
      relative_position_ = to.clone();
      drawable_.position_ = terrain_behaviour.getAbsolutePos(relative_position_, relative_position_);
      drawable_.position_.x -= 0.08;
      ret = true;
    }
    return ret;
  }

  void init(EngineElement parent)
  {
    parent_ = parent;
    drawable_ = parent.drawable_;
    move(new Vector2.zero());
    var cur_pos = drawable_.position_;
    drawable_.size = 0.07;
    Quaternion rot1 = new Quaternion(0.0, 0.0, 0.0, 1.0);
    rot1.setAxisAngle(new Vector3(1.0,0.0,0.0), radians(60.0));
    drawable_.rotation_ = rot1;
  }

  void update(GameState state){}

}

class ObstacleBehaviour extends SceneElementBehaviour
{
  Vector2 position_;
  ObstacleBehaviour(EngineElement terrain, this.position_)
      :super(terrain);

  void init(EngineElement parent)
  {
    super.init(parent);
    setPos(position_);
    drawable_.size = 0.10;
    TerrainBehaviour terrain_behaviour = terrain_.behaviour_;
    terrain_behaviour.obstacles_.add(position_ + new Vector2(0.06,0.05));
  }
}

class FollowableBehaviour extends SceneElementBehaviour
{
  FollowableBehaviour(EngineElement terrain) : super(terrain);
  FollowerBehaviour followed_;
}

class FollowerBehaviour extends FollowableBehaviour
{
  int sheep_level_;
  FollowerBehaviour(EngineElement terrain, this.following_, this.speed_, SceneElementBehaviour previous, this.sheep_level_)
  :super(terrain)
  {
    drawable_ = previous.drawable_;
    parent_ = previous.parent_;
    relative_position_ = previous.relative_position_;

    while(following_.followed_!=null)
    {
      following_ = following_.followed_;
    }
    following_.followed_ = this;
    followed_ = null;
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
        move(relative_position_ + diff.normalize() * speed_);
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

  void stopFollowing()
  {
    FollowerBehaviour cur_follower = this;
    cur_follower.following_.followed_ = null;
    while (cur_follower.followed_ != null && cur_follower.followed_.followed_ != null)
    {
      cur_follower = cur_follower.followed_;
      SheepBehaviour new_behaviour = new SheepBehaviour(terrain_, new Vector2.copy(cur_follower.relative_position_), cur_follower.sheep_level_);
      cur_follower.parent_.behaviour_ = new_behaviour;
      new_behaviour.drawable_ = cur_follower.drawable_;
      new_behaviour.initial_position_ = new Vector2.copy(cur_follower.relative_position_);
      new_behaviour.walk_initial_position_ = new Vector2.copy(cur_follower.relative_position_);
      new_behaviour.relative_position_ = new Vector2.copy(cur_follower.relative_position_);
      new_behaviour.wait_time_ = 300;
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
  int sheep_level_;
  Vector2 initial_position_;
  Vector2 walk_initial_position_ = new Vector2(0.0,0.0);
  Random rng = new Random();
  Vector2 random_position_;
  int wait_time_ = 0;
  SheepBehaviour(EngineElement terrain, Vector2 initial_position, this.sheep_level_)
  : super(terrain)
  {
    initial_position_ = initial_position / 5.0;
  }

  void init(EngineElement parent)
  {
    super.init(parent);
    wait_time_ = rng.nextInt(300);
    move(initial_position_);
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
        move(relative_position_ + diff);
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
  bool finished_ = false;

  int cool_level_ = 0;
  int num_followers_ = 0;
  int max_follower_ = 0;

  MainCharacterBehaviour(EngineElement terrain, this.keyboard_) : super(terrain)
  {
    querySelector("#coolbase").style.display = "";
  }

  ImageElement coolm1 = querySelector("#cool0");
  ImageElement coolm2 = querySelector("#cool1");
  ImageElement coolm3 = querySelector("#cool2");

  void updateCoolness()
  {
    if(cool_level_ > 0)
    {
      coolm1.style.display = "";
    }
    else
    {
      coolm1.style.display = "none";
    }
    if(cool_level_ > 1)
    {
      coolm2.style.display = "";
    }
    else
    {
      coolm2.style.display = "none";
    }
    if(cool_level_ > 2)
    {
      coolm3.style.display = "";
    }
    else
    {
      coolm3.style.display = "none";
    }
  }

  int updateHowCool()
  {
    FollowerBehaviour cur_follower = followed_;
    num_followers_ = 0;
    while(cur_follower != null)
    {
      num_followers_++;
      if(cur_follower.sheep_level_ > max_follower_)
      {
        max_follower_ = cur_follower.sheep_level_;
      }
      cur_follower = cur_follower.followed_;
    }
    if (num_followers_ > 1)
    {
      cool_level_ = 1;
    }
    if (max_follower_ == 2)
    {
      cool_level_ = 2;
    }
    if (max_follower_ == 3)
    {
      cool_level_ = 3;
    }
    return cool_level_;
  }

  void update(GameState state)
  {
    updateHowCool();
    updateCoolness();
    if (relative_position_.x >0.98 && relative_position_.x < 1.42 && relative_position_.y > 2.42 && relative_position_.y < 2.65)
    {
      if(!finished_)
      {
        if (num_followers_ == 0)
        {
          window.location.assign("#end1");
          finished_ = true;
        }
        else if (num_followers_ == 1)
        {
          window.location.assign("#end2");
          finished_ = true;
        }
        else if (max_follower_ == 1)
        {
          window.location.assign("#end3");
          finished_ = true;
        }
        else if (max_follower_ == 2)
        {
          window.location.assign("#end4");
          finished_ = true;
        }
        else if (max_follower_ == 3)
        {
          window.location.assign("#end5");
          finished_ = true;
        }
      }
    }
    else
    {
      finished_ = false;
    }
    if(keyboard_.isDown(Keyboard.UP))
    {
      move(relative_position_ + new Vector2(0.0, 0.005));
    }
    if(keyboard_.isDown(Keyboard.DOWN))
    {
      move(relative_position_ + new Vector2(0.0, -0.005));
    }
    if(keyboard_.isDown(Keyboard.LEFT))
    {
      move(relative_position_ + new Vector2(-0.005, 0.0));
    }
    if(keyboard_.isDown(Keyboard.RIGHT))
    {
      move(relative_position_ + new Vector2(0.005, 0.0));
    }
    if(keyboard_.isDown(Keyboard.SPACE))
    {
      if (space_key_released_)
      {
        print('position is $relative_position_');
        EngineElement sheep_found = getClosestSheep(state, relative_position_);
        if (sheep_found != null)
        {
          SheepBehaviour previous_behaviour = sheep_found.behaviour_;
          Vector2 diff = relative_position_ - previous_behaviour.relative_position_;
          if(calculateVectorLength(diff) < 0.1)
          {
            bool accepts = false;
            if (previous_behaviour.sheep_level_ == 1)
            {
              accepts = true;
            }
            if (previous_behaviour.sheep_level_ == 2)
            {
              if (followed_ != null && followed_.followed_ != null)
              {
                accepts = true;
              }
            }
            if (previous_behaviour.sheep_level_ == 3)
            {
              var followed = followed_;
              while(followed != null)
              {
                if (followed.sheep_level_ == 2)
                {
                  accepts = true;
                }
                followed = followed.followed_;
              }
            }
            if (accepts)
            {
              FollowerBehaviour sheep_behaviour = new FollowerBehaviour(terrain_ ,this, 0.005, sheep_found.behaviour_, previous_behaviour.sheep_level_);
              sheep_behaviour.parent_ = sheep_found;
              sheep_found.behaviour_ = sheep_behaviour;
            }
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
  int times_stop_ = 0;
  bool fix_movement = false;

  void init(EngineElement parent)
  {
    super.init(parent);
    move(initial_position_);
  }

  void updateNormalWalk()
  {
    bool moved;
    if (fix_movement)
    {
      times_stop_--;
      if(times_stop_ == 0)
      {
        fix_movement = false;
      }
      switch(dir)
      {
        case 0:
          moved = move(relative_position_ + new Vector2(-speed_, 0.0));
          if (!moved || times_stop_ < 10)
            dir = 1;
          break;
        case 1:
          moved = move(relative_position_ + new Vector2(0.0, -speed_));
          if (!moved || times_stop_ < 1)
            dir = 2;
          break;
        case 2:
          moved = move(relative_position_ + new Vector2(speed_, 0.0));
          if (!moved || times_stop_ < 1)
            dir = 3;
          break;
        case 3:
          moved = move(relative_position_ + new Vector2(0.0, speed_));
          if (!moved || times_stop_ < 1)
          {
            dir = 0;
          }
          break;
      }
    }
    else
    {
      switch(dir)
      {
        case 0:
          moved = move(relative_position_ + new Vector2(speed_, 0.0));
          if (relative_position_.x > initial_position_.x + movement_.x)
            dir = 1;
          break;
        case 1:
          moved = move(relative_position_ + new Vector2(0.0, speed_));
          if (relative_position_.y > initial_position_.y +  movement_.y)
            dir = 2;
          break;
        case 2:
          moved = move(relative_position_ + new Vector2(-speed_, 0.0));
          if (relative_position_.x < initial_position_.x)
            dir = 3;
          break;
        case 3:
          moved = move(relative_position_ + new Vector2(0.0, -speed_));
          if (relative_position_.y < initial_position_.y)
          {
            dir = 0;
          }
          break;
      }
      if(!moved)
      {
        times_stop_++;
      }
      if(times_stop_ > 5)
      {
        fix_movement = true;
        times_stop_ = 50;
      }
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
        move(relative_position_ + dir * speed_);
        if(distance < 0.001)
        {
          if (chasing_sheep_ is FollowerBehaviour)
          {
            FollowerBehaviour current = chasing_sheep_;
            current.stopFollowing();
          }
          SceneElementBehaviour behaviour =new DeadSheepBehaviour();
          sheep_element_.behaviour_ = behaviour;
          behaviour.drawable_ = sheep_element_.drawable_;
          behaviour.parent_ = sheep_element_;
          chasing_sheep_ = null;
          sleep_time_ = 100;
        }
      }
      else
      {
        updateNormalWalk();
      }
    }
  }
}