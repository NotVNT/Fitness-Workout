import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../common/colo_extension.dart';

class SmartFoodImage extends StatefulWidget {
  final String foodName;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? fallbackAsset;

  const SmartFoodImage({
    super.key,
    required this.foodName,
    this.width = 100,
    this.height = 100,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackAsset,
  });

  @override
  State<SmartFoodImage> createState() => _SmartFoodImageState();
}

class _SmartFoodImageState extends State<SmartFoodImage> {
  String? imageUrl;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      // Simple placeholder implementation - you can replace with actual image service
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          imageUrl = null; // Use placeholder icon instead
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        color: TColor.lightGray,
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        child: _buildImageContent(),
      ),
    );
  }

  Widget _buildImageContent() {
    if (isLoading) {
      return _buildLoadingWidget();
    }

    if (hasError || imageUrl == null) {
      return _buildErrorWidget();
    }

    // Kiểm tra nếu là URL placeholder hoặc network image
    if (imageUrl!.startsWith('http')) {
      return _buildNetworkImage();
    }

    // Fallback to asset image
    return _buildAssetImage();
  }

  Widget _buildNetworkImage() {
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholder: (context, url) => _buildLoadingWidget(),
      errorWidget: (context, url, error) => _buildErrorWidget(),
      fadeInDuration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildAssetImage() {
    return widget.fallbackAsset != null
        ? Image.asset(
            widget.fallbackAsset!,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
          )
        : _buildErrorWidget();
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TColor.lightGray,
            TColor.lightGray.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(TColor.primaryColor1),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TColor.primaryColor2.withOpacity(0.3),
            TColor.primaryColor1.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            color: TColor.primaryColor1,
            size: widget.width * 0.3,
          ),
          const SizedBox(height: 4),
          Text(
            widget.foodName.split(' ').first,
            style: TextStyle(
              color: TColor.primaryColor1,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Widget đơn giản hơn cho các trường hợp cần hiệu suất cao
class SimpleFoodImage extends StatelessWidget {
  final String foodName;
  final double size;
  final String? fallbackAsset;

  const SimpleFoodImage({
    super.key,
    required this.foodName,
    this.size = 60,
    this.fallbackAsset,
  });

  @override
  Widget build(BuildContext context) {
    // Tạo màu dựa trên tên món ăn
    final hash = foodName.hashCode.abs();
    final colors = [
      [TColor.primaryColor2, TColor.primaryColor1],
      [TColor.secondaryColor2, TColor.secondaryColor1],
      [const Color(0xFFFFB4B4), const Color(0xFFFF8A80)],
      [const Color(0xFFDDA0DD), const Color(0xFFBA68C8)],
      [const Color(0xFF98FB98), const Color(0xFF66BB6A)],
      [const Color(0xFFFFE4B5), const Color(0xFFFFCC02)],
    ];

    final colorPair = colors[hash % colors.length];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colorPair,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: [
          BoxShadow(
            color: colorPair[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getFoodIcon(foodName),
            color: Colors.white,
            size: size * 0.4,
          ),
          const SizedBox(height: 2),
          Text(
            _getShortName(foodName),
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  IconData _getFoodIcon(String foodName) {
    if (foodName.toLowerCase().contains('phở') ||
        foodName.toLowerCase().contains('bún')) {
      return Icons.ramen_dining;
    } else if (foodName.toLowerCase().contains('cơm')) {
      return Icons.rice_bowl;
    } else if (foodName.toLowerCase().contains('gỏi') ||
        foodName.toLowerCase().contains('salad')) {
      return Icons.eco;
    } else if (foodName.toLowerCase().contains('canh') ||
        foodName.toLowerCase().contains('soup')) {
      return Icons.soup_kitchen;
    } else if (foodName.toLowerCase().contains('sinh tố') ||
        foodName.toLowerCase().contains('smoothie')) {
      return Icons.local_drink;
    } else if (foodName.toLowerCase().contains('bánh')) {
      return Icons.bakery_dining;
    } else if (foodName.toLowerCase().contains('cháo')) {
      return Icons.breakfast_dining;
    } else if (foodName.toLowerCase().contains('chè')) {
      return Icons.icecream;
    }
    return Icons.restaurant;
  }

  String _getShortName(String foodName) {
    final words = foodName.split(' ');
    if (words.length >= 2) {
      return '${words[0]}\n${words[1]}';
    }
    return words[0];
  }
}
