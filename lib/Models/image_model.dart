class ImageModel {
  final int id;
  final String imagePath;

  ImageModel({required this.id, required this.imagePath});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
    };
  }
}
