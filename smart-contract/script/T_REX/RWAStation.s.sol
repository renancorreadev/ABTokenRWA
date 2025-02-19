// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {ITREXFactory} from "../../src/T_REX/TREXFactory.sol";
import {IToken} from "@erc3643/contracts/token/IToken.sol";
import {IIdentityRegistry} from "@erc3643/contracts/registry/interface/IIdentityRegistry.sol";
import {IIdentityRegistryStorage} from "@erc3643/contracts/registry/interface/IIdentityRegistryStorage.sol";
import {IIdentity} from "@onchain-id/solidity/contracts/interface/IIdentity.sol";
import {IClaimTopicsRegistry} from "@erc3643/contracts/registry/interface/IClaimTopicsRegistry.sol";
import {ITrustedIssuersRegistry} from "@erc3643/contracts/registry/interface/ITrustedIssuersRegistry.sol";
import {IModularCompliance} from "@erc3643/contracts/compliance/modular/IModularCompliance.sol";

contract DeployRWAToken is Script {
    address public deployer;
    address public investor1;

    // Endereços dos contratos a serem implantados
    address public tokenAddress;
    address public identityRegistryAddress;
    address public identityRegistryStorageAddress;
    address public complianceAddress;
    address public trustedIssuersRegistryAddress;
    address public claimTopicsRegistryAddress;

    ITREXFactory public trexFactory;

    function run() external {
        deployer = vm.envAddress("DEPLOYER_KEY");

        investor1 = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266); // Endereço fictício para testes

        vm.startBroadcast(vm.envUint("DEPLOYER_KEY"));

        // 1️⃣ Obter a instância do TREXFactory já implantado
        trexFactory = ITREXFactory(0x123456789aBCdEF123456789aBCdef123456789A); // 🛑 Altere para o endereço real!

        // 2️⃣ Criar parâmetros do deploy
        ITREXFactory.TokenDetails memory tokenDetails = ITREXFactory.TokenDetails({
            owner: deployer,
            name: "RealEstateToken",
            symbol: "RET",
            decimals: 0,
            irs: address(0), // Deixar em 0 para a factory criar
            ONCHAINID: address(0),
            irAgents: new address[](0),
            tokenAgents: new address[](0),
            complianceModules: new address[](0),
            complianceSettings: new bytes[](0)
        });

        // 3️⃣ Configurar as claims do KYC
        uint256[] memory claimTopics = new uint256[](0); // KYC
        address[] memory issuers = new address[](0);
        uint256[][] memory issuerClaims = new uint256[][](0);
        ITREXFactory.ClaimDetails memory claimDetails =
            ITREXFactory.ClaimDetails({claimTopics: claimTopics, issuers: issuers, issuerClaims: issuerClaims});

        // 4️⃣ Realizar o deploy do T-REX Suite
        string memory salt = "RWA-TOKEN-DEPLOY";
        trexFactory.deployTREXSuite(salt, tokenDetails, claimDetails);

        // 5️⃣ Obter os contratos criados
        tokenAddress = trexFactory.getToken(salt);

        IToken token = IToken(tokenAddress);
        IIdentityRegistry identityRegistry = IIdentityRegistry(token.identityRegistry());
        identityRegistryAddress = address(identityRegistry);

        IModularCompliance compliance = IModularCompliance(token.compliance());
        complianceAddress = address(compliance);

        // Corrigido: Obter o TrustedIssuersRegistry corretamente
        IIdentityRegistryStorage identityRegistryStorage = IIdentityRegistryStorage(identityRegistry.identityStorage());
        identityRegistryStorageAddress = address(identityRegistryStorage);

        trustedIssuersRegistryAddress = address(identityRegistry.issuersRegistry());
        claimTopicsRegistryAddress = address(identityRegistry.topicsRegistry());

        // 6️⃣ Simular KYC: Registrar um investidor fictício na IdentityRegistry
        identityRegistry.registerIdentity(investor1, IIdentity(address(0)), 76); // 76 = Brasil

        // 7️⃣ Mintar tokens para o investidor KYC'd
        token.mint(investor1, 1000);

        vm.stopBroadcast();

        // 8️⃣ Exibir os endereços dos contratos implantados
        console.log("======================================================");
        console.log("** Deploy finalizado com sucesso! Enderecos dos contratos: **");
        console.log("Token Address: ", tokenAddress);
        console.log("IdentityRegistry Address: ", identityRegistryAddress);
        console.log("IdentityRegistryStorage Address: ", identityRegistryStorageAddress);
        console.log("Compliance Address: ", complianceAddress);
        console.log("TrustedIssuersRegistry Address: ", trustedIssuersRegistryAddress);
        console.log("ClaimTopicsRegistry Address: ", claimTopicsRegistryAddress);
        console.log("Mintou 1000 tokens para o investidor: ", investor1);
        console.log("======================================================");
    }
}
