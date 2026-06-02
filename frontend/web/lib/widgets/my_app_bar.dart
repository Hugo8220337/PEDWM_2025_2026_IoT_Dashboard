import 'package:common/models/sensor_info.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/pages/initial_screen/widgets/add_sensor_dialog/add_sensor_screen.dart';

class MyAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;

  final Function(List<SensorInfo>)? onSensorsAdded;
  final List<SensorInfo> activeSensors;

  const MyAppBar({
    super.key,
    required this.title,
    this.onSensorsAdded,
    this.activeSensors = const [],
  });

  @override
  Widget build(BuildContext context) {
    var foregroundColor = Theme.of(
      context,
    ).appBarTheme.foregroundColor;

    var backgroundColor = Theme.of(
      context,
    ).appBarTheme.backgroundColor;

    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Side: Brand/Title
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),

            // Right Side: Icons & Profile
            Row(
              children: [
                _ToggleThemeButton(),

                const SizedBox(width: 10),

                IconButton(
                  onPressed: () async {
                    final List<SensorInfo>? selectedSensors =
                        await showDialog<List<SensorInfo>>(
                          context: context,
                          builder: (context) {
                            return AddSensorScreen(
                              initialSelectedSensors: activeSensors,
                            );
                          },
                        );

                    if (selectedSensors != null &&
                        onSensorsAdded != null) {
                      onSensorsAdded!(selectedSensors);
                    }
                  },
                  tooltip: "Add Sensor",
                  icon: Icon(Icons.add, color: foregroundColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Required by the PreferredSizeWidget
  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class _ToggleThemeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeNotifier,
      builder: (_, ThemeMode currentMode, _) {
        final isDark =
            currentMode == ThemeMode.dark ||
            (currentMode == ThemeMode.system &&
                MediaQuery.of(context).platformBrightness ==
                    Brightness.dark);

        return IconButton(
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          tooltip: 'change_theme'.tr(context: context),
          onPressed: () {
            AppTheme.themeNotifier.value = isDark
                ? ThemeMode.light
                : ThemeMode.dark;
          },
        );
      },
    );
  }
}
