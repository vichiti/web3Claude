<!-- src/pages/ContractInteractionPage.vue -->
<template>
  <v-container>
    <v-card v-if="web3Store.isConnected">
      <v-card-title>Smart Contract Interaction</v-card-title>
      <v-card-text>
        <v-text-field 
          v-model="contractAddress" 
          label="Contract Address"
          placeholder="Enter contract address from Remix"
        ></v-text-field>
        
        <v-text-field 
          v-model.number="valueToSet" 
          label="Value to Set"
          type="number"
        ></v-text-field>
        
        <v-row>
          <v-col>
            <v-btn 
              @click="setValue" 
              color="primary"
              :disabled="!contractAddress || valueToSet === null"
            >
              Set Value
            </v-btn>
          </v-col>
          <v-col>
            <v-btn 
              @click="getValue" 
              color="secondary"
              :disabled="!contractAddress"
            >
              Get Value
            </v-btn>
          </v-col>
        </v-row>
        
        <v-alert 
          v-if="retrievedValue !== null" 
          type="info" 
          class="mt-4"
        >
          Retrieved Value: {{ retrievedValue }}
        </v-alert>
        
        <v-alert 
          v-if="transactionHash" 
          type="success" 
          class="mt-4"
        >
          Transaction Hash: {{ transactionHash }}
        </v-alert>
      </v-card-text>
    </v-card>
    <v-alert v-else type="warning">
      Please connect your wallet first
    </v-alert>
  </v-container>
</template>

<script setup>
import { ref } from 'vue'
import { useWeb3Store } from '@/stores/web3Store'
import { ethers } from 'ethers'

const web3Store = useWeb3Store()

// Sample ABI for a simple storage contract
const CONTRACT_ABI = [
  "function setValue(uint256 _value)",
  "function getValue() public view returns (uint256)"
]

const contractAddress = ref('')
const valueToSet = ref(null)
const retrievedValue = ref(null)
const transactionHash = ref(null)

const setValue = async () => {
  try {
    if (!window.ethereum) {
      throw new Error('MetaMask not found')
    }

    const provider = new ethers.providers.Web3Provider(window.ethereum)
    const signer = provider.getSigner()
    const contract = new ethers.Contract(contractAddress.value, CONTRACT_ABI, signer)
    
    const tx = await contract.setValue(valueToSet.value)
    await tx.wait()
    
    transactionHash.value = tx.hash
    web3Store.addTransaction({
      type: 'Contract Interaction',
      action: 'Set Value',
      hash: tx.hash,
      timestamp: new Date().toISOString()
    })
  } catch (error) {
    console.error('Error setting value:', error)
    alert(`Failed to set value: ${error.message}`)
  }
}

const getValue = async () => {
  try {
    if (!window.ethereum) {
      throw new Error('MetaMask not found')
    }

    const provider = new ethers.providers.Web3Provider(window.ethereum)
    const contract = new ethers.Contract(contractAddress.value, CONTRACT_ABI, provider)
    
    const value = await contract.getValue()
    retrievedValue.value = value.toNumber()
  } catch (error) {
    console.error('Error getting value:', error)
    alert(`Failed to get value: ${error.message}`)
  }
}
</script>