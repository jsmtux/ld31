library geometry_data;

List<double> triangle_vertices = [
   0.0,  1.0,  0.0,
  -1.0, -1.0,  0.0,
   1.0, -1.0,  0.0
];
List<int> triangle_indices = [0, 1, 2];

List<double> quad_vertices = [
                0.0, 0.0,  0.0,
                0.0,  2.0,  0.0,
                2.0, 0.0,  0.0,
                2.0,  2.0,  0.0
           ];
List<double> quad_coords = [
  0.0, 0.0,
  0.0, 1.0,
  1.0, 0.0,
  1.0, 1.0
];
List<int> quad_indices = [0, 3, 1, 0, 2, 3];