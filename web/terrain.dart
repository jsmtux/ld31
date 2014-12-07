library terrain;

import 'base_geometry.dart';

class Terrain
{
  List<List<int>> points_ = new List<List<int>>();
  int size_;
  void addQuad(int x, int y, int w, int h, int level)
  {
    for(int i=0; i < w; i++)
    {
      for(int j=0; j < h; j++)
      {
        points_[i+x][j+y] = level;
      }
    }
  }

  BaseGeometry calculateBaseGeometry()
  {
    ColoredGeometry ret = new ColoredGeometry(new List<double>(), new List<int>(), new List<double>());

    for (int i = 0; i < size_; i++)
    {
      for (int j = 0; j < size_; j++)
      {
        ret.vertices_.add(i/5);
        ret.vertices_.add(j/5);
        ret.vertices_.add(points_[i][j]/10);
        ret.colors_.add(points_[i][j]/6 - 0.1);
        ret.colors_.add(1 - (points_[i][j]/6));
        ret.colors_.add(0.0);
        ret.colors_.add(1.0);
      }
    }

    for (int i = 0; i < size_ - 1; i++)
    {
      for (int j = 0; j < size_ - 1; j++)
      {
        if(points_[i+1][j] == points_[i][j+1])
        {
          ret.indices_.add(i * size_ + j);
          ret.indices_.add((i + 1) * size_ + j);
          ret.indices_.add(i * size_ + j + 1);
          ret.indices_.add(i * size_ + j + 1);
          ret.indices_.add((i + 1) * size_ + j);
          ret.indices_.add((i + 1) * size_ + j + 1);
        }
        else if(points_[i][j] == points_[i+1][j+1])
        {
          ret.indices_.add(i * size_ + j);
          ret.indices_.add((i + 1) * size_ + j);
          ret.indices_.add((i + 1) * size_ + j + 1);
          ret.indices_.add(i * size_ + j);
          ret.indices_.add((i + 1) * size_ + j + 1);
          ret.indices_.add(i * size_ + j + 1);
        }
        else if(points_[i][j] == points_[i+1][j] || points_[i][j] == points_[i][j+1])
        {
          ret.indices_.add(i * size_ + j);
          ret.indices_.add((i + 1) * size_ + j);
          ret.indices_.add((i + 1) * size_ + j + 1);
          ret.indices_.add(i * size_ + j);
          ret.indices_.add((i + 1) * size_ + j + 1);
          ret.indices_.add(i * size_ + j + 1);
        }
        else
        {
          print('Invalid geometry, at least two points should match on each quad!!');
        }
      }
    }

    return ret;
  }

  Terrain(this.size_, this.points_)
  {
  }

  Terrain.empty(this.size_)
  {
    for(int i = 0; i < size_; i++)
    {
      points_.add(new List<int>());
      for (int j = 0; j < size_; j++)
      {
        points_[i].add(0);
      }
    }
  }
}