// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {AbstractModule} from "@erc3643/contracts/compliance/modular/modules/AbstractModule.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/// 🔹 Custom Errors (para otimizar gas)
import {
    NotApprovedBuyer, 
    InvalidBuyerData, 
    NotBoundCompliance, 
    IncomeTooLow, 
    ComplianceCheckFailed, 
    ComplianceAlreadyBound, 
    UnauthorizedCaller
} from "./RWAComplianceErrors.sol";

contract RWAComplianceModule is AbstractModule, OwnableUpgradeable {
    struct BuyerInfo {
        bool creditInsuranceApproved;
        bool serasaClearance;
        bool documentsVerified;
        uint256 income;
        string addressVerified;
        bool saleRegistered;
        bool signedAgreement;
    }

    mapping(address => BuyerInfo) private _buyers;
    uint256 public minIncomeRequired;
    uint256 public immutable minTransactionValue = 1 ether;

    /// 🔹 Eventos para auditoria
    event BuyerApproved(address indexed buyer);
    event ComplianceCheckPassed(
        address indexed from,
        address indexed to,
        uint256 value
    );
    event ComplianceCheckFailedEvent(
        address indexed from,
        address indexed to,
        uint256 value,
        string reason
    );

    /// 🔹 Modifier para garantir que um comprador esteja cadastrado
    modifier onlyRegisteredBuyer(address buyer) {
        if (_buyers[buyer].income == 0) revert NotApprovedBuyer(buyer);
        _;
    }

    function init(uint256 _minIncomeRequired) external initializer {
        __Ownable_init();
        minIncomeRequired = _minIncomeRequired;
    }

    /// 🔹 Aprovação de comprador com verificação única
    function approveBuyer(
        address buyer,
        bool creditInsuranceApproved,
        bool serasaClearance,
        bool documentsVerified,
        uint256 income,
        string memory addressVerified,
        bool saleRegistered,
        bool signedAgreement
    ) external onlyOwner {
        if (income < minIncomeRequired)
            revert IncomeTooLow(buyer, minIncomeRequired, income);

        _buyers[buyer] = BuyerInfo({
            creditInsuranceApproved: creditInsuranceApproved,
            serasaClearance: serasaClearance,
            documentsVerified: documentsVerified,
            income: income,
            addressVerified: addressVerified,
            saleRegistered: saleRegistered,
            signedAgreement: signedAgreement
        });

        emit BuyerApproved(buyer);
    }

    /// @dev  verifica se uma transação entre duas partes cumpre os critérios de compliance antes que o token seja transferido.
    /// @notice Verifica se uma transação atende aos critérios de compliance
    /// @param from Endereço do remetente da transação
    /// @param to Endereço do destinatário da transação
    /// @param value Valor da transação em wei
    /// @param compliance Endereço do contrato de compliance vinculado
    /// @return bool Retorna true se a transação atende aos critérios, reverte caso contrário
    function moduleCheck(
        address from,
        address to,
        uint256 value,
        address compliance
    )
        external
        view
        override
        onlyBoundCompliance(compliance)
        onlyRegisteredBuyer(to)
        returns (bool)
    {
        BuyerInfo memory buyer = _buyers[to];

        unchecked {
            if (value < minTransactionValue) {
                revert ComplianceCheckFailed(
                    from,
                    to,
                    value,
                    "Transaction value too low"
                );
            }
        }

        return (buyer.creditInsuranceApproved &&
            buyer.serasaClearance &&
            buyer.documentsVerified &&
            buyer.income >= minIncomeRequired &&
            bytes(buyer.addressVerified).length > 0 &&
            buyer.saleRegistered &&
            buyer.signedAgreement);
    }

    /// 🔹 Verifica se um compliance pode ser vinculado
    function canComplianceBind(address) external pure override returns (bool) {
        return true;
    }

    /// 🔹 Nome do módulo
    function name() external pure override returns (string memory) {
        return "RWAVigentComplianceModule";
    }

    /// 🔹 Indica que é um módulo plug & play
    function isPlugAndPlay() external pure override returns (bool) {
        return true;
    }

    /// 🔹 Métodos obrigatórios da interface (não fazem nada neste módulo)
    // solhint-disable-next-line
    function moduleMintAction(address, uint256) external override {}

    // solhint-disable-next-line
    function moduleBurnAction(address, uint256) external override {}

    function moduleTransferAction(
        address,
        address,
        uint256
      // solhint-disable-next-line
    ) external override {}

}
