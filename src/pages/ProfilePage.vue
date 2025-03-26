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
