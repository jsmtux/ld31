library texture_manager;

import 'dart:web_gl' as webgl;

import 'texture.dart';

class TextureManager
{
  Map<String, Texture> texture_list_ = new Map();
  webgl.RenderingContext gl_;

  TextureManager(this.gl_);

  Texture getTexture(String name)
  {
    texture_list_.putIfAbsent(name, () => new Texture(name, gl_));
    return texture_list_[name];
  }
}