// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {console} from "forge-std/console.sol";
import {Test} from "forge-std/Test.sol";
import {ABToken} from "../src/ABToken.sol";

import {MockIdentityRegistry} from "./mocks/IdentityRegistryMock.sol";
import {MockModularCompliance} from "./mocks/ModularComplianceMock.sol";
import {MockIdentityOnChainID} from "./mocks/IdentityOnChainIDMock.sol";

/// @dev Mocks smart contracts off identityRegistry
import {ClaimTopicsRegistryMock} from "./mocks/utils/ClaimTopicsRegistryMock.sol";
import {IdentityRegistryStorageMock} from "./mocks/utils/IdentityRegistryStorageMock.sol";
import {TrustedIssuersRegistryMock} from "./mocks/utils/TrustedIssuersRegistryMock.sol";

/// @dev Interfaces
import {IIdentity} from "@onchain-id/solidity/contracts/interface/IIdentity.sol";

contract ERC3643Test is Test {
    address public owner;
    uint256 private _ownerPrivateKey;

    /// @dev Smart contract instances
    ABToken public abTokenInstance;

    // Mocks setups
    MockIdentityRegistry public identityRegistry;
    MockModularCompliance public compliance;
    MockIdentityOnChainID public onchainID;

    // Mocks setups utils from  identityRegistry
    ClaimTopicsRegistryMock public claimTopicsRegistry;
    IdentityRegistryStorageMock public identityRegistryStorage;
    TrustedIssuersRegistryMock public trustedIssuersRegistry;

    // ------------------------------------------------------------
    function setUp() public {
        /// @dev 🔹 Cria o owner
        (owner, _ownerPrivateKey) = makeAddrAndKey("owner");

        vm.startPrank(owner);
        /// ------------------------------------------------------------
        /// @dev 🔹 Deploy dos mocks
        trustedIssuersRegistry = new TrustedIssuersRegistryMock();
        claimTopicsRegistry = new ClaimTopicsRegistryMock();
        identityRegistryStorage = new IdentityRegistryStorageMock();
        identityRegistry = new MockIdentityRegistry();
        compliance = new MockModularCompliance();
        onchainID = new MockIdentityOnChainID();

        /// ----------------- Deploy do contrato -----------------
        abTokenInstance = new ABToken();
        /// ------------------------------------------------------------
        /// @dev 🔹 Inicializa ownable mocks
        identityRegistryStorage.init();
        trustedIssuersRegistry.init();
        claimTopicsRegistry.init();
        identityRegistry.init(
            address(trustedIssuersRegistry),
            address(claimTopicsRegistry),
            address(identityRegistryStorage)
        );
        abTokenInstance.init(
            address(identityRegistry),
            address(compliance),
            "TestABToken",
            "TTK",
            18,
            address(onchainID)
        );

        /// @dev Adiciona o owner como agente supervisionador
        identityRegistryStorage.addAgent(owner); // Owner pode modificar storage
        identityRegistryStorage.addAgent(address(identityRegistry)); // IdentityRegistry pode modificar storage
        identityRegistry.addAgent(owner); // Owner pode modificar IdentityRegistry
        abTokenInstance.addAgent(owner); // Owner pode mintar tokens
        vm.stopPrank();
    }

   

    function testMint() public {
        address user;
        uint256 userPrivateKey;
        (user, userPrivateKey) = makeAddrAndKey("user");

        uint256 mintAmount = 1000 * 10 ** 18;

        vm.startPrank(owner);
        /// @dev Registra a identidade do usuário
        identityRegistry.registerIdentity(
            user,
            IIdentity(address(onchainID)),
            1
        );

        /// @dev Minta tokens para o usuário
        abTokenInstance.mint(user, mintAmount);
        vm.stopPrank();

        /// @dev Verifica se o usuário recebeu os tokens corretamente
        uint256 userBalance = abTokenInstance.balanceOf(user);
        console.log("User Balance:", userBalance);
        assertEq(userBalance, mintAmount, "Minting failed: balance incorrect");
    }

    function testBurn() public {
        address user;
        uint256 userPrivateKey;
        (user, userPrivateKey) = makeAddrAndKey("user");

        uint256 mintAmount = 1000 * 10 ** 18;
        uint256 burnAmount = 500 * 10 ** 18;

        vm.startPrank(owner);
        /// @dev Registra a identidade do usuário
        identityRegistry.registerIdentity(
            user,
            IIdentity(address(onchainID)),
            1
        );

        /// @dev Minta tokens para o usuário
        abTokenInstance.mint(user, mintAmount);
        vm.stopPrank();

        /// @dev Verifica o saldo inicial
        uint256 initialBalance = abTokenInstance.balanceOf(user);
        assertEq(initialBalance, mintAmount, "Erro: saldo inicial incorreto");

        vm.startPrank(owner);
        /// @dev Queima tokens do usuário
        abTokenInstance.burn(user, burnAmount);
        vm.stopPrank();

        /// @dev Verifica o saldo após queima
        uint256 finalBalance = abTokenInstance.balanceOf(user);
        assertEq(
            finalBalance,
            mintAmount - burnAmount,
            "Erro: saldo apos burn incorreto"
        );

        console.log("User Balance after burn:", finalBalance);
    }

    function testBurnUnauthorized() public {
        address user;
        uint256 userPrivateKey;
        (user, userPrivateKey) = makeAddrAndKey("user");

        uint256 mintAmount = 1000 * 10 ** 18;
        uint256 burnAmount = 500 * 10 ** 18;

        vm.startPrank(owner);
        identityRegistry.registerIdentity(
            user,
            IIdentity(address(onchainID)),
            1
        );
        abTokenInstance.mint(user, mintAmount);
        vm.stopPrank();

        /// @dev Testa que um usuário sem permissão **NÃO** pode queimar tokens
        vm.startPrank(user);
        vm.expectRevert("AgentRole: caller does not have the Agent role");
        abTokenInstance.burn(user, burnAmount);
        vm.stopPrank();
    }

    function testTransfer() public {
        address user1;
        address user2;
        (user1, ) = makeAddrAndKey("user1");
        (user2, ) = makeAddrAndKey("user2");

        uint256 mintAmount = 1000 * 10 ** 18;
        uint256 transferAmount = 500 * 10 ** 18;

        /// @dev Registra as identidades dos usuários
        vm.startPrank(owner);
        identityRegistry.registerIdentity(
            user1,
            IIdentity(address(onchainID)),
            1
        );
        identityRegistry.registerIdentity(
            user2,
            IIdentity(address(onchainID)),
            1
        );

        /// @dev Minta tokens para o usuário 1
        abTokenInstance.mint(user1, mintAmount);
        vm.stopPrank();

        /// @dev Despausa o token
        vm.startPrank(owner);
        abTokenInstance.unpause();
        vm.stopPrank();

        /// @dev Transfere tokens do usuário 1 para o usuário 2
        vm.startPrank(user1);
        abTokenInstance.transfer(user2, transferAmount);
        vm.stopPrank();

        assertEq(
            abTokenInstance.balanceOf(user1),
            mintAmount - transferAmount,
            "Transfer failed: sender balance incorrect"
        );
        assertEq(
            abTokenInstance.balanceOf(user2),
            transferAmount,
            "Transfer failed: receiver balance incorrect"
        );
    }

    function testTransferFromSetup() public returns (
        address user1,
        address user2,
        uint256 mintAmount,
        uint256 transferAmount
    ) {
        uint256 user1PrivateKey;
        uint256 user2PrivateKey;
        (user1, user1PrivateKey) = makeAddrAndKey("user1");
        (user2, user2PrivateKey) = makeAddrAndKey("user2");

        mintAmount = 1000 * 10 ** 18;
        transferAmount = 500 * 10 ** 18;

        vm.startPrank(owner);
        identityRegistry.registerIdentity(
            user1,
            IIdentity(address(onchainID)),
            1
        );
        identityRegistry.registerIdentity(
            user2,
            IIdentity(address(onchainID)),
            1
        );

        abTokenInstance.mint(user1, mintAmount);
        abTokenInstance.unpause();
        vm.stopPrank();

        return (user1, user2, mintAmount, transferAmount);
    }

    function testTransferFrom() public {
        (
            address user1,
            address user2,
            uint256 mintAmount,
            uint256 transferAmount
        ) = testTransferFromSetup();

        vm.startPrank(user1);
        abTokenInstance.approve(user2, transferAmount);
        vm.stopPrank();

        vm.startPrank(user2);
        abTokenInstance.transferFrom(user1, user2, transferAmount);
        vm.stopPrank();

        uint256 user1Balance = abTokenInstance.balanceOf(user1);
        uint256 user2Balance = abTokenInstance.balanceOf(user2);
        uint256 allowance = abTokenInstance.allowance(user1, user2);

        assertEq(
            user1Balance,
            mintAmount - transferAmount,
            "TransferFrom failed: sender balance incorrect"
        );
        assertEq(
            user2Balance,
            transferAmount,
            "TransferFrom failed: receiver balance incorrect"
        );
        assertEq(allowance, 0, "TransferFrom failed: allowance incorrect");
    }

    // solhint-disable-next-line 
    function testPauseAndUnpause() public {
        address user1;
        uint256 user1PrivateKey;
        (user1, user1PrivateKey) = makeAddrAndKey("user1");

        uint256 mintAmount = 1000 * 10 ** 18;
        uint256 transferAmount = 500 * 10 ** 18;

        vm.startPrank(owner);

        /// 🔹 Registra a identidade antes de qualquer ação
        identityRegistry.registerIdentity(
            user1,
            IIdentity(address(onchainID)),
            1
        );

        /// 🔹 Minta tokens para o usuário antes de pausar
        abTokenInstance.mint(user1, mintAmount);
        vm.stopPrank();

        /// 🔹 Tenta transferir tokens enquanto pausado (deve falhar)
        vm.startPrank(user1);
        vm.expectRevert("Pausable: paused");
        abTokenInstance.transfer(owner, transferAmount);
        console.log("transfer bloqueada corretamente enquanto pausado");
        vm.stopPrank();

        /// 🔹 Despausa antes da nova tentativa de transferência
        vm.startPrank(owner);
        abTokenInstance.unpause();
        console.log("Contrato despausado com sucesso");
        vm.stopPrank();

        /// 🔹 Verifica se o contrato está realmente despausado antes de transferir
        bool isPaused = abTokenInstance.paused();
        console.log("Contrato esta pausado?:", isPaused);
        assertEq(isPaused, false, "O contrato ainda esta pausado!");

        /// 🔹 Agora que está despausado, a transferência deve ocorrer normalmente

        vm.startPrank(user1);
        abTokenInstance.transfer(owner, transferAmount);
        console.log("transfer realizada com sucesso");
        vm.stopPrank();

        /// 🔹 Verifica saldo final
        uint256 user1Balance = abTokenInstance.balanceOf(user1);
        console.log("Saldo final do user1 apos a transfer:", user1Balance);
        assertEq(
            user1Balance,
            mintAmount - transferAmount,
            "Transfer falhou apos despausar"
        );
    }

    // solhint-disable-next-line 
    function testComplianceCheck() public {
        address user1;
        address user2;
        (user1, ) = makeAddrAndKey("user1");
        (user2, ) = makeAddrAndKey("user2");

        uint256 mintAmount = 1000 * 10 ** 18;
        uint256 transferAmount = 500 * 10 ** 18;

        vm.startPrank(owner);

        /// 🔹 Antes de tentar mintar, precisamos registrar a identidade do usuário!
        identityRegistry.registerIdentity(
            user1,
            IIdentity(address(onchainID)), // Simula uma identidade válida
            1 // Código do país
        );

        /// 🔹 Agora podemos mintar corretamente
        abTokenInstance.mint(user1, mintAmount);

        /// 🔹 O contrato começa pausado, então a transferência deve falhar
        vm.expectRevert("Pausable: paused");
        abTokenInstance.transfer(user2, transferAmount);

        /// 🔹 Agora registramos a identidade do user2 antes de permitir a transferência
        identityRegistry.registerIdentity(
            user2,
            IIdentity(address(onchainID)),
            1
        );

        /// 🔹 Despausamos o contrato antes da transferência
        abTokenInstance.unpause();
        vm.stopPrank();

        /// 🔹 Agora podemos transferir tokens normalmente
        vm.startPrank(user1);
        abTokenInstance.transfer(user2, transferAmount);
        vm.stopPrank();

        /// 🔹 Verificamos os saldos finais
        uint256 user1Balance = abTokenInstance.balanceOf(user1);
        uint256 user2Balance = abTokenInstance.balanceOf(user2);
        console.log("User1 Balance after transfer:", user1Balance);
        console.log("User2 Balance after transfer:", user2Balance);

        assertEq(
            user1Balance,
            mintAmount - transferAmount,
            "Compliance failed: transfer should be allowed after verification"
        );
        assertEq(
            user2Balance,
            transferAmount,
            "Compliance failed: receiver did not get the tokens"
        );
    }

     /// @dev Teste de deployment
     function testDeployment() public view {
        string memory tokenName = abTokenInstance.name();
        console.log("Token Name:", tokenName);
        assertEq(tokenName, "TestABToken", "Nome do abTokenInstance incorreto");
    }
}
