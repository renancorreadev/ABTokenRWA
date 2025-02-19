// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {console} from "forge-std/console.sol";
import {Test} from "forge-std/Test.sol";

import {ABToken} from "../src/ABToken.sol";
import {RWAComplianceModule} from "../src/compliances/RWACompliance.sol";

import {MockIdentityRegistry} from "./mocks/IdentityRegistryMock.sol";
import {MockModularCompliance} from "./mocks/ModularComplianceMock.sol";
import {MockIdentityOnChainID} from "./mocks/IdentityOnChainIDMock.sol";
import {TrustedIssuersRegistryMock} from "./mocks/utils/TrustedIssuersRegistryMock.sol";
import {ClaimTopicsRegistryMock} from "./mocks/utils/ClaimTopicsRegistryMock.sol";
import {IdentityRegistryStorageMock} from "./mocks/utils/IdentityRegistryStorageMock.sol";

import {IIdentity} from "@onchain-id/solidity/contracts/interface/IIdentity.sol";

import {NotApprovedBuyer} from "../src/compliances/RWAComplianceErrors.sol";

contract ERC3643IntegrationTest is Test {
    address public owner;
    uint256 private _ownerPrivateKey;

    /// @dev Instâncias de contrato
    ABToken public abToken;
    RWAComplianceModule public rwaCompliance;
    MockIdentityRegistry public identityRegistry;
    MockModularCompliance public compliance;
    MockIdentityOnChainID public onchainID;

    // Mocks setups utils from  identityRegistry
    ClaimTopicsRegistryMock public claimTopicsRegistry;
    IdentityRegistryStorageMock public identityRegistryStorage;
    TrustedIssuersRegistryMock public trustedIssuersRegistry;

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
        rwaCompliance = new RWAComplianceModule();

        /// ----------------- Deploy do contrato -----------------
        abToken = new ABToken();
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
        compliance.init();
        rwaCompliance.init(5000 ether);

        abToken.init(
            address(identityRegistry),
            address(compliance),
            "TestABToken",
            "TTK",
            18,
            address(onchainID)
        );

        /// 🔹 Associa o módulo de compliance ao contrato de compliance mock
        compliance.addModule(address(rwaCompliance));
        rwaCompliance.transferOwnership(owner);

        /// 🔹 Adiciona o owner como agente supervisionador
        identityRegistryStorage.addAgent(owner);
        identityRegistryStorage.addAgent(address(identityRegistry));
        identityRegistry.addAgent(owner);
        abToken.addAgent(owner);
        vm.stopPrank();
    }

  

    /// ✅ Testa Mint + Compliance
    // solhint-disable-next-line 
    function testMintAndTransferWithCompliance() public {
        address user1;
        address user2;
        (user1, ) = makeAddrAndKey("user1");
        (user2, ) = makeAddrAndKey("user2");

        uint256 mintAmount = 1000 ether;
        uint256 transferAmount = 500 ether;

        vm.startPrank(owner);

        /// 🔹 Registra identidade dos usuários
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

        /// 🔹 Aprova os usuários no compliance
        rwaCompliance.approveBuyer(
            user1,
            true,
            true,
            true,
            10000 ether, // ✅ Renda suficiente
            "Valid Address",
            true,
            true
        );

        rwaCompliance.approveBuyer(
            user2,
            true,
            true,
            true,
            10000 ether, // ✅ Renda suficiente
            "Valid Address",
            true,
            true
        );

        /// 🔹 Mint para user1
        abToken.mint(user1, mintAmount);

        vm.stopPrank();

        /// 🔹 Despausa o token antes da transferência
        vm.startPrank(owner);
        abToken.unpause();
        vm.stopPrank();

        /// 🔹 Usuário 1 transfere tokens para Usuário 2
        vm.startPrank(user1);
        abToken.transfer(user2, transferAmount);
        vm.stopPrank();

        /// 🔹 Verifica os saldos finais
        uint256 user1Balance = abToken.balanceOf(user1);
        uint256 user2Balance = abToken.balanceOf(user2);
        console.log("User1 Balance after transfer:", user1Balance);
        console.log("User2 Balance after transfer:", user2Balance);

        assertEq(
            user1Balance,
            mintAmount - transferAmount,
            "Transferencia falhou: saldo incorreto no remetente"
        );
        assertEq(
            user2Balance,
            transferAmount,
            "Transferencia falhou: saldo incorreto no destinatario"
        );
    }

    /// ✅ Testa que um usuário não aprovado **NÃO** pode transferir
    // solhint-disable-next-line 
    function testTransferFailsForNonApprovedUser() public {
        address user1;
        address user2;
        (user1, ) = makeAddrAndKey("user1");
        (user2, ) = makeAddrAndKey("user2");

        uint256 mintAmount = 1000 ether;
        uint256 transferAmount = 500 ether;

        vm.startPrank(owner);

        /// 🔹 Registra identidade dos usuários
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

        /// 🔹 Apenas user1 é aprovado, user2 não
        rwaCompliance.approveBuyer(
            user1,
            true,
            true,
            true,
            10000 ether,
            "Valid Address",
            true,
            true
        );

        /// 🔹 Mint para user1
        abToken.mint(user1, mintAmount);

        vm.stopPrank();

        /// 🔹 Despausa o token
        vm.startPrank(owner);
        abToken.unpause();
        vm.stopPrank();

        /// 🔹 Espera-se um revert ao transferir para user2
        vm.startPrank(user1);
        vm.expectRevert(
            abi.encodeWithSelector(NotApprovedBuyer.selector, user2)
        );
        abToken.transfer(user2, transferAmount);
        vm.stopPrank();
    }

    /// ✅ Testa se remover o compliance **desbloqueia** transações
    // solhint-disable-next-line 
    function testTransferAfterComplianceRemoved() public {
        address user1;
        address user2;
        (user1, ) = makeAddrAndKey("user1");
        (user2, ) = makeAddrAndKey("user2");

        uint256 mintAmount = 1000 ether;
        uint256 transferAmount = 500 ether;

        vm.startPrank(owner);

        /// 🔹 Registra identidade dos usuários
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

        /// 🔹 Aprova os usuários no compliance
        rwaCompliance.approveBuyer(
            user1,
            true,
            true,
            true,
            10000 ether,
            "Valid Address",
            true,
            true
        );

        rwaCompliance.approveBuyer(
            user2,
            true,
            true,
            true,
            10000 ether,
            "Valid Address",
            true,
            true
        );

        /// 🔹 Mint para user1
        abToken.mint(user1, mintAmount);

        vm.stopPrank();

        /// 🔹 Remove o compliance
        vm.startPrank(owner);
        compliance.removeModule(address(rwaCompliance));

        /// 🔹 Despausa o token após remover o compliance
        abToken.unpause();
        vm.stopPrank();

        /// 🔹 Agora a transferência deve passar
        vm.startPrank(user1);
        abToken.transfer(user2, transferAmount);
        vm.stopPrank();

        uint256 user1Balance = abToken.balanceOf(user1);
        uint256 user2Balance = abToken.balanceOf(user2);

        assertEq(user1Balance, mintAmount - transferAmount);
        assertEq(user2Balance, transferAmount);
    }

      /// ✅ Teste de Deployment
    function testDeployment() public view {
        string memory tokenName = abToken.name();
        console.log("Token Name:", tokenName);
        assertEq(tokenName, "TestABToken", "Nome do token incorreto");

        bool isBound = rwaCompliance.isComplianceBound(address(compliance));
        assertTrue(isBound, "O modulo de compliance nao esta vinculado");
    }
}
