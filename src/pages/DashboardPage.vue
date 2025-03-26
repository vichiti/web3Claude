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
