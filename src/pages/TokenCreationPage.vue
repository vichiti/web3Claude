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
const TOKEN_CONTRACT_BYTECODE = '608060405234801561000f575f80fd5b506040516118dc3803806118dc833981810160405281019061003191906104b7565b828281600390816100429190610743565b5080600490816100529190610743565b5050506100893361006761009160201b60201c565b600a610073919061097a565b8361007e91906109c4565b61009960201b60201c565b505050610aed565b5f6012905090565b5f73ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff1603610109575f6040517fec442f050000000000000000000000000000000000000000000000000000000081526004016101009190610a44565b60405180910390fd5b61011a5f838361011e60201b60201c565b5050565b5f73ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff160361016e578060025f8282546101629190610a5d565b9250508190555061023c565b5f805f8573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f20549050818110156101f7578381836040517fe450d38c0000000000000000000000000000000000000000000000000000000081526004016101ee93929190610a9f565b60405180910390fd5b8181035f808673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f2081905550505b5f73ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff1603610283578060025f82825403925050819055506102cd565b805f808473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f82825401925050819055505b8173ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef8360405161032a9190610ad4565b60405180910390a3505050565b5f604051905090565b5f80fd5b5f80fd5b5f80fd5b5f80fd5b5f601f19601f8301169050919050565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52604160045260245ffd5b61039682610350565b810181811067ffffffffffffffff821117156103b5576103b4610360565b5b80604052505050565b5f6103c7610337565b90506103d3828261038d565b919050565b5f67ffffffffffffffff8211156103f2576103f1610360565b5b6103fb82610350565b9050602081019050919050565b8281835e5f83830152505050565b5f610428610423846103d8565b6103be565b9050828152602081018484840111156104445761044361034c565b5b61044f848285610408565b509392505050565b5f82601f83011261046b5761046a610348565b5b815161047b848260208601610416565b91505092915050565b5f819050919050565b61049681610484565b81146104a0575f80fd5b50565b5f815190506104b18161048d565b92915050565b5f805f606084860312156104ce576104cd610340565b5b5f84015167ffffffffffffffff8111156104eb576104ea610344565b5b6104f786828701610457565b935050602084015167ffffffffffffffff81111561051857610517610344565b5b61052486828701610457565b9250506040610535868287016104a3565b9150509250925092565b5f81519050919050565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52602260045260245ffd5b5f600282049050600182168061058d57607f821691505b6020821081036105a05761059f610549565b5b50919050565b5f819050815f5260205f209050919050565b5f6020601f8301049050919050565b5f82821b905092915050565b5f600883026106027fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff826105c7565b61060c86836105c7565b95508019841693508086168417925050509392505050565b5f819050919050565b5f61064761064261063d84610484565b610624565b610484565b9050919050565b5f819050919050565b6106608361062d565b61067461066c8261064e565b8484546105d3565b825550505050565b5f90565b61068861067c565b610693818484610657565b505050565b5b818110156106b6576106ab5f82610680565b600181019050610699565b5050565b601f8211156106fb576106cc816105a6565b6106d5846105b8565b810160208510156106e4578190505b6106f86106f0856105b8565b830182610698565b50505b505050565b5f82821c905092915050565b5f61071b5f1984600802610700565b1980831691505092915050565b5f610733838361070c565b9150826002028217905092915050565b61074c8261053f565b67ffffffffffffffff81111561076557610764610360565b5b61076f8254610576565b61077a8282856106ba565b5f60209050601f8311600181146107ab575f8415610799578287015190505b6107a38582610728565b86555061080a565b601f1984166107b9866105a6565b5f5b828110156107e0578489015182556001820191506020850194506020810190506107bb565b868310156107fd57848901516107f9601f89168261070c565b8355505b6001600288020188555050505b505050505050565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52601160045260245ffd5b5f8160011c9050919050565b5f808291508390505b6001851115610894578086048111156108705761086f610812565b5b600185161561087f5780820291505b808102905061088d8561083f565b9450610854565b94509492505050565b5f826108ac5760019050610967565b816108b9575f9050610967565b81600181146108cf57600281146108d957610908565b6001915050610967565b60ff8411156108eb576108ea610812565b5b8360020a91508482111561090257610901610812565b5b50610967565b5060208310610133831016604e8410600b841016171561093d5782820a90508381111561093857610937610812565b5b610967565b61094a848484600161084b565b9250905081840481111561096157610960610812565b5b81810290505b9392505050565b5f60ff82169050919050565b5f61098482610484565b915061098f8361096e565b92506109bc7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff848461089d565b905092915050565b5f6109ce82610484565b91506109d983610484565b92508282026109e781610484565b915082820484148315176109fe576109fd610812565b5b5092915050565b5f73ffffffffffffffffffffffffffffffffffffffff82169050919050565b5f610a2e82610a05565b9050919050565b610a3e81610a24565b82525050565b5f602082019050610a575f830184610a35565b92915050565b5f610a6782610484565b9150610a7283610484565b9250828201905080821115610a8a57610a89610812565b5b92915050565b610a9981610484565b82525050565b5f606082019050610ab25f830186610a35565b610abf6020830185610a90565b610acc6040830184610a90565b949350505050565b5f602082019050610ae75f830184610a90565b92915050565b610de280610afa5f395ff3fe608060405234801561000f575f80fd5b5060043610610091575f3560e01c8063313ce56711610064578063313ce5671461013157806370a082311461014f57806395d89b411461017f578063a9059cbb1461019d578063dd62ed3e146101cd57610091565b806306fdde0314610095578063095ea7b3146100b357806318160ddd146100e357806323b872dd14610101575b5f80fd5b61009d6101fd565b6040516100aa9190610a5b565b60405180910390f35b6100cd60048036038101906100c89190610b0c565b61028d565b6040516100da9190610b64565b60405180910390f35b6100eb6102af565b6040516100f89190610b8c565b60405180910390f35b61011b60048036038101906101169190610ba5565b6102b8565b6040516101289190610b64565b60405180910390f35b6101396102e6565b6040516101469190610c10565b60405180910390f35b61016960048036038101906101649190610c29565b6102ee565b6040516101769190610b8c565b60405180910390f35b610187610333565b6040516101949190610a5b565b60405180910390f35b6101b760048036038101906101b29190610b0c565b6103c3565b6040516101c49190610b64565b60405180910390f35b6101e760048036038101906101e29190610c54565b6103e5565b6040516101f49190610b8c565b60405180910390f35b60606003805461020c90610cbf565b80601f016020809104026020016040519081016040528092919081815260200182805461023890610cbf565b80156102835780601f1061025a57610100808354040283529160200191610283565b820191905f5260205f20905b81548152906001019060200180831161026657829003601f168201915b5050505050905090565b5f80610297610467565b90506102a481858561046e565b600191505092915050565b5f600254905090565b5f806102c2610467565b90506102cf858285610480565b6102da858585610513565b60019150509392505050565b5f6012905090565b5f805f8373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f20549050919050565b60606004805461034290610cbf565b80601f016020809104026020016040519081016040528092919081815260200182805461036e90610cbf565b80156103b95780601f10610390576101008083540402835291602001916103b9565b820191905f5260205f20905b81548152906001019060200180831161039c57829003601f168201915b5050505050905090565b5f806103cd610467565b90506103da818585610513565b600191505092915050565b5f60015f8473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f8373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f2054905092915050565b5f33905090565b61047b8383836001610603565b505050565b5f61048b84846103e5565b90507fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff81101561050d57818110156104fe578281836040517ffb8f41b20000000000000000000000000000000000000000000000000000000081526004016104f593929190610cfe565b60405180910390fd5b61050c84848484035f610603565b5b50505050565b5f73ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff1603610583575f6040517f96c6fd1e00000000000000000000000000000000000000000000000000000000815260040161057a9190610d33565b60405180910390fd5b5f73ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff16036105f3575f6040517fec442f050000000000000000000000000000000000000000000000000000000081526004016105ea9190610d33565b60405180910390fd5b6105fe8383836107d2565b505050565b5f73ffffffffffffffffffffffffffffffffffffffff168473ffffffffffffffffffffffffffffffffffffffff1603610673575f6040517fe602df0500000000000000000000000000000000000000000000000000000000815260040161066a9190610d33565b60405180910390fd5b5f73ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff16036106e3575f6040517f94280d620000000000000000000000000000000000000000000000000000000081526004016106da9190610d33565b60405180910390fd5b8160015f8673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f8573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f208190555080156107cc578273ffffffffffffffffffffffffffffffffffffffff168473ffffffffffffffffffffffffffffffffffffffff167f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925846040516107c39190610b8c565b60405180910390a35b50505050565b5f73ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff1603610822578060025f8282546108169190610d79565b925050819055506108f0565b5f805f8573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f20549050818110156108ab578381836040517fe450d38c0000000000000000000000000000000000000000000000000000000081526004016108a293929190610cfe565b60405180910390fd5b8181035f808673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f2081905550505b5f73ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff1603610937578060025f8282540392505081905550610981565b805f808473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f82825401925050819055505b8173ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef836040516109de9190610b8c565b60405180910390a3505050565b5f81519050919050565b5f82825260208201905092915050565b8281835e5f83830152505050565b5f601f19601f8301169050919050565b5f610a2d826109eb565b610a3781856109f5565b9350610a47818560208601610a05565b610a5081610a13565b840191505092915050565b5f6020820190508181035f830152610a738184610a23565b905092915050565b5f80fd5b5f73ffffffffffffffffffffffffffffffffffffffff82169050919050565b5f610aa882610a7f565b9050919050565b610ab881610a9e565b8114610ac2575f80fd5b50565b5f81359050610ad381610aaf565b92915050565b5f819050919050565b610aeb81610ad9565b8114610af5575f80fd5b50565b5f81359050610b0681610ae2565b92915050565b5f8060408385031215610b2257610b21610a7b565b5b5f610b2f85828601610ac5565b9250506020610b4085828601610af8565b9150509250929050565b5f8115159050919050565b610b5e81610b4a565b82525050565b5f602082019050610b775f830184610b55565b92915050565b610b8681610ad9565b82525050565b5f602082019050610b9f5f830184610b7d565b92915050565b5f805f60608486031215610bbc57610bbb610a7b565b5b5f610bc986828701610ac5565b9350506020610bda86828701610ac5565b9250506040610beb86828701610af8565b9150509250925092565b5f60ff82169050919050565b610c0a81610bf5565b82525050565b5f602082019050610c235f830184610c01565b92915050565b5f60208284031215610c3e57610c3d610a7b565b5b5f610c4b84828501610ac5565b91505092915050565b5f8060408385031215610c6a57610c69610a7b565b5b5f610c7785828601610ac5565b9250506020610c8885828601610ac5565b9150509250929050565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52602260045260245ffd5b5f6002820490506001821680610cd657607f821691505b602082108103610ce957610ce8610c92565b5b50919050565b610cf881610a9e565b82525050565b5f606082019050610d115f830186610cef565b610d1e6020830185610b7d565b610d2b6040830184610b7d565b949350505050565b5f602082019050610d465f830184610cef565b92915050565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52601160045260245ffd5b5f610d8382610ad9565b9150610d8e83610ad9565b9250828201905080821115610da657610da5610d4c565b5b9291505056fea264697066735822122085a4a13f36bd35cbbe081c8666113ef1aca064a1269c61860eb5cbcf9b62b3da64736f6c634300081a0033' // Replace with actual bytecode
const TOKEN_CONTRACT_ABI = [
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "symbol",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "initialSupply",
				"type": "uint256"
			}
		],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "spender",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "allowance",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "needed",
				"type": "uint256"
			}
		],
		"name": "ERC20InsufficientAllowance",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "sender",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "balance",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "needed",
				"type": "uint256"
			}
		],
		"name": "ERC20InsufficientBalance",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "approver",
				"type": "address"
			}
		],
		"name": "ERC20InvalidApprover",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "receiver",
				"type": "address"
			}
		],
		"name": "ERC20InvalidReceiver",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "sender",
				"type": "address"
			}
		],
		"name": "ERC20InvalidSender",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "spender",
				"type": "address"
			}
		],
		"name": "ERC20InvalidSpender",
		"type": "error"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "spender",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			}
		],
		"name": "Approval",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			}
		],
		"name": "Transfer",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "spender",
				"type": "address"
			}
		],
		"name": "allowance",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "spender",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			}
		],
		"name": "approve",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "balanceOf",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "decimals",
		"outputs": [
			{
				"internalType": "uint8",
				"name": "",
				"type": "uint8"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "name",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "symbol",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "totalSupply",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			}
		],
		"name": "transfer",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			}
		],
		"name": "transferFrom",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	}
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