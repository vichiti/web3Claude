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
