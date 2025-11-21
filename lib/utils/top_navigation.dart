import 'package:flutter/material.dart';
import '../utils/theme.dart';

class TopNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const TopNavigation({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              // Logo/Brand
              Text(
                'SOAR',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: AppTheme.textPrimaryColor,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 48),
              
              // Navigation items
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildNavItem('home', 0, context),
                      const SizedBox(width: 32),
                      _buildNavItem('explore', 1, context),
                      const SizedBox(width: 32),
                      _buildNavItem('podcast', 2, context),
                      const SizedBox(width: 32),
                      _buildNavItem('community', 3, context),
                    ],
                  ),
                ),
              ),
              
              // Profile icon
              IconButton(
                icon: Icon(
                  Icons.person_outline,
                  color: AppTheme.textPrimaryColor,
                  size: 22,
                ),
                onPressed: () => onItemSelected(4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String label, int index, BuildContext context) {
    final isSelected = currentIndex == index;
    
    return GestureDetector(
      onTap: () => onItemSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          border: isSelected
              ? Border(
                  bottom: BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                )
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            color: isSelected
                ? AppTheme.textPrimaryColor
                : AppTheme.textSecondaryColor,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

