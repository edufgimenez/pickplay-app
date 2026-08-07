# 💕 PickPlay - Sorteador de Entretenimento para Casais 🎬📺🎮🍽️

> **PickPlay** é um aplicativo mobile em **Flutter** feito sob medida para casais resolverem o clássico dilema: *"O que vamos assistir, jogar ou comer hoje?"* 

Com uma estética **Dark Romantic Neon**, o PickPlay transforma a escolha de filmes, séries, jogos, pratos e passeios em uma experiência divertida, cheia de suspense, sons e comemoração a dois!

---

## 🌟 A Ideia & Conceito

Chega de gastar 45 minutos tentando decidir o que assistir ou onde comer! Com o **PickPlay**, o casal cadastra suas opções desejadas no mês atual e deixa que a sorte decida por vocês com um **sorteio dramático em roleta 3D com efeitos sonoros**.

---

## ✨ Principais Funcionalidades

### 📅 1. Organização por Mês Ativo
- Navegue entre os meses do ano (**Agosto 2026**, **Setembro 2026**...).
- O aplicativo armazena as opções e os sorteios de cada mês de forma isolada para criar um histórico das atividades do casal.

### 🎬 2. Categorias Interativas com Ícones Inteligentes
- **Filmes** 🎬
- **Séries** 📺
- **Jogos** 🎮
- **Pratos** 🍽️
- **Categorias Personalizadas** ➕: Crie suas próprias categorias (ex: *Restaurantes*, *Pratos*, *Encontros*, *Passeios*, *Drinks*). O app reconhece automaticamente o tipo da palavra e atribui o ícone correspondente (ex: 🍽️ para Prato/Restaurante, 💖 para Encontro, ✈️ para Viagem).
- **Gerenciamento Simples**: Toque longo para excluir categorias customizadas.

### 🎭 3. O Grande Sorteio Dramático
- **Contagem Regressiva**: Contagem regressiva de 5 segundos com som de tick em tom crescente e mensagens divertidas de suspense.
- **Roleta 3D Vertical (Slot Machine)**: Giro contínuo em 3D com desaceleração física gradual e trilha sonora de roleta com efeito fadeout.
- **Explosão de Confetes & Áudio de Comemoração**: Revelação do vencedor acompanhada de confetes e música festiva.
- **Salvar ou Refazer**: Opção de salvar a escolha no Histórico do Mês ou sortear novamente.

### 📜 4. Histórico do Casal
- Registra a data, hora exata e categoria de cada sorteio realizado no mês.
- Permite consultar o histórico mensal isoladamente.

### 💖 5. Personalização dos Nomes do Casal
- Personalize como vocês desejam ser chamados no topo do aplicativo (ex: *"Ana & João"*, *"Amor da Minha Vida"* ou *"Meu Crush"*).

### 🔒 6. 100% Offline & Seguro
- Todos os dados (opções, histórico e nomes) são salvos nativamente no próprio celular via `SharedPreferences`.

---

## 🛠️ Tecnologias Utilizadas

- **[Flutter](https://flutter.dev/)** & **[Dart](https://dart.dev/)** (Framework Multiplataforma)
- **[Provider](https://pub.dev/packages/provider)** (Gerenciamento de Estado Reativo)
- **[AudioPlayers](https://pub.dev/packages/audioplayers)** (Sons da Contagem, Giro da Roleta e Comemoração)
- **[Shared Preferences](https://pub.dev/packages/shared_preferences)** (Persistência Local JSON)
- **[Flutter Animate](https://pub.dev/packages/flutter_animate)** (Animações Fluídas e Efeitos de Luz)
- **[Confetti](https://pub.dev/packages/confetti)** (Explosão Visual de Partículas)
- **[Google Fonts](https://pub.dev/packages/google_fonts)** (Tipografia Poppins & Fredoka)
- **[Intl](https://pub.dev/packages/intl)** (Internacionalização e Formatação em Português `pt_BR`)

---

## 🚀 Como Executar o Projeto

### Pré-requisitos
Ter o SDK do **Flutter** (versão 3.x ou superior) e o **Dart** instalados na máquina.

### 1. Clonar ou Acessar o Diretório do Projeto
```bash
cd pickplay-app
```

### 2. Instalar as Dependências
```bash
flutter pub get
```

### 3. Rodar o Aplicativo

- **No Celular Android / iOS ou Emulador (Recomendado)**:
  ```bash
  flutter run
  ```

- **No Navegador (Chrome / Edge)**:
  ```bash
  flutter run -d chrome
  ```

- **No Windows Desktop**:
  ```bash
  flutter run -d windows
  ```

---

<p align="center">
  Desenvolvido com ❤️ para momentos incríveis a dois!
</p>