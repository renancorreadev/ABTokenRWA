use crate::application::kyc_service::KYCService;
use crate::domain::kyc_model::{KYCEntry, NewKYCEntry};
use crate::infrastructure::database::connection::DbPool;
use crate::infrastructure::database::schema::kyc_entries;
use async_trait::async_trait;
use diesel::prelude::*;
use log::{error, info, warn};
use std::sync::Arc;
use tokio::task;

/// Implementação concreta do serviço de KYC
pub struct KYCAdapter {
    pub db_pool: Arc<DbPool>,
}

impl KYCAdapter {
    /// Cria uma nova instância do `KYCAdapter`
    pub fn new(db_pool: Arc<DbPool>) -> Self {
        Self { db_pool }
    }
}

#[async_trait]
impl KYCService for KYCAdapter {
    /// Insere um novo registro de KYC no banco de dados com validações e logs
    async fn create_kyc_entry(&self, entry: NewKYCEntry) -> Result<KYCEntry, String> {
        let db_pool = Arc::clone(&self.db_pool);

        // Validações antes de inserir
        if entry.user_email.trim().is_empty() || entry.identity_hash.trim().is_empty() {
            warn!("Tentativa de criação de KYC com campos vazios.");
            return Err("Email e hash de identidade são obrigatórios.".to_string());
        }

        info!("Criando novo KYC para: {}", entry.user_email);

        task::spawn_blocking(move || {
            let mut conn = db_pool
                .get()
                .map_err(|e| format!("Erro ao obter conexão: {}", e))?;

            diesel::insert_into(kyc_entries::table)
                .values(&entry)
                .get_result::<KYCEntry>(&mut conn)
                .map_err(|e| {
                    error!("Erro ao inserir KYC para {}: {}", entry.user_email, e);
                    format!("Erro ao inserir KYC: {}", e)
                })
        })
        .await
        .map_err(|e| format!("Erro assíncrono: {}", e))?
    }

    /// Busca um registro de KYC pelo e-mail com logs detalhados
    async fn get_kyc_by_email(&self, email: String) -> Result<Option<KYCEntry>, String> {
        let db_pool = Arc::clone(&self.db_pool);

        if email.trim().is_empty() {
            warn!("Tentativa de busca de KYC com email vazio.");
            return Err("Email não pode ser vazio.".to_string());
        }

        info!("Buscando KYC para: {}", email);

        task::spawn_blocking(move || {
            let mut conn = db_pool
                .get()
                .map_err(|e| format!("Erro ao obter conexão: {}", e))?;

            kyc_entries::table
                .filter(kyc_entries::user_email.eq(email.clone()))
                .first::<KYCEntry>(&mut conn)
                .optional()
                .map_err(|e| {
                    error!("Erro ao buscar KYC para {}: {}", email, e);
                    format!("Erro ao buscar KYC: {}", e)
                })
        })
        .await
        .map_err(|e| format!("Erro assíncrono: {}", e))?
    }

    /// Atualiza o status de um KYC pelo e-mail
    async fn update_kyc_status(&self, email: String, status: String) -> Result<KYCEntry, String> {
        let db_pool = Arc::clone(&self.db_pool);

        if email.trim().is_empty() {
            warn!("Tentativa de atualização de KYC com email vazio.");
            return Err("Email não pode ser vazio.".to_string());
        }

        if status.trim().is_empty() {
            warn!("Tentativa de atualização de KYC sem status informado.");
            return Err("Status não pode ser vazio.".to_string());
        }

        info!("Atualizando status do KYC para {} -> {}", email, status);

        task::spawn_blocking(move || {
            let mut conn = db_pool
                .get()
                .map_err(|e| format!("Erro ao obter conexão: {}", e))?;

            diesel::update(kyc_entries::table.filter(kyc_entries::user_email.eq(email.clone())))
                .set(kyc_entries::status.eq(status.clone()))
                .get_result::<KYCEntry>(&mut conn)
                .map_err(|e| {
                    error!("Erro ao atualizar status do KYC para {}: {}", email, e);
                    format!("Erro ao atualizar status: {}", e)
                })
        })
        .await
        .map_err(|e| format!("Erro assíncrono: {}", e))?
    }
}
