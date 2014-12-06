library Drawable;

import 'dart:web_gl' as webgl;

import 'package:vector_math/vector_math.dart';

import 'texture.dart';
import 'shader.dart';

class Drawable
{
  webgl.Buffer pos_buffer_;
  webgl.Buffer ind_buffer_;
  webgl.Buffer color_buffer_;
  webgl.Buffer tex_buffer_;

  Vector3 position_ = new Vector3(0.0,0.0,0.0);
  Quaternion rotation_ = new Quaternion(0.0,0.0,0.0,1.0);
  double size = 1.0;

  Shader shader_;

  Texture tex_;

  int vertices_;
}
