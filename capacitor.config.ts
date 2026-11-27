import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'br.com.barbeariadomeupai',
  appName: 'Barbearia do Meu Pai',
  webDir: 'www',
  bundledWebRuntime: false,
  android: {
    backgroundColor: '#f7f7f5',
    allowMixedContent: false
  }
};

export default config;
