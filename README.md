# 📱 Desafio Flutter – Lista de Produtos

Aplicativo desenvolvido em **Flutter** que consome a [Fake Store API](https://fakestoreapi.com/) e exibe produtos em uma lista, permitindo busca, favoritar itens e visualizar detalhes.

## 👨‍💻 Desenvolvedor
**Lucas Campos** - Desenvolvedor Full Stack experiente em Angular, NestJS, arquitetura MVC e Flutter (web, desktop, mobile).

🔗 **GitHub:** [lucascampos42](https://github.com/lucascampos42)

---

## 🚀 Funcionalidades
- Exibir lista de produtos com nome, preço, imagem, avaliação e favoritos.  
- Barra de busca em tempo real (case-insensitive).  
- Tela de detalhes com informações completas.  
- Tela de favoritos (persistidos em armazenamento local).  
- Uso de **ValueNotifier** para gerenciamento de estado.  
- Persistência com **Shared Preferences**.  
- Testes unitários e de widget.  

---

## 📂 Estrutura do Projeto
```
lib/
 ├── main.dart
 ├── core/
 │    ├── theme/
 │    └── utils/
 ├── data/
 │    ├── models/         # Product model
 │    ├── services/       # API (Dio)
 │    └── local/          # SharedPreferences
 ├── providers/           # ValueNotifier (estado)
 ├── ui/
 │    ├── screens/
 │    │     ├── home/
 │    │     ├── product_detail/
 │    │     └── favorites/
 │    └── widgets/        # Componentes reutilizáveis
 └── tests/
```

---

## 🛠️ Tecnologias Utilizadas
- [Flutter](https://flutter.dev/)  
- [Dio](https://pub.dev/packages/dio) – consumo de API  
- [Shared Preferences](https://pub.dev/packages/shared_preferences) – armazenamento local  
- [ValueNotifier](https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html) – gerenciamento de estado  
- [Fake Store API](https://fakestoreapi.com/docs)  

---

## 🎨 Design
- Baseado no protótipo do [Figma](https://www.figma.com/file/mNgC26HuTYGaiRvpPVZFkR/test?type=design).  
- Responsividade garantida em diferentes tamanhos de tela.  

---

## ⚡ Como Rodar
1. Clone o repositório:
   ```bash
   git clone https://github.com/lucascampos42/desafio_bemol.git
   cd desafio_bemol
   ```
2. Instale as dependências:
   ```bash
   flutter pub get
   ```
3. Rode o projeto:
   ```bash
   flutter run
   ```

---

## 🧪 Testes
Rodar testes unitários e de widget:
```bash
flutter test
```

---

## ✅ Critérios de Avaliação
- Funcionalidade completa conforme requisitos.  
- Código limpo e organizado.  
- Tratamento de erros.  
- Gerenciamento de estado com **ValueNotifier**.  
- Testes unitários e de widget.  
- Design fiel ao Figma.
