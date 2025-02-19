use crate::domain::kyc_model::{KYCEntry, NewKYCEntry};
use async_trait::async_trait;

#[async_trait]
/// KYCService trait defines the essential methods for managing KYC (Know Your Customer) entries
///
/// This trait provides the core functionality for:
/// - Creating new KYC entries
/// - Retrieving KYC entries by email
/// - Updating the status of existing KYC entries
///
/// All methods return a Result type to handle potential errors during operations.
pub trait KYCService {
    async fn create_kyc_entry(&self, entry: NewKYCEntry) -> Result<KYCEntry, String>;
    async fn get_kyc_by_email(&self, email: String) -> Result<Option<KYCEntry>, String>;
    async fn update_kyc_status(&self, email: String, status: String) -> Result<KYCEntry, String>;
}
