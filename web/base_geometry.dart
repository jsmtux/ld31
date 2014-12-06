library base_geometry;

class BaseGeometry
{

  List<double> vertices_;

  BaseGeometry(this.vertices_);
}

class ColoredGeometry extends BaseGeometry
{
  List<double> colors_;

  ColoredGeometry(List<double> vertices, this.colors_)
      : super(vertices)
  {}

}

class TexturedGeometry extends BaseGeometry
{
  List<double> text_coords_;
  String image_;

  TexturedGeometry(List<double> vertices, this.text_coords_, this.image_)
    : super(vertices)
  {
  }
}