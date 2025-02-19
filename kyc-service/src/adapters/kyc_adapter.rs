use crate::application::kyc_service::KYCService;
use crate::domain::kyc_model::{KYCEntry, NewKYCEntry};
use crate::infrastructure::database::connection::DbPool;
use crate::infrastructure::database::schema::kyc_entries;
use async_trait::async_trait;
use diesel::prelude::*;
use regex::Regex;
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

    /// 🔹 Função auxiliar para validar e-mail
    fn is_valid_email(email: &str) -> bool {
        let email_regex = Regex::new(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
            .expect("Regex inválido");
        email_regex.is_match(email)
    }
}

#[async_trait]
impl KYCService for KYCAdapter {
    /// 🔹 Criar um novo KYC com validação
    async fn create_kyc_entry(&self, entry: NewKYCEntry) -> Result<KYCEntry, String> {
        if !Self::is_valid_email(&entry.user_email) {
            return Err(
                "E-mail inválido. Use um formato válido (exemplo@dominio.com).".to_string(),
            );
        }
        if entry.identity_hash.is_empty() || entry.status.is_empty() {
            return Err("Os campos identity_hash e status não podem estar vazios.".to_string());
        }

        let db_pool = Arc::clone(&self.db_pool);
        let entry_clone = entry.clone();

        info!("Criando novo KYC para usuário: {}", entry_clone.user_email);

        let result = task::spawn_blocking(move || {
            let mut conn = db_pool
                .get()
                .map_err(|e| format!("Erro ao obter conexão: {}", e))?;

            // 🔹 Verifica se o e-mail já existe antes de criar
            let exists: bool = diesel::select(diesel::dsl::exists(
                kyc_entries::table.filter(kyc_entries::user_email.eq(&entry_clone.user_email)),
            ))
            .get_result(&mut conn)
            .map_err(|e| format!("Erro ao verificar duplicidade: {}", e))?;

            if exists {
                return Err("E-mail já cadastrado no sistema.".to_string());
            }

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

    /// 🔹 Buscar um KYC por e-mail com validação
    async fn get_kyc_by_email(&self, email: String) -> Result<Option<KYCEntry>, String> {
        if !Self::is_valid_email(&email) {
            return Err(
                "E-mail inválido. Use um formato válido (exemplo@dominio.com).".to_string(),
            );
        }

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

    /// 🔹 Atualizar um KYC com validação
    async fn update_kyc_status(&self, email: String, status: String) -> Result<KYCEntry, String> {
        if !Self::is_valid_email(&email) {
            return Err(
                "E-mail inválido. Use um formato válido (exemplo@dominio.com).".to_string(),
            );
        }
        if status.is_empty() {
            return Err("O status não pode estar vazio.".to_string());
        }

        let db_pool = Arc::clone(&self.db_pool);
        info!(
            "Atualizando status de KYC para email: {} -> {}",
            email, status
        );

        let result = task::spawn_blocking(move || {
            let mut conn = db_pool
                .get()
                .map_err(|e| format!("Erro ao obter conexão: {}", e))?;

            let updated_kyc = diesel::update(
                kyc_entries::table.filter(kyc_entries::user_email.eq(email.clone())),
            )
            .set(kyc_entries::status.eq(status))
            .get_result::<KYCEntry>(&mut conn)
            .map_err(|e| format!("Erro ao atualizar KYC: {}", e))?;

            Ok(updated_kyc)
        })
        .await
        .map_err(|e| format!("Erro assíncrono: {}", e))?;

        match &result {
            Ok(kyc) => info!("KYC atualizado com sucesso: {:?}", kyc),
            Err(e) => error!("Erro ao atualizar KYC: {}", e),
        }

        result
    }

    /// 🔹 Deletar um KYC com validação
    async fn delete_kyc_by_email(&self, email: String) -> Result<(), String> {
        if !Self::is_valid_email(&email) {
            return Err(
                "E-mail inválido. Use um formato válido (exemplo@dominio.com).".to_string(),
            );
        }

        info!("Deletando KYC para email: {}", email);
        let db_pool = Arc::clone(&self.db_pool);

        let result = task::spawn_blocking(move || {
            let mut conn = db_pool
                .get()
                .map_err(|e| format!("Erro ao obter conexão: {}", e))?;

            let deleted_rows =
                diesel::delete(kyc_entries::table.filter(kyc_entries::user_email.eq(email)))
                    .execute(&mut conn)
                    .map_err(|e| format!("Erro ao excluir KYC: {}", e))?;

            if deleted_rows == 0 {
                Err("Nenhum registro encontrado para deletar.".to_string())
            } else {
                Ok(())
            }
        })
        .await
        .map_err(|e| format!("Erro assíncrono: {}", e))?;

        match &result {
            Ok(_) => info!("KYC deletado com sucesso."),
            Err(e) => error!("Erro ao deletar KYC: {}", e),
        }

        result
    }
}
