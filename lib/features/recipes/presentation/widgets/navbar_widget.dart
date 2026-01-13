import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class NavbarWidget extends StatelessWidget {
  final Widget child;
  final String currentPath;

  const NavbarWidget({
    super.key,
    required this.child,
    required this.currentPath,
  });

  int _getCurrentIndex() {
    if (currentPath == '/') return 0;
    if (currentPath == '/random') return 1;
    if (currentPath == '/favourites') return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _getCurrentIndex(),
          onTap: (index) {
            switch (index) {
              case 0:
                context.go('/');
                break;
              case 1:
                context.go('/random');
                break;
              case 2:
                context.go('/favourites');
                break;
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF2E7D32),
          unselectedItemColor: Colors.grey[600],
          selectedFontSize: 12.sp,
          unselectedFontSize: 12.sp,
          elevation: 0,
          backgroundColor: Colors.white,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 24.sp),
              activeIcon: Icon(Icons.home_rounded, size: 24.sp),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shuffle_outlined, size: 24.sp),
              activeIcon: Icon(Icons.shuffle_rounded, size: 24.sp),
              label: 'Random',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline, size: 24.sp),
              activeIcon: Icon(Icons.favorite_rounded, size: 24.sp),
              label: 'Favourites',
            ),
          ],
        ),
      ),
    );
  }
}
