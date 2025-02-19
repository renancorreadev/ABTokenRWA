use crate::schema::kyc_entries;
use diesel::{Insertable, Queryable};
use serde::{Deserialize, Serialize};

#[derive(Queryable, Serialize)]
pub struct KYCEntry {
    pub id: i32,
    pub user_email: String,
    pub identity_hash: String,
    pub status: String,
    pub created_at: chrono::NaiveDateTime,
    pub updated_at: chrono::NaiveDateTime,
}

#[derive(Insertable, Deserialize)]
#[table_name = "kyc_entries"]
pub struct NewKYCEntry {
    pub user_email: String,
    pub identity_hash: String,
    pub status: String,
}
