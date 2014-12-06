library game_state;

import 'dart:html';

import 'package:game_loop/game_loop_html.dart';

import 'drawable_factory.dart';
import 'drawable.dart';
import 'renderer.dart';
import 'element.dart';
import 'base_geometry.dart';

class GameState extends SimpleHtmlState
{
  Renderer renderer_;
  List<EngineElement> elements_ = new List<EngineElement>();
  DrawableFactory drawable_factory_;

  EngineElement addElement(BaseGeometry geom)
  {
    Drawable drawable;
    if (geom is TexturedGeometry)
    {
      drawable = drawable_factory_.createTexturedDrawable(geom);
    }
    else if (geom is ColoredGeometry)
    {
      drawable = drawable_factory_.createColoredDrawable(geom);
    }
    EngineElement toAdd = new EngineElement(drawable);
    elements_.add(toAdd);
    renderer_.addDrawable(toAdd.drawable_);
    return toAdd;
  }

  void onRender(GameLoop gameLoop) {
    renderer_.render();
  }

  void onKeyDown(KeyboardEvent event) {
    event.preventDefault();

    print("Key event");
  }

  GameState(Renderer renderer)
  {
    renderer_ = renderer;
    drawable_factory_ = new DrawableFactory(renderer);
  }
}