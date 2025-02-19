use crate::infrastructure::database::schema::kyc_entries;
use chrono::NaiveDateTime;
use diesel::prelude::*;

/// Representa um registro de KYC no banco de dados.
#[derive(Queryable, Identifiable, Debug)]
#[table_name = "kyc_entries"]
pub struct KYCEntry {
    pub id: i32,
    pub user_email: String,
    pub identity_hash: String,
    pub status: String,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}

/// Modelo para inserir um novo KYCEntry.
#[derive(Insertable)]
#[table_name = "kyc_entries"]
pub struct NewKYCEntry {
    pub user_email: String,
    pub identity_hash: String,
    pub status: String,
}
