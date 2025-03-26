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
