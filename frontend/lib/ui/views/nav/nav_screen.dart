import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:telegram_frontend/gen/assets.gen.dart';
import 'package:telegram_frontend/gen/fonts.gen.dart';
import 'package:telegram_frontend/ui/views/chat/chats.dart';

import 'package:telegram_frontend/ui/views/nav/cubit/nav_cubit.dart';
import 'package:telegram_frontend/ui/views/nav/widgets/bottom_navigation.dart';

class NavScreen extends StatefulWidget {
  const NavScreen({super.key});

  @override
  State<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  late final NavCubit _homeCubit;
  List<Widget> _screens = [];

  final ValueNotifier<int> _currentIndex = ValueNotifier(0);

  @override
  void initState() {
    super.initState();

    _homeCubit = context.read<NavCubit>();

    _screens = [
      BlocProvider(
        create: (context) => ChatsCubit(
          homeCubit: _homeCubit,
          chatRepository: context.read(),
          storyRepository: context.read(),
        )..initialize(),
        child: const ChatsScreen(),
      ),
      Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Assets.icons.icContacts.image(
                height: 64,
                color: const Color(0xFF838383),
              ),
              const SizedBox(height: 16),
              const Text(
                'Contacts',
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFF49454F),
                  fontFamily: FontFamily.roboto,
                ),
              ),
              const Text(
                'Coming soon...',
                style: TextStyle(
                  color: Color(0xFF838383),
                  fontFamily: FontFamily.roboto,
                ),
              ),
            ],
          ),
        ),
      ),
      Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Assets.icons.icSettings.image(
                height: 64,
                color: const Color(0xFF838383),
              ),
              const SizedBox(height: 16),
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFF49454F),
                  fontFamily: FontFamily.roboto,
                ),
              ),
              const Text(
                'Coming soon...',
                style: TextStyle(
                  color: Color(0xFF838383),
                  fontFamily: FontFamily.roboto,
                ),
              ),
            ],
          ),
        ),
      ),
      Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Assets.icons.icPremium.image(
                height: 64,
                color: const Color(0xFF838383),
              ),
              const SizedBox(height: 16),
              const Text(
                'Premium',
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFF49454F),
                  fontFamily: FontFamily.roboto,
                ),
              ),
              const Text(
                'Coming soon...',
                style: TextStyle(
                  color: Color(0xFF838383),
                  fontFamily: FontFamily.roboto,
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  @override
  void dispose() {
    _currentIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _currentIndex,
      builder: (context, index, _) {
        return Scaffold(
          body: IndexedStack(
            index: index,
            children: _screens,
          ),
          bottomNavigationBar: BottomNavigation(
            items: [
              BottomNavigationItem(
                label: 'Chats',
                iconPath: Assets.icons.icChatsEnable.path,
                disableIconPath: Assets.icons.icChats.path,
              ),
              BottomNavigationItem(
                label: 'Contacts',
                iconPath: Assets.icons.icContactsEnable.path,
                disableIconPath: Assets.icons.icContacts.path,
              ),
              BottomNavigationItem(
                label: 'Settings',
                iconPath: Assets.icons.icSettingsEnable.path,
                disableIconPath: Assets.icons.icSettings.path,
              ),
              BottomNavigationItem(
                label: 'Premium',
                iconPath: Assets.icons.icPremiumEnable.path,
                disableIconPath: Assets.icons.icPremium.path,
              ),
            ],
            currentIndex: index,
            onTap: (index) {
              _currentIndex.value = index;
            },
          ),
        );
      },
    );
  }
}
