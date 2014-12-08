library top_terrain;

import 'terrain.dart';

Terrain createTopTerrain()
{
  int size = 15;
  Terrain ret = new Terrain.empty(15);

  ret.addQuad(0,5,15,10,2);
  ret.addQuad(5,0,10,15,2);
  ret.addQuad(0,6,15,9,3);
  ret.addQuad(7, 0, 2, 4, 3);
  ret.addQuad(12, 3, 3, 4, 3);
  ret.addQuad(12, 3, 3, 4, 3);
  ret.addQuad(4,9,11,6,4);
  ret.addQuad(6,9,2,2,3);
  ret.addQuad(4, 12, 4, 3, 5);

  return ret;
}