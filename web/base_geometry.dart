library base_geometry;

class BaseGeometry
{

  List<double> vertices_;
  List<int> indices_;

  BaseGeometry(this.vertices_, this.indices_);
}

class ColoredGeometry extends BaseGeometry
{
  List<double> colors_;

  ColoredGeometry(List<double> vertices, List<int> indices, this.colors_)
      : super(vertices, indices)
  {}

}

class TexturedGeometry extends BaseGeometry
{
  List<double> text_coords_;
  String image_;

  TexturedGeometry(List<double> vertices, List<int> indices, this.text_coords_, this.image_)
    : super(vertices, indices)
  {
  }
}