import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/constants.dart';

/// Widget aprimorado para exibir diferentes tipos de erro com feedback visual adequado
class EnhancedErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final ErrorType errorType;
  final bool showImage;
  final String? customImagePath;

  const EnhancedErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.errorType = ErrorType.generic,
    this.showImage = true,
    this.customImagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showImage) _buildErrorImage(),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildErrorIcon(),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildErrorTitle(context),
            const SizedBox(height: AppConstants.smallPadding),
            _buildErrorMessage(context),
            if (onRetry != null) ...[
              const SizedBox(height: AppConstants.largePadding),
              _buildRetryButton(),
            ],
            const SizedBox(height: AppConstants.defaultPadding),
            _buildHelpText(context),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorImage() {
    String imagePath = customImagePath ?? _getImagePath();
    
    return Image.asset(
      imagePath,
      width: 120,
      height: 120,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorIcon();
      },
    );
  }

  Widget _buildErrorIcon() {
    IconData icon;
    Color color;
    
    switch (errorType) {
      case ErrorType.network:
        icon = Icons.wifi_off;
        color = AppTheme.errorColor;
        break;
      case ErrorType.server:
        icon = Icons.cloud_off;
        color = AppTheme.errorColor;
        break;
      case ErrorType.timeout:
        icon = Icons.access_time;
        color = AppTheme.warningColor;
        break;
      case ErrorType.notFound:
        icon = Icons.search_off;
        color = AppTheme.textSecondary;
        break;
      case ErrorType.storage:
        icon = Icons.storage;
        color = AppTheme.errorColor;
        break;
      case ErrorType.generic:
      default:
        icon = Icons.error_outline;
        color = AppTheme.errorColor;
        break;
    }
    
    return Icon(
      icon,
      size: 64,
      color: color,
    );
  }

  Widget _buildErrorTitle(BuildContext context) {
    String title = _getErrorTitle();
    
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        color: AppTheme.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildErrorMessage(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: AppTheme.textSecondary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildRetryButton() {
    return ElevatedButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh),
      label: Text(_getRetryButtonText()),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.largePadding,
          vertical: AppConstants.defaultPadding,
        ),
      ),
    );
  }

  Widget _buildHelpText(BuildContext context) {
    String helpText = _getHelpText();
    
    if (helpText.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.textHint.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Expanded(
            child: Text(
              helpText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getImagePath() {
    switch (errorType) {
      case ErrorType.network:
      case ErrorType.server:
      case ErrorType.timeout:
        return 'assets/images/erro.png';
      case ErrorType.notFound:
        return 'assets/images/empty.png';
      case ErrorType.storage:
      case ErrorType.generic:
      default:
        return 'assets/images/erro.png';
    }
  }

  String _getErrorTitle() {
    switch (errorType) {
      case ErrorType.network:
        return 'Sem conexão';
      case ErrorType.server:
        return 'Erro do servidor';
      case ErrorType.timeout:
        return 'Tempo esgotado';
      case ErrorType.notFound:
        return 'Nada encontrado';
      case ErrorType.storage:
        return 'Erro de armazenamento';
      case ErrorType.generic:
      default:
        return 'Ops! Algo deu errado';
    }
  }

  String _getRetryButtonText() {
    switch (errorType) {
      case ErrorType.network:
        return 'Verificar conexão';
      case ErrorType.server:
      case ErrorType.timeout:
        return 'Tentar novamente';
      case ErrorType.notFound:
        return 'Buscar novamente';
      case ErrorType.storage:
        return 'Recarregar';
      case ErrorType.generic:
      default:
        return 'Tentar novamente';
    }
  }

  String _getHelpText() {
    switch (errorType) {
      case ErrorType.network:
        return 'Verifique sua conexão com a internet e tente novamente.';
      case ErrorType.server:
        return 'Nossos servidores estão temporariamente indisponíveis.';
      case ErrorType.timeout:
        return 'A operação demorou mais que o esperado.';
      case ErrorType.storage:
        return 'Problema ao acessar o armazenamento do dispositivo.';
      case ErrorType.notFound:
      case ErrorType.generic:
      default:
        return '';
    }
  }
}

/// Tipos de erro para personalizar a exibição
enum ErrorType {
  network,
  server,
  timeout,
  notFound,
  storage,
  generic,
}