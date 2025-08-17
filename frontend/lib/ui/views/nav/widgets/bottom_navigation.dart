import 'package:flutter/material.dart';
import 'package:telegram_frontend/gen/fonts.gen.dart';
import 'package:telegram_frontend/ui/core/themes/colors.dart';

class BottomNavigationItem {
  BottomNavigationItem({
    required this.label,
    required this.iconPath,
    required this.disableIconPath,
    this.badge = 0,
  });

  final String label;
  final String iconPath;
  final String disableIconPath;
  final int badge;
}

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final List<BottomNavigationItem> items;
  final int currentIndex;
  final void Function(int index) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        border: Border(
          top: BorderSide(color: Color(0xFFEDEDED)),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final itemWidth = width / items.length;

          return SafeArea(
            top: false,
            child: Stack(
              children: [
                // Indicator
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeInOut,
                  left: (currentIndex + 0.5) * itemWidth - 20,
                  top: 12,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4F4FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const SizedBox(width: 40, height: 32),
                  ),
                ),

                Row(
                  children: items.map((item) {
                    final index = items.indexOf(item);
                    final isSelected = index == currentIndex;

                    final textColor = isSelected
                        ? AppColors.telegramBlue
                        : const Color(0xFF49454F);
                    final iconPath =
                        isSelected ? item.iconPath : item.disableIconPath;
                    final textWeight =
                        isSelected ? FontWeight.w500 : FontWeight.w400;

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 16),
                        child: InkWell(
                          onTap: () => onTap(index),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    child: Image.asset(
                                      iconPath,
                                      height: 24,
                                      width: 24,
                                    ),
                                  ),
                                  if (item.badge > 0) _buildBadge(item.badge),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 12,
                                  fontFamily: FontFamily.roboto,
                                  fontWeight: textWeight,
                                  height: 1,
                                  letterSpacing: 0.50,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBadge(int badge) {
    return Positioned(
      top: -4,
      right: -4,
      child: Container(
        width: 16,
        height: 16,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFFE14D4D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: Center(
          child: Text(
            badge.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontFamily: FontFamily.roboto,
              fontWeight: FontWeight.w500,
              height: 1.45,
              letterSpacing: 0.50,
            ),
          ),
        ),
      ),
    );
  }
}
