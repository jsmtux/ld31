library top_terrain;

import 'terrain.dart';

Terrain createTopTerrain()
{
  int size = 15;
  Terrain ret = new Terrain.empty(15);

  ret.addQuad(0,5,15,9,3);
  ret.addQuad(5,0,9,15,3);
  ret.addQuad(10, 11, 4, 3, 5);

  return ret;
}