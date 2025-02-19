use crate::application::kyc_service::KYCService;
use crate::domain::kyc_model::{KYCEntry, NewKYCEntry};
use crate::infrastructure::database::connection::DbPool;
use crate::infrastructure::database::schema::kyc_entries;
use async_trait::async_trait;
use diesel::prelude::*;
use std::sync::Arc;
use tokio::task;

/// Implementação do serviço de KYC (Know Your Customer)
///
/// Esta estrutura fornece as implementações concretas dos métodos do serviço KYC:
/// - Criar entrada KYC
/// - Buscar KYC por e-mail
/// - Atualizar status de um KYC
pub struct KYCServiceImpl {
    /// Pool de conexão com o banco de dados
    pub db_pool: Arc<DbPool>,
}

impl KYCServiceImpl {
    /// Cria uma nova instância do serviço `KYCServiceImpl`
    pub fn new(db_pool: Arc<DbPool>) -> Self {
        Self { db_pool }
    }
}

#[async_trait]
impl KYCService for KYCServiceImpl {
    /// Insere um novo registro de KYC no banco de dados
    async fn create_kyc_entry(&self, entry: NewKYCEntry) -> Result<KYCEntry, String> {
        let db_pool = Arc::clone(&self.db_pool); // Usa Arc::clone para evitar ownership issues

        task::spawn_blocking(move || {
            let mut conn = db_pool
                .get()
                .map_err(|e| format!("Erro ao obter conexão: {}", e))?;

            diesel::insert_into(kyc_entries::table)
                .values(&entry)
                .get_result::<KYCEntry>(&mut conn)
                .map_err(|e| format!("Erro ao inserir KYC: {}", e))
        })
        .await
        .map_err(|e| format!("Erro na execução assíncrona: {}", e))?
    }

    /// Busca um registro de KYC pelo e-mail
    async fn get_kyc_by_email(&self, email: String) -> Result<Option<KYCEntry>, String> {
        let db_pool = Arc::clone(&self.db_pool);

        task::spawn_blocking(move || {
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
        .map_err(|e| format!("Erro na execução assíncrona: {}", e))?
    }

    /// Atualiza o status de um registro de KYC pelo e-mail
    async fn update_kyc_status(
        &self,
        email: String,
        new_status: String,
    ) -> Result<KYCEntry, String> {
        let db_pool = Arc::clone(&self.db_pool);

        task::spawn_blocking(move || {
            let mut conn = db_pool
                .get()
                .map_err(|e| format!("Erro ao obter conexão: {}", e))?;

            diesel::update(kyc_entries::table.filter(kyc_entries::user_email.eq(email)))
                .set(kyc_entries::status.eq(new_status))
                .get_result::<KYCEntry>(&mut conn)
                .map_err(|e| format!("Erro ao atualizar KYC: {}", e))
        })
        .await
        .map_err(|e| format!("Erro na execução assíncrona: {}", e))?
    }
}
