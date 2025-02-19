use crate::infrastructure::database::schema::kyc_entries;
use chrono::NaiveDateTime;
use diesel::prelude::*;
use serde::{Deserialize, Serialize}; // ADICIONE ESTA LINHA

/// Representa um registro de KYC no banco de dados.
#[derive(Debug, Clone, Serialize, Deserialize, Queryable, Identifiable)]
#[diesel(table_name = kyc_entries)]
pub struct KYCEntry {
    pub id: i32,
    pub user_email: String,
    pub identity_hash: String,
    pub status: String,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}

/// Modelo para inserir um novo KYCEntry.
#[derive(Debug, Clone, Serialize, Deserialize, Insertable)]
#[diesel(table_name = kyc_entries)]
pub struct NewKYCEntry {
    pub user_email: String,
    pub identity_hash: String,
    pub status: String,
}
