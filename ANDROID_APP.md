# Aplicativo Android — Barbearia do Meu Pai

Esta configuração empacota os arquivos web do repositório em um aplicativo Android com Capacitor. O site publicado na Vercel não é alterado.

## Requisitos

- Node.js LTS (20 ou mais recente)
- Android Studio atualizado
- Android SDK instalado pelo Android Studio

## Criar o projeto Android (primeira vez)

Na pasta do repositório, execute:

```bash
npm install
npm run android:init
npm run android:open
```

O script `build` copia os arquivos do site para `www/`. O Capacitor usa essa pasta como conteúdo local do app; não é uma simples janela apontando para o site da Vercel.

## Testar no celular/emulador

No Android Studio, aguarde a sincronização do Gradle, conecte um celular com Depuração USB ativada ou inicie um emulador e clique em Run.

Para atualizar o conteúdo web após alterações no site:

```bash
npm run android:sync
`

## Gerar arquivo para publicação

No Android Studio: **Build > Generate Signed Bundle / APK > Android App Bundle**. Crie e guarde a chave de assinatura (keystore) em local seguro; não a envie ao GitHub. Gere o arquivo **AAB** para enviar ao Google Play Console.

## Antes de publicar

- Testar agendamento, login de barbeiro/admin, navegação e links externos no Android.
- Criar ícone definitivo e imagens de divulgação.
- Confirmar política de privacidade e formulário de segurança de dados da Play Store.
- Configurar o nome, categoria, classificação etária e ficha do app no Play Console.
- A publicação exige conta Google Play Console e passa por revisão. Requisitos de teste para contas novas podem se aplicar.

Observação: Capacitor 7 usa a versão Android/SDK compatível definida pelo template instalado. Se o Android Studio pedir atualização do SDK ou Gradle, aceite as versões recomendadas pelo Capacitor e teste antes de publicar.
