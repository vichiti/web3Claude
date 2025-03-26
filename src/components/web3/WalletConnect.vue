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
