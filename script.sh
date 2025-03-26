#!/bin/bash

# Create project directory structure
mkdir -p src/assets
mkdir -p src/components/layout
mkdir -p src/components/web3
mkdir -p src/layouts
mkdir -p src/pages
mkdir -p src/stores
mkdir -p src/utils

# Create package.json
cat > package.json << EOL
{
  "name": "my-web3-app",
  "private": true,
  "version": "0.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "@mdi/font": "^7.2.96",
    "@mdi/js": "^7.2.96",
    "@vueuse/core": "^10.1.2",
    "ethers": "^5.7.2",
    "pinia": "^2.1.3",
    "vue": "^3.3.4",
    "vue-router": "^4.2.2",
    "vuetify": "^3.3.5"
  },
  "devDependencies": {
    "@vitejs/plugin-vue": "^4.2.3",
    "vite": "^4.3.9",
    "vite-plugin-vuetify": "^1.0.2"
  }
}
EOL

# Vite Configuration
cat > vite.config.js << EOL
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import vuetify from 'vite-plugin-vuetify'

export default defineConfig({
  plugins: [
    vue(),
    vuetify({ autoImport: true })
  ],
  resolve: {
    alias: {
      '@': '/src'
    }
  }
})
EOL

# Main.js
cat > src/main.js << EOL
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'
import 'vuetify/styles/main.css'
import '@mdi/font/css/materialdesignicons.css'

import App from './App.vue'
import router from './router'

const vuetify = createVuetify({
  components,
  directives,
  icons: {
    defaultSet: 'mdi'
  }
})

const app = createApp(App)
const pinia = createPinia()

app.use(router)
   .use(pinia)
   .use(vuetify)
   .mount('#app')
EOL

# Router Configuration
cat > src/router.js << EOL
import { createRouter, createWebHistory } from 'vue-router'
import { useWeb3Store } from '@/stores/web3Store'

import HomePage from '@/pages/HomePage.vue'
import ProfilePage from '@/pages/ProfilePage.vue'
import DashboardPage from '@/pages/DashboardPage.vue'

const routes = [
  { 
    path: '/', 
    component: HomePage,
    meta: { requiresAuth: false }
  },
  { 
    path: '/profile', 
    component: ProfilePage,
    meta: { requiresAuth: true }
  },
  { 
    path: '/dashboard', 
    component: DashboardPage,
    meta: { requiresAuth: true }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  const web3Store = useWeb3Store()
  
  if (to.meta.requiresAuth && !web3Store.isConnected) {
    next('/')
  } else {
    next()
  }
})

export default router
EOL

# Web3 Store
cat > src/stores/web3Store.js << EOL
import { defineStore } from 'pinia'
import { ethers } from 'ethers'

export const useWeb3Store = defineStore('web3', {
  state: () => ({
    account: null,
    isConnected: false,
    chainId: null,
    balance: null,
    userProfile: null,
    transactions: [],
    networkName: null
  }),
  actions: {
    async connectWallet() {
      try {
        if (!window.ethereum) {
          throw new Error('MetaMask not found')
        }

        const accounts = await window.ethereum.request({
          method: 'eth_requestAccounts'
        })

        const provider = new ethers.providers.Web3Provider(window.ethereum)
        const signer = provider.getSigner()

        const network = await provider.getNetwork()
        const address = accounts[0]
        const balance = await provider.getBalance(address)

        this.account = address
        this.isConnected = true
        this.chainId = network.chainId
        this.balance = ethers.utils.formatEther(balance)
        this.networkName = network.name

        this.userProfile = {
          address: address,
          registeredAt: new Date().toISOString()
        }

        window.ethereum.on('accountsChanged', this.handleAccountsChanged)
        window.ethereum.on('chainChanged', this.handleChainChanged)

        return address
      } catch (error) {
        console.error('Wallet connection error:', error)
        this.resetState()
        throw error
      }
    },
    handleAccountsChanged(accounts) {
      if (accounts.length === 0) {
        this.resetState()
      } else {
        this.account = accounts[0]
      }
    },
    handleChainChanged(chainId) {
      window.location.reload()
    },
    resetState() {
      this.account = null
      this.isConnected = false
      this.chainId = null
      this.balance = null
      this.userProfile = null
      this.transactions = []
      this.networkName = null

      if (window.ethereum && window.ethereum.removeAllListeners) {
        window.ethereum.removeAllListeners('accountsChanged')
        window.ethereum.removeAllListeners('chainChanged')
      }
    },
    async disconnectWallet() {
      try {
        this.resetState()
        return true
      } catch (error) {
        console.error('Disconnection error:', error)
        this.resetState()
        throw error
      }
    },
    addTransaction(transaction) {
      if (this.isConnected) {
        this.transactions.push(transaction)
      }
    }
  }
})
EOL

# Wallet Connect Component
cat > src/components/web3/WalletConnect.vue << EOL
<template>
  <div>
    <v-btn 
      v-if="!web3Store.isConnected"
      @click="connectWallet" 
      color="primary"
    >
      Connect Wallet
    </v-btn>
    <v-btn 
      v-else
      @click="disconnectWallet" 
      color="error"
    >
      Disconnect
    </v-btn>
  </div>
</template>

<script setup>
import { useWeb3Store } from '@/stores/web3Store'
import { useRouter } from 'vue-router'

