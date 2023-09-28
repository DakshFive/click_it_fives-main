import 'package:flutter/material.dart';

typedef void RatingChangeCallback(double rating);

class StarRating extends StatelessWidget {
  final int starCount;
  final double rating;
  final RatingChangeCallback onRatingChanged;
  final Color color;
  final double size;

  StarRating(
      {this.starCount = 5,
        this.rating = .0,
        required this.onRatingChanged,
        required this.color,
        required this.size});

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= rating) {
      icon = Icon(
        Icons.star_border_rounded,
        color:Colors.grey,
        size: size,
      );
    } else if (index > rating - 1 && index < rating) {
      icon = Icon(
        Icons.star_half_rounded,
        color: color,
        size: size,
      );
    } else {
      icon = Icon(
        Icons.star_rounded,
        color: color,
        size: size,
      );
    }
    return InkResponse(
      onTap:
      onRatingChanged == null ? null : () => onRatingChanged(index + 1.0),
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        children:
        List.generate(starCount, (index) => buildStar(context, index)));
  }
}
