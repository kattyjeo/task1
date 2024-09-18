#!/bin/bash

# Define Variables
GITHUB_REPO="https://github.com/kattyjeo/task1.git"
COMMIT_MESSAGE="Deploy smart contract and setup Hardhat project"
CONTRACT_NAME="MyFirstContract"

# Step 1: Install Node.js if not installed
if ! command -v node &> /dev/null
then
    echo "Node.js not found, installing..."
    sudo apt update
    sudo apt install nodejs npm -y
else
    echo "Node.js is already installed."
fi

# Step 2: Install Git if not installed
if ! command -v git &> /dev/null
then
    echo "Git not found, installing..."
    sudo apt install git -y
else
    echo "Git is already installed."
fi

# Step 3: Create Hardhat project structure manually
echo "Setting up Hardhat project..."
mkdir -p smart-contract/contracts
mkdir -p smart-contract/scripts

cd smart-contract

# Initialize npm and install Hardhat
npm init -y
npm install --save-dev hardhat

# Initialize Hardhat project
npx hardhat

# Step 4: Add a simple smart contract
echo "Creating smart contract..."
cat <<EOF > contracts/$CONTRACT_NAME.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract $CONTRACT_NAME {
    string public message;

    constructor(string memory _message) {
        message = _message;
    }

    function updateMessage(string memory _newMessage) public {
        message = _newMessage;
    }
}
EOF

# Step 5: Add a deployment script
echo "Creating deployment script..."
cat <<EOF > scripts/deploy.js
async function main() {
  const [deployer] = await ethers.getSigners();
  
  console.log("Deploying contracts with the account:", deployer.address);

  const Contract = await ethers.getContractFactory("$CONTRACT_NAME");
  const contract = await Contract.deploy("Hello, Blockchain!");

  console.log("Contract deployed to address:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
EOF

# Step 6: Compile the contract
echo "Compiling the contract..."
npx hardhat compile

# Step 7: Deploy the contract
echo "Deploying the contract..."
CONTRACT_ADDRESS=$(npx hardhat run scripts/deploy.js | grep -o '0x[a-fA-F0-9]\{40\}')
echo "Contract deployed at address: $CONTRACT_ADDRESS"

# Step 8: Initialize Git and push code to GitHub
echo "Pushing code to GitHub..."

git init
git remote add origin $GITHUB_REPO

git add .
git commit -m "$COMMIT_MESSAGE"

# Push to GitHub
git push origin main || echo "Failed to push. Please authenticate if required or set up SSH keys."

echo "Smart contract setup completed!"
