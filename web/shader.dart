library Shader;

import 'dart:web_gl' as webgl;
import 'dart:typed_data';

import 'package:vector_math/vector_math.dart';

class Shader
{
  webgl.Program shader_program_;
  int a_vertex_pos_;
  int a_vertex_color_;
  int a_vertex_coord_;
  webgl.UniformLocation u_m_perspective_;
  webgl.UniformLocation u_m_modelview_;

  webgl.RenderingContext gl_;

  Shader (String vertex_source, String fragment_source, webgl.RenderingContext gl)
  {
    gl_ =  gl;
    webgl.Shader vs = gl.createShader(webgl.RenderingContext.VERTEX_SHADER);
    gl.shaderSource(vs, vertex_source);
    gl.compileShader(vs);

    webgl.Shader fs = gl.createShader(webgl.RenderingContext.FRAGMENT_SHADER);
    gl.shaderSource(fs, fragment_source);
    gl.compileShader(fs);

    shader_program_ = gl.createProgram();
    gl.attachShader(shader_program_, vs);
    gl.attachShader(shader_program_, fs);
    gl.linkProgram(shader_program_);
    gl.useProgram(shader_program_);

    if (!gl.getShaderParameter(vs, webgl.RenderingContext.COMPILE_STATUS)) {
      print(gl.getShaderInfoLog(vs));
    }

    if (!gl.getShaderParameter(fs, webgl.RenderingContext.COMPILE_STATUS)) {
      print(gl.getShaderInfoLog(fs));
    }

    if (!gl.getProgramParameter(shader_program_, webgl.RenderingContext.LINK_STATUS)) {
      print(gl.getProgramInfoLog(shader_program_));
    }

    a_vertex_pos_ = gl.getAttribLocation(shader_program_, "aVertexPosition");
    gl.enableVertexAttribArray(a_vertex_pos_);

    a_vertex_color_ = gl.getAttribLocation(shader_program_, "aVertexColor");
    if (a_vertex_color_ >= 0)
    {
      gl.enableVertexAttribArray(a_vertex_color_);
    }

    a_vertex_coord_ = gl.getAttribLocation(shader_program_, "aTextureCoord");
    if (a_vertex_coord_ >= 0)
    {
      gl.enableVertexAttribArray(a_vertex_coord_);
    }

    u_m_perspective_ = gl.getUniformLocation(shader_program_, "uPMatrix");
    u_m_modelview_ = gl.getUniformLocation(shader_program_, "uMVMatrix");
  }

  void setMatrixUniforms(Matrix4 m_perspective_, Matrix4 m_modelview_)
  {
    Float32List tmpList = new Float32List(16);
    m_perspective_.copyIntoArray(tmpList);
    gl_.uniformMatrix4fv(u_m_perspective_, false, tmpList);

    m_modelview_.copyIntoArray(tmpList);
    gl_.uniformMatrix4fv(u_m_modelview_, false, tmpList);
  }

  void makeCurrent()
  {
    gl_.useProgram(shader_program_);
  }

}

String color_vs_source = """
attribute vec3 aVertexPosition;
attribute vec4 aVertexColor;

uniform mat4 uMVMatrix;
uniform mat4 uPMatrix;

varying vec4 vColor;

void main(void) {
  gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
  vColor = aVertexColor;
}
""";

String color_fs_source = """
precision mediump float;
varying vec4 vColor;
void main(void) {
  gl_FragColor = vColor;
}
    """;

Shader createColorShader(webgl.RenderingContext gl) => new Shader(color_vs_source, color_fs_source, gl);

String texture_vs_source = """
attribute vec3 aVertexPosition;
attribute vec2 aTextureCoord;

uniform mat4 uMVMatrix;
uniform mat4 uPMatrix;

varying vec2 vTextureCoord;

void main(void) {
  gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
  vTextureCoord = aTextureCoord;
}
""";

String texture_fs_source = """
precision mediump float;
varying vec2 vTextureCoord;
uniform sampler2D uSampler;
void main(void) {
  gl_FragColor = texture2D(uSampler, vec2(vTextureCoord.s, vTextureCoord.t));
}
""";

Shader createTextureShader(webgl.RenderingContext gl) => new Shader(texture_vs_source, texture_fs_source, gl);