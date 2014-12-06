library drawable_factory;

import 'dart:web_gl' as webgl;
import 'dart:typed_data';

import 'drawable.dart';
import 'renderer.dart';
import 'base_geometry.dart';
import 'texture.dart';
import 'texture_manager.dart';

class DrawableFactory
{
  Renderer renderer_;
  TextureManager texture_manager_;

  Drawable createBaseDrawable(BaseGeometry geometry)
  {
    Drawable ret = new Drawable();
    ret.pos_buffer_ = renderer_.gl_.createBuffer();
    renderer_.gl_.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, ret.pos_buffer_);

    renderer_.gl_.bufferDataTyped(webgl.RenderingContext.ARRAY_BUFFER,
        new Float32List.fromList(geometry.vertices_), webgl.RenderingContext.STATIC_DRAW);

    ret.vertices_ = geometry.vertices_.length~/3;

    return ret;
  }

  Drawable createColoredDrawable(ColoredGeometry geometry)
  {
    Drawable ret = createBaseDrawable(geometry);

    ret.color_buffer_ = renderer_.gl_.createBuffer();
    renderer_.gl_.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, ret.color_buffer_);

    renderer_.gl_.bufferDataTyped(webgl.RenderingContext.ARRAY_BUFFER, new Float32List.fromList(geometry.colors_),
      webgl.RenderingContext.STATIC_DRAW);

    ret.shader_ = renderer_.color_shader_;

    return ret;
  }

  Drawable createTexturedDrawable(TexturedGeometry geometry)
  {
    Drawable ret = createBaseDrawable(geometry);

    ret.tex_buffer_ = renderer_.gl_.createBuffer();
    renderer_.gl_.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, ret.tex_buffer_);

    renderer_.gl_.bufferDataTyped(webgl.RenderingContext.ARRAY_BUFFER,
        new Float32List.fromList(geometry.text_coords_), webgl.RenderingContext.STATIC_DRAW);

    ret.tex_ = texture_manager_.getTexture(geometry.image_);

    ret.shader_ = renderer_.texture_shader_;

    return ret;
  }

  DrawableFactory(this.renderer_)
  {
    texture_manager_ = new TextureManager(renderer_.gl_);
  }
}