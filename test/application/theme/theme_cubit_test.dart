import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matbakhy/application/theme/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeCubit', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    group('initial state', () {
      test('emits ThemeMode.system when no preference exists', () async {
        SharedPreferences.setMockInitialValues({});

        final cubit = ThemeCubit();
        // Wait for _load() to complete
        await Future.delayed(const Duration(milliseconds: 50));

        expect(cubit.state, ThemeMode.system);
        await cubit.close();
      });
    });

    group('setThemeMode', () {
      test('emits light when set to light', () async {
        SharedPreferences.setMockInitialValues({});

        final cubit = ThemeCubit();
        await Future.delayed(const Duration(milliseconds: 50));

        await cubit.setThemeMode(ThemeMode.light);

        expect(cubit.state, ThemeMode.light);
        await cubit.close();
      });

      test('emits dark when set to dark', () async {
        SharedPreferences.setMockInitialValues({});

        final cubit = ThemeCubit();
        await Future.delayed(const Duration(milliseconds: 50));

        await cubit.setThemeMode(ThemeMode.dark);

        expect(cubit.state, ThemeMode.dark);
        await cubit.close();
      });

      test('persists mode to SharedPreferences', () async {
        SharedPreferences.setMockInitialValues({});

        final cubit = ThemeCubit();
        await Future.delayed(const Duration(milliseconds: 50));

        await cubit.setThemeMode(ThemeMode.dark);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('theme_mode'), 'dark');
        await cubit.close();
      });
    });

    group('loading saved preference', () {
      test('loads dark mode from preferences', () async {
        SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});

        final cubit = ThemeCubit();
        await Future.delayed(const Duration(milliseconds: 50));

        expect(cubit.state, ThemeMode.dark);
        await cubit.close();
      });

      test('loads light mode from preferences', () async {
        SharedPreferences.setMockInitialValues({'theme_mode': 'light'});

        final cubit = ThemeCubit();
        await Future.delayed(const Duration(milliseconds: 50));

        expect(cubit.state, ThemeMode.light);
        await cubit.close();
      });
    });
  });
}
