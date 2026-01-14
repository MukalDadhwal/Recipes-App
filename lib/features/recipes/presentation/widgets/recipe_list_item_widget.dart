import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecipeListItemWidget extends StatelessWidget {
  final String id;
  final String name;
  final String imageUrl;
  final String? category;
  final String? area;
  final VoidCallback onTap;

  const RecipeListItemWidget({
    super.key,
    required this.id,
    required this.name,
    required this.imageUrl,
    this.category,
    this.area,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                Hero(
                  tag: 'meal_$id',
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14.r),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 95.w,
                        height: 95.h,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 95.w,
                          height: 95.h,
                          color: Colors.grey[100],
                          child: Icon(
                            Icons.restaurant,
                            color: Colors.grey[300],
                            size: 32.sp,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 95.w,
                          height: 95.h,
                          color: Colors.grey[100],
                          child: Icon(
                            Icons.restaurant,
                            color: Colors.grey[300],
                            size: 32.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (category != null || area != null) ...[
                        SizedBox(height: 6.h),
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 4.h,
                          children: [
                            if (category != null)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  category!,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF129575),
                                  ),
                                ),
                              ),
                            if (area != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.place_outlined,
                                    size: 15.sp,
                                    color: const Color(0xFF129575),
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    area!,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16.sp,
                  color: Colors.grey[350],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
