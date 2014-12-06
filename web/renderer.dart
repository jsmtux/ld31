library Renderer;

import 'dart:html';
import 'dart:web_gl' as webgl;
import 'shader.dart';

import 'package:vector_math/vector_math.dart';

import 'drawable.dart';

class Renderer
{
  CanvasElement canvas_;
  webgl.RenderingContext gl_;
  webgl.Program shader_program_;

  int dimensions_ = 3;
  int view_width_;
  int view_height_;

  Matrix4 m_perspective_;
  Matrix4 m_modelview_;
  Matrix4 m_worldview_;

  Shader color_shader_;
  Shader texture_shader_;

  List<Drawable> drawables_ = new List<Drawable>();

  Renderer(CanvasElement canvas)
  {
    canvas_ = canvas;
    view_width_ = canvas.width;
    view_height_ = canvas.height;
    gl_ = canvas.getContext('experimental-webgl');
    color_shader_ = createColorShader(gl_);
    texture_shader_ = createTextureShader(gl_);

    m_worldview_ = new Matrix4.identity();

    gl_.clearColor(1.0, 0.0, 1.0, 1.0);
    gl_.enable(webgl.RenderingContext.DEPTH_TEST);
    gl_.blendFunc(webgl.RenderingContext.SRC_ALPHA, webgl.RenderingContext.ONE_MINUS_SRC_ALPHA);
    gl_.enable(webgl.RenderingContext.BLEND);
  }

  void addDrawable(Drawable drawable)
  {
    drawables_.add(drawable);
  }

  void render()
  {
    gl_.viewport(0, 0, view_width_, view_height_);
    gl_.clear(webgl.RenderingContext.COLOR_BUFFER_BIT | webgl.RenderingContext.DEPTH_BUFFER_BIT);

    m_perspective_ = makePerspectiveMatrix(radians(45.0), view_width_/view_height_, 0.1, 100.0);

    for (Drawable d in drawables_)
    {
      d.shader_.makeCurrent();
      m_modelview_ = new Matrix4.identity();
      m_modelview_.translate(d.position_);
      m_modelview_.setRotation(d.rotation_.asRotationMatrix());
      m_modelview_.scale(d.size, d.size, d.size);

      gl_.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, d.pos_buffer_);
      gl_.vertexAttribPointer(d.shader_.a_vertex_pos_, dimensions_, webgl.RenderingContext.FLOAT, false, 0, 0);
      if(d.color_buffer_ != null)
      {
        gl_.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, d.color_buffer_);
        gl_.vertexAttribPointer(d.shader_.a_vertex_color_, 4, webgl.RenderingContext.FLOAT, false, 0, 0);
      }
      if(d.tex_buffer_ != null)
      {
        d.tex_.makeCurrent();
        gl_.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, d.tex_buffer_);
        gl_.vertexAttribPointer(d.shader_.a_vertex_coord_, 2, webgl.RenderingContext.FLOAT, false, 0, 0);
      }

      gl_.bindBuffer(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, d.ind_buffer_);

      d.shader_.setMatrixUniforms(m_perspective_, m_modelview_, m_worldview_);
      gl_.drawElements(webgl.RenderingContext.TRIANGLES, d.vertices_, webgl.RenderingContext.UNSIGNED_SHORT, 0);
    }
  }
}