library texture;
import 'dart:html';

import 'dart:web_gl' as webgl;

class Texture
{
  String path;
  webgl.RenderingContext gl_;
  webgl.Texture texture_;
  bool loaded_ = false;

  Texture(String image_name, this.gl_)
  {
    texture_ = gl_.createTexture();
    ImageElement image = new Element.tag('img');
    image.onLoad.listen((e) {
      _handleLoadedTexture(texture_, image);
      loaded_ = true;
    });
    image.src = image_name;
  }

  void _handleLoadedTexture(webgl.Texture texture, ImageElement img) {
    gl_.bindTexture(webgl.RenderingContext.TEXTURE_2D, texture);
    gl_.pixelStorei(webgl.RenderingContext.UNPACK_FLIP_Y_WEBGL, 1); // second argument must be an int
    gl_.texImage2DImage(webgl.RenderingContext.TEXTURE_2D, 0, webgl.RenderingContext.RGBA, webgl.RenderingContext.RGBA, webgl.RenderingContext.UNSIGNED_BYTE, img);
    gl_.texParameteri(webgl.RenderingContext.TEXTURE_2D, webgl.RenderingContext.TEXTURE_MAG_FILTER, webgl.RenderingContext.NEAREST);
    gl_.texParameteri(webgl.RenderingContext.TEXTURE_2D, webgl.RenderingContext.TEXTURE_MIN_FILTER, webgl.RenderingContext.NEAREST);
    gl_.bindTexture(webgl.RenderingContext.TEXTURE_2D, null);
  }

  void makeCurrent()
  {
    if (loaded_)
    {
      gl_.bindTexture(webgl.RenderingContext.TEXTURE_2D, texture_);
    }
  }
}