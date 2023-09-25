import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobless/core/widgets/bottom_navy_bar.dart';
import 'package:jobless/presentation/bloc/hidenavbar/hidenavbar_cubit.dart';
import 'package:jobless/presentation/bloc/navigation/navigation_cubit.dart';
import 'package:jobless/presentation/bloc/user/user_cubit.dart';
import 'package:jobless/presentation/pages/applications/employee/application_page.dart';
import 'package:jobless/presentation/pages/applications/employers/application_page.dart';
import 'package:jobless/presentation/pages/chats/chats_page.dart';
import 'package:jobless/presentation/pages/home/home_page_employee.dart';
import 'package:jobless/presentation/pages/home/home_page_employers.dart';
import 'package:jobless/presentation/pages/profile/employee/profile_page.dart';
import 'package:jobless/presentation/pages/profile/employers/profile_page.dart';
import 'package:jobless/presentation/shared/named_nav_bar_item_widget.dart';

class NavbarPage extends StatefulWidget {
  const NavbarPage({super.key});

  @override
  State<NavbarPage> createState() => _NavbarPageState();
}

class _NavbarPageState extends State<NavbarPage> {
  String? status;

  @override
  void initState() {
    status = context.read<UserCubit>().user!.statusprofile!;
    context.read<NavigationCubit>().getNavBarItem(0);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final tabsEmployee = [
    NamedNavigationBarItemWidget(
      screen: const HomePage(),
      icon: const Icon(Icons.home),
      title: const Text('Home'),
      textAlign: TextAlign.center,
    ),
    NamedNavigationBarItemWidget(
      screen: const ApplicationPage(),
      icon: const Icon(Icons.apps),
      title: const Text('Apps'),
      textAlign: TextAlign.center,
    ),
    NamedNavigationBarItemWidget(
      screen: const ChatsPage(),
      icon: const Icon(Icons.message),
      title: const Text(
        'Messages',
      ),
      textAlign: TextAlign.center,
    ),
    NamedNavigationBarItemWidget(
      screen: const ProfileEmployeePage(),
      icon: const Icon(Icons.person),
      title: const Text('Profile'),
      textAlign: TextAlign.center,
    ),
  ];

  final tabsEmployers = [
    NamedNavigationBarItemWidget(
      screen: const HomeEmployersPage(),
      icon: const Icon(Icons.home),
      title: const Text('Home'),
      textAlign: TextAlign.center,
    ),
    NamedNavigationBarItemWidget(
      screen: const ApplicationEmployersPage(),
      icon: const Icon(Icons.apps),
      title: const Text('Vacancies'),
      textAlign: TextAlign.center,
    ),
    NamedNavigationBarItemWidget(
      screen: const ChatsPage(),
      icon: const Icon(Icons.message),
      title: const Text(
        'Messages',
      ),
      textAlign: TextAlign.center,
    ),
    NamedNavigationBarItemWidget(
      screen: const ProfileEmployersPage(),
      icon: const Icon(Icons.person),
      title: const Text('Profile'),
      textAlign: TextAlign.center,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (status == 'employee')
          ? tabsEmployee[
                  context.select((NavigationCubit nav) => nav.selectedPage)]
              .screen
          : tabsEmployers[
                  context.select((NavigationCubit nav) => nav.selectedPage)]
              .screen,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Align(
        alignment: const Alignment(1, 1.04),
        child: BlocBuilder<HideNavBarCubit, HideNavBarState>(
            builder: (context, stateVisible) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            height: stateVisible.isVisible ? 0.0 : 74.0,
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: BlocBuilder<NavigationCubit, NavigationState>(
                buildWhen: (previous, current) =>
                    previous.index != current.index,
                builder: (context, state) {
                  return BottomNavyBar(
                    selectedIndex: state.index,
                    showElevation: true,
                    itemCornerRadius: 16,
                    borderRadius: BorderRadius.circular(16.0),
                    curve: Curves.easeIn,
                    onItemSelected: (index) {
                      if (state.index != index) {
                        context.read<NavigationCubit>().getNavBarItem(index);
                      }
                    },
                    items:
                        (status == 'employee') ? tabsEmployee : tabsEmployers,
                  );
                }),
          );
        }),
      ),
    );
  }
}
