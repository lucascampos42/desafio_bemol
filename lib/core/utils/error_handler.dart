import 'package:flutter/material.dart';
import '../utils/toast_helper.dart';
import '../../ui/widgets/enhanced_error_widget.dart';

/// Classe responsável pelo tratamento centralizado de erros da aplicação
/// 
/// Esta classe fornece métodos estáticos para:
/// - Analisar tipos de exceções (rede, timeout, etc.)
/// - Exibir toasts de erro padronizados
/// - Tratar erros específicos de carregamento de dados
/// - Fornecer mensagens de erro amigáveis ao usuário
/// 
/// Utiliza [ToastHelper] para feedback visual e [AppLogger] para logs
class ErrorHandler {
  /// Analisa o tipo de exceção e retorna uma mensagem amigável ao usuário
  /// 
  /// Este método identifica diferentes tipos de erro:
  /// - Erros de conexão de rede
  /// - Timeouts de requisição
  /// - Erros de servidor (4xx, 5xx)
  /// - Erros de parsing de dados
  /// - Outros erros não categorizados
  /// 
  /// [error] - Exceção capturada para análise
  /// 
  /// Retorna informações estruturadas sobre o erro
  static ErrorInfo analyzeError(dynamic error) {
    String errorMessage;
    ErrorType errorType;
    
    final errorString = error.toString();
    
    if (errorString.contains('SocketException') || 
        errorString.contains('NetworkException')) {
      errorMessage = 'No internet connection';
      errorType = ErrorType.network;
    } else if (errorString.contains('TimeoutException')) {
      errorMessage = 'Request timeout';
      errorType = ErrorType.timeout;
    } else if (errorString.contains('500') || errorString.contains('502')) {
      errorMessage = 'Server temporarily unavailable';
      errorType = ErrorType.server;
    } else {
      errorMessage = 'Unexpected error';
      errorType = ErrorType.generic;
    }
    
    return ErrorInfo(message: errorMessage, type: errorType);
  }
  
  /// Exibe toast de erro padronizado e registra no log do sistema
  /// 
  /// Este método:
  /// - Analisa a exceção para gerar mensagem amigável
  /// - Exibe toast de erro se contexto estiver disponível
  /// - Registra erro detalhado no sistema de logs
  /// - Verifica se o contexto ainda está montado
  /// 
  /// [context] - Contexto para exibir toast (pode ser null)
  /// [errorInfo] - Informações do erro a ser tratado
  /// [customMessage] - Mensagem personalizada opcional
  static void showErrorToast(BuildContext? context, ErrorInfo errorInfo, {String? customMessage}) {
    if (context == null || !context.mounted) return;
    
    final message = customMessage ?? errorInfo.message;
    
    switch (errorInfo.type) {
      case ErrorType.network:
      case ErrorType.server:
      case ErrorType.generic:
      case ErrorType.storage:
        ToastHelper.showError(context, message);
      case ErrorType.timeout:
        ToastHelper.showWarning(context, message);
      case ErrorType.notFound:
        ToastHelper.showInfo(context, message);
    }
  }
  
  /// Trata erros de carregamento de produtos
  static ErrorInfo handleProductLoadError(dynamic error) {
    final errorInfo = analyzeError(error);
    return ErrorInfo(
      message: errorInfo.type == ErrorType.network 
        ? 'No internet connection'
        : 'Error loading products',
      type: errorInfo.type
    );
  }
  
  /// Trata erros de carregamento de categorias
  static ErrorInfo handleCategoryLoadError(dynamic error) {
    final errorInfo = analyzeError(error);
    return ErrorInfo(
      message: errorInfo.type == ErrorType.network 
        ? 'No connection to load categories'
        : 'Category filters unavailable',
      type: errorInfo.type
    );
  }
}

/// Informações sobre um erro processado
class ErrorInfo {
  final String message;
  final ErrorType type;
  
  const ErrorInfo({
    required this.message,
    required this.type,
  });
}