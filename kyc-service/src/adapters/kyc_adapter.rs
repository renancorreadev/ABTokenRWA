use crate::application::kyc_service::KYCService;
use crate::domain::kyc_model::{KYCEntry, NewKYCEntry};
use crate::infrastructure::database::connection::DbPool;
use crate::infrastructure::database::schema::kyc_entries;
use async_trait::async_trait;
use diesel::prelude::*;
use std::sync::Arc;
use tokio::task;
use tracing::{error, info}; // Logging

/// Implementação concreta do serviço de KYC
pub struct KYCAdapter {
    pub db_pool: Arc<DbPool>,
}

impl KYCAdapter {
    pub fn new(db_pool: Arc<DbPool>) -> Self {
        Self { db_pool }
    }
}

#[async_trait]
impl KYCService for KYCAdapter {
    /// Insere um novo registro de KYC no banco de dados
    async fn create_kyc_entry(&self, entry: NewKYCEntry) -> Result<KYCEntry, String> {
        let db_pool = Arc::clone(&self.db_pool);
        let entry_clone = entry.clone(); // 🔹 Clone para evitar borrow após move

        info!("Criando novo KYC para usuário: {}", entry_clone.user_email);

        let result = task::spawn_blocking(move || {
            let mut conn = db_pool
                .get()
                .map_err(|e| format!("Erro ao obter conexão: {}", e))?;

            diesel::insert_into(kyc_entries::table)
                .values(entry_clone)
                .get_result::<KYCEntry>(&mut conn)
                .map_err(|e| format!("Erro ao inserir KYC: {}", e))
        })
        .await
        .map_err(|e| format!("Erro assíncrono: {}", e))?;

        match &result {
            Ok(kyc) => info!("KYC criado com sucesso: {:?}", kyc),
            Err(e) => error!("Erro ao criar KYC: {}", e),
        }

        result
    }

    /// Busca um registro de KYC pelo e-mail
    async fn get_kyc_by_email(&self, email: String) -> Result<Option<KYCEntry>, String> {
        let db_pool = Arc::clone(&self.db_pool);
        info!("Buscando KYC para email: {}", email);

        let result = task::spawn_blocking(move || {
            let mut conn = db_pool
                .get()
                .map_err(|e| format!("Erro ao obter conexão: {}", e))?;

            kyc_entries::table
                .filter(kyc_entries::user_email.eq(email))
                .first::<KYCEntry>(&mut conn)
                .optional()
                .map_err(|e| format!("Erro ao buscar KYC: {}", e))
        })
        .await
        .map_err(|e| format!("Erro assíncrono: {}", e))?;

        match &result {
            Ok(Some(kyc)) => info!("KYC encontrado: {:?}", kyc),
            Ok(None) => info!("Nenhum KYC encontrado"),
            Err(e) => error!("Erro ao buscar KYC: {}", e),
        }

        result
    }

    /// Atualiza o status de um KYC
    async fn update_kyc_status(&self, email: String, status: String) -> Result<KYCEntry, String> {
        let db_pool = Arc::clone(&self.db_pool);
        info!(
            "Atualizando status de KYC para email: {} -> {}",
            email, status
        );

        let result = task::spawn_blocking(move || {
            let mut conn = db_pool
                .get()
                .map_err(|e| format!("Erro ao obter conexão: {}", e))?;

            diesel::update(kyc_entries::table.filter(kyc_entries::user_email.eq(email)))
                .set(kyc_entries::status.eq(status))
                .get_result::<KYCEntry>(&mut conn)
                .map_err(|e| format!("Erro ao atualizar KYC: {}", e))
        })
        .await
        .map_err(|e| format!("Erro assíncrono: {}", e))?;

        match &result {
            Ok(kyc) => info!("KYC atualizado com sucesso: {:?}", kyc),
            Err(e) => error!("Erro ao atualizar KYC: {}", e),
        }

        result
    }

    async fn delete_kyc_by_email(&self, email: String) -> Result<(), String> {
        let db_pool = Arc::clone(&self.db_pool);

        task::spawn_blocking(move || {
            let mut conn = db_pool
                .get()
                .map_err(|e| format!("Erro ao obter conexão: {}", e))?;

            let deleted_rows =
                diesel::delete(kyc_entries::table.filter(kyc_entries::user_email.eq(email)))
                    .execute(&mut conn)
                    .map_err(|e| format!("Erro ao excluir KYC: {}", e))?;

            if deleted_rows == 0 {
                Err("Nenhum registro encontrado para deletar".to_string())
            } else {
                Ok(())
            }
        })
        .await
        .map_err(|e| format!("Erro na execução assíncrona: {}", e))?
    }
}