const web3Store = useWeb3Store()
const router = useRouter()

const connectWallet = async () => {
  try {
    await web3Store.connectWallet()
    router.push('/dashboard')
  } catch (error) {
    console.error('Connection failed:', error)
  }
}

const disconnectWallet = async () => {
  try {
    await web3Store.disconnectWallet()
    router.push('/')
  } catch (error) {
    console.error('Disconnection failed:', error)
  }
}
</script>
EOL

# App.vue
cat > src/App.vue << EOL
<template>
  <v-app>
    <v-app-bar color="primary" app>
      <v-app-bar-nav-icon @click.stop="drawer = !drawer"></v-app-bar-nav-icon>
      <v-toolbar-title>Web3 DApp</v-toolbar-title>
      <v-spacer></v-spacer>
      <WalletConnect />
    </v-app-bar>

    <v-navigation-drawer v-model="drawer" app>
      <v-list>
        <v-list-item 
          v-for="item in menuItems" 
          :key="item.path"
          :to="item.path"
        >
          <v-list-item-title>{{ item.title }}</v-list-item-title>
        </v-list-item>
        
        <v-list-item 
          v-if="web3Store.isConnected"
          @click="logout"
        >
          <v-list-item-title class="text-error">Logout</v-list-item-title>
        </v-list-item>
      </v-list>
    </v-navigation-drawer>

    <v-main>
      <router-view v-slot="{ Component }">
        <v-container fluid>
          <component :is="Component" />
        </v-container>
      </router-view>
    </v-main>
  </v-app>
</template>

<script setup>
import { ref } from 'vue'
import { useWeb3Store } from '@/stores/web3Store'
import { useRouter } from 'vue-router'
import WalletConnect from '@/components/web3/WalletConnect.vue'

const web3Store = useWeb3Store()
const router = useRouter()

const drawer = ref(false)

const menuItems = [
  { title: 'Home', path: '/' },
  { title: 'Profile', path: '/profile' },
  { title: 'Dashboard', path: '/dashboard' }
]

const logout = async () => {
  try {
    await web3Store.disconnectWallet()
    router.push('/')
    drawer.value = false
  } catch (error) {
    console.error('Logout failed:', error)
  }
}
</script>
EOL

# Home Page
cat > src/pages/HomePage.vue << EOL
<template>
  <v-container>
    <v-row>
      <v-col cols="12" class="text-center">
        <h1 class="text-h4 mb-4">Welcome to Web3 DApp</h1>
        <p>Connect your wallet to explore more features!</p>
        <WalletConnect v-if="!web3Store.isConnected" />
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import { useWeb3Store } from '@/stores/web3Store'
import WalletConnect from '@/components/web3/WalletConnect.vue'

const web3Store = useWeb3Store()
</script>
EOL

# Profile Page
cat > src/pages/ProfilePage.vue << EOL
<template>
  <v-container>
    <v-card v-if="web3Store.isConnected">
      <v-card-title>Your Profile</v-card-title>
      <v-card-text>
        <p>Address: {{ web3Store.account }}</p>
        <p>Balance: {{ web3Store.balance }} ETH</p>
        <p>Network: {{ web3Store.networkName }}</p>
        <p>Chain ID: {{ web3Store.chainId }}</p>
      </v-card-text>
    </v-card>
    <v-alert v-else type="warning">
      Please connect your wallet first
    </v-alert>
  </v-container>
</template>

<script setup>
import { useWeb3Store } from '@/stores/web3Store'

const web3Store = useWeb3Store()
</script>
EOL

# Dashboard Page
cat > src/pages/DashboardPage.vue << EOL
<template>
  <v-container>
    <v-card v-if="web3Store.isConnected">
      <v-card-title>Dashboard</v-card-title>
      <v-card-text>
        <v-row>
          <v-col>
            <h2>Wallet Details</h2>
            <p>Connected Address: {{ web3Store.account }}</p>
            <p>Network: {{ web3Store.networkName }}</p>
          </v-col>
        </v-row>
      </v-card-text>
    </v-card>
    <v-alert v-else type="warning">
      Please connect your wallet first
    </v-alert>
  </v-container>
</template>

<script setup>
import { useWeb3Store } from '@/stores/web3Store'

const web3Store = useWeb3Store()
</script>
EOL

# Create README
cat > README.md << EOL
# Web3 DApp with Vue 3, Vite, Vuetify, and MetaMask

## Project Setup

1. Install dependencies
\`\`\`bash
npm install
\`\`\`

2. Run development server
\`\`\`bash
npm run dev
\`\`\`

## Features
- MetaMask wallet connection
- Vuetify responsive design
- Vue Router with protected routes
- Pinia state management
- Web3 wallet integration
- Logout functionality

## Requirements
- Node.js
- MetaMask browser extension
EOL

# Create .gitignore
cat > .gitignore << EOL
node_modules
dist
.env
.DS_Store
*.log
EOL

# Create index.html
cat > index.html << EOL
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Web3 DApp</title>
</head>
<body>
    <div id="app"></div>
    <script type="module" src="/src/main.js"></script>
</body>
</html>
EOL

# Compress the project
tar -czvf my-web3-app.tar.gz my-web3-app

echo "Project created and compressed as my-web3-app.tar.gz"
