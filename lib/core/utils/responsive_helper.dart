import 'package:flutter/material.dart';

/// Helper class para gerenciar layouts responsivos
/// Fornece breakpoints e utilitários para diferentes tamanhos de tela
class ResponsiveHelper {
  // Breakpoints para diferentes dispositivos
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1600;

  /// Verifica se é um dispositivo móvel
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Verifica se é um tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Verifica se é desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  /// Verifica se é desktop grande
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= largeDesktopBreakpoint;
  }

  /// Retorna o número de colunas baseado no tamanho da tela
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= largeDesktopBreakpoint) return 4;
    if (width >= desktopBreakpoint) return 3;
    if (width >= tabletBreakpoint) return 2;
    return 1;
  }

  /// Retorna padding responsivo
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  }

  /// Retorna largura máxima do conteúdo para desktop
  static double getMaxContentWidth(BuildContext context) {
    if (isLargeDesktop(context)) return 1400;
    if (isDesktop(context)) return 1200;
    return double.infinity;
  }

  /// Retorna espaçamento entre itens baseado no tamanho da tela
  static double getItemSpacing(BuildContext context) {
    if (isDesktop(context)) return 24;
    if (isTablet(context)) return 16;
    return 12;
  }

  /// Widget responsivo que adapta baseado no tamanho da tela
  static Widget responsive({
    required BuildContext context,
    Widget? mobile,
    Widget? tablet,
    Widget? desktop,
    Widget? largeDesktop,
  }) {
    if (isLargeDesktop(context) && largeDesktop != null) {
      return largeDesktop;
    }
    if (isDesktop(context) && desktop != null) {
      return desktop;
    }
    if (isTablet(context) && tablet != null) {
      return tablet;
    }
    return mobile ?? const SizedBox.shrink();
  }

  /// Retorna valor responsivo baseado no tamanho da tela
  static T responsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    if (isLargeDesktop(context) && largeDesktop != null) {
      return largeDesktop;
    }
    if (isDesktop(context) && desktop != null) {
      return desktop;
    }
    if (isTablet(context) && tablet != null) {
      return tablet;
    }
    return mobile;
  }
}

/// Widget que centraliza conteúdo com largura máxima em desktop
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool centerContent;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveHelper.getMaxContentWidth(context);
    final responsivePadding = padding ?? ResponsiveHelper.getResponsivePadding(context);

    Widget content = Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: responsivePadding,
      child: child,
    );

    if (centerContent && ResponsiveHelper.isDesktop(context)) {
      return Center(child: content);
    }

    return content;
  }
}

/// Layout responsivo para listas de produtos
class ResponsiveProductLayout extends StatelessWidget {
  final List<Widget> children;
  final ScrollController? scrollController;
  final EdgeInsets? padding;

  const ResponsiveProductLayout({
    super.key,
    required this.children,
    this.scrollController,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // Em mobile, usa ListView tradicional
    if (ResponsiveHelper.isMobile(context)) {
      return ListView(
        controller: scrollController,
        padding: padding,
        children: children,
      );
    }

    // Em tablet/desktop, usa GridView para melhor aproveitamento do espaço
    final columns = ResponsiveHelper.getGridColumns(context);
    final spacing = ResponsiveHelper.getItemSpacing(context);

    return ResponsiveContainer(
      padding: padding,
      child: GridView.builder(
        controller: scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: ResponsiveHelper.responsiveValue(
            context: context,
            mobile: 1.0,
            tablet: 0.8,
            desktop: 0.75,
          ),
        ),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      ),
    );
  }
}