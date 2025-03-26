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
