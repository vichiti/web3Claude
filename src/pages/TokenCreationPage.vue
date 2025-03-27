<!-- src/pages/TokenCreationPage.vue -->
<template>
  <v-container>
    <v-card v-if="web3Store.isConnected">
      <v-card-title>Create Fungible Token for Hedera</v-card-title>
      <v-card-text>
        <v-text-field 
          v-model="tokenName" 
          label="Token Name"
          placeholder="Enter token name"
        ></v-text-field>
        
        <v-text-field 
          v-model="tokenSymbol" 
          label="Token Symbol"
          placeholder="Enter token symbol"
        ></v-text-field>
        
        <v-text-field 
          v-model.number="initialSupply" 
          label="Initial Supply"
          type="number"
          placeholder="Enter initial token supply"
        ></v-text-field>
        
        <v-btn 
          @click="createToken" 
          color="primary"
          :disabled="!tokenName || !tokenSymbol || !initialSupply"
        >
          Create Token
        </v-btn>
        
        <v-alert 
          v-if="deployedTokenAddress" 
          type="success" 
          class="mt-4"
        >
          Token Deployed at: {{ deployedTokenAddress }}
        </v-alert>
        
        <v-alert 
          v-if="transactionHash" 
          type="info" 
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

// Sample ERC20 Token Contract (Simplified for Hedera/Ethereum)
const TOKEN_CONTRACT_BYTECODE = '0x60806040...' // Replace with actual bytecode
const TOKEN_CONTRACT_ABI = [
  "constructor(string memory name, string memory symbol, uint256 initialSupply)",
  "function name() public view returns (string memory)",
  "function symbol() public view returns (string memory)",
  "function totalSupply() public view returns (uint256)",
  "function balanceOf(address account) public view returns (uint256)"
]

const tokenName = ref('')
const tokenSymbol = ref('')
const initialSupply = ref(null)
const deployedTokenAddress = ref(null)
const transactionHash = ref(null)

const createToken = async () => {
  try {
    if (!window.ethereum) {
      throw new Error('MetaMask not found')
    }

    const provider = new ethers.providers.Web3Provider(window.ethereum)
    const signer = provider.getSigner()

    // Create contract factory
    const factory = new ethers.ContractFactory(
      TOKEN_CONTRACT_ABI, 
      TOKEN_CONTRACT_BYTECODE, 
      signer
    )

    // Deploy the contract
    const contract = await factory.deploy(
      tokenName.value, 
      tokenSymbol.value, 
      ethers.utils.parseUnits(initialSupply.value.toString(), 18)
    )

    // Wait for deployment
    await contract.deployed()

    // Store deployment details
    deployedTokenAddress.value = contract.address
    transactionHash.value = contract.deployTransaction.hash

    // Add to web3 store transactions
    web3Store.addTransaction({
      type: 'Token Creation',
      tokenName: tokenName.value,
      tokenSymbol: tokenSymbol.value,
      address: contract.address,
      hash: contract.deployTransaction.hash,
      timestamp: new Date().toISOString()
    })

    alert('Token created successfully!')
  } catch (error) {
    console.error('Error creating token:', error)
    alert(`Failed to create token: ${error.message}`)
  }
}
</script>