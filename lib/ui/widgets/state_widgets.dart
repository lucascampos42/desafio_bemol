import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/constants.dart';
import '../../core/utils/animations.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  
  const LoadingWidget({super.key, this.message});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppAnimations.fadeIn(
        child: AnimatedLoadingWidget(
          message: message,
          size: 40,
        ),
      ),
    );
  }
}

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final bool useErrorImage;
  
  const CustomErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
    this.useErrorImage = true,
  });
  
  bool get _isConnectionError {
    final lowerMessage = message.toLowerCase();
    return lowerMessage.contains('connection') || 
           lowerMessage.contains('network') ||
           lowerMessage.contains('internet') ||
           lowerMessage.contains('apiexception');
  }
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppAnimations.scaleIn(
              child: useErrorImage
                  ? Image.asset(
                      'assets/images/erro.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          _isConnectionError ? Icons.wifi_off : (icon ?? Icons.error_outline),
                          size: 64,
                          color: AppTheme.errorColor,
                        );
                      },
                    )
                  : Icon(
                      _isConnectionError ? Icons.wifi_off : (icon ?? Icons.error_outline),
                      size: 64,
                      color: AppTheme.errorColor,
                    ),
            ),
            // Exibe textos apenas se NÃO for um erro de conexão
            if (!_isConnectionError) ...[
              const SizedBox(height: AppConstants.defaultPadding),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppConstants.largePadding),
              AppAnimations.fadeSlideIn(
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyWidget extends StatelessWidget {
  final String message;
  final String? subtitle;
  final IconData? icon;
  final Widget? action;
  final bool useErrorImageOnly;
  
  const EmptyWidget({
    super.key,
    required this.message,
    this.subtitle,
    this.icon,
    this.action,
    this.useErrorImageOnly = false,
  });
  
  @override
  Widget build(BuildContext context) {
    // Se useErrorImageOnly for true, exibe apenas a imagem erro.png
    if (useErrorImageOnly) {
      return Center(
        child: Image.asset(
          'assets/images/erro.png',
          width: 120,
          height: 120,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              icon ?? Icons.inbox_outlined,
              size: 64,
              color: AppTheme.textHint,
            );
          },
        ),
      );
    }
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: AppAnimations.fadeSlideIn(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppAnimations.scaleIn(
                child: Icon(
                  icon ?? Icons.inbox_outlined,
                  size: 64,
                  color: AppTheme.textHint,
                ),
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Text(
                message,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            if (subtitle != null) ...[
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
              if (action != null) ...[
                const SizedBox(height: AppConstants.largePadding),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}



class NoSearchResultsWidget extends StatelessWidget {
  final String searchQuery;
  final VoidCallback? onClearSearch;
  
  const NoSearchResultsWidget({
    super.key,
    required this.searchQuery,
    this.onClearSearch,
  });
  
  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      message: 'No results found',
      subtitle: 'We couldn\'t find products for "$searchQuery"',
      icon: Icons.search_off,
      action: onClearSearch != null
          ? TextButton.icon(
              onPressed: onClearSearch,
              icon: const Icon(Icons.clear),
              label: const Text('Clear search'),
            )
          : null,
    );
  }
}
