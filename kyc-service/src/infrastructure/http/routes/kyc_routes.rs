use crate::application::kyc_service::KYCService;
use crate::domain::kyc_model::NewKYCEntry;
use log::{error, info, warn};
use serde_json::json;
use std::sync::Arc;
use warp::{http::StatusCode, Filter, Rejection, Reply};

/// Define as rotas para o serviço KYC
///
/// - `POST /kyc`: Criar entrada KYC
/// - `GET /kyc/{email}`: Buscar entrada KYC por email
/// - `PUT /kyc/{email}/{status}`: Atualizar status de um KYC
pub fn kyc_routes(
    kyc_service: Arc<dyn KYCService + Send + Sync>,
) -> impl Filter<Extract = impl Reply, Error = Rejection> + Clone {
    let kyc_service = warp::any().map(move || Arc::clone(&kyc_service));

    let create_kyc = warp::post()
        .and(warp::path("kyc"))
        .and(warp::body::json())
        .and(kyc_service.clone())
        .and_then(handle_create_kyc);

    let get_kyc = warp::get()
        .and(warp::path!("kyc" / String))
        .and(kyc_service.clone())
        .and_then(handle_get_kyc);

    let update_kyc = warp::put()
        .and(warp::path!("kyc" / String / String))
        .and(kyc_service.clone())
        .and_then(handle_update_kyc);

    // Rota para deletar KYC pelo email
    let delete_kyc = warp::delete()
        .and(warp::path!("kyc" / String))
        .and(kyc_service.clone())
        .and_then(handle_delete_kyc);

    create_kyc.or(get_kyc).or(update_kyc).or(delete_kyc)
}

/// Handler para criar um novo KYC com validações aprimoradas e logs
async fn handle_create_kyc(
    entry: NewKYCEntry,
    service: Arc<dyn KYCService + Send + Sync>,
) -> Result<impl Reply, Rejection> {
    // Validações antes da criação
    if entry.user_email.trim().is_empty() || entry.identity_hash.trim().is_empty() {
        warn!("Tentativa de criação de KYC com campos vazios");
        return Ok(warp::reply::with_status(
            warp::reply::json(&json!({"error": "Email e hash de identidade são obrigatórios"})),
            StatusCode::BAD_REQUEST,
        ));
    }

    info!("Criando novo KYC para: {}", entry.user_email);

    match service.create_kyc_entry(entry).await {
        Ok(created) => {
            info!("KYC criado com sucesso para: {}", created.user_email);
            Ok(warp::reply::with_status(
                warp::reply::json(&created),
                StatusCode::CREATED,
            ))
        }
        Err(e) => {
            error!("Erro ao criar KYC: {}", e);
            Ok(warp::reply::with_status(
                warp::reply::json(&json!({"error": "Erro interno ao processar a requisição"})),
                StatusCode::INTERNAL_SERVER_ERROR,
            ))
        }
    }
}

/// Handler para buscar KYC por email com logs estruturados
async fn handle_get_kyc(
    email: String,
    service: Arc<dyn KYCService + Send + Sync>,
) -> Result<impl Reply, Rejection> {
    if email.trim().is_empty() {
        warn!("Tentativa de busca de KYC com email vazio");
        return Ok(warp::reply::with_status(
            warp::reply::json(&json!({"error": "Email não pode ser vazio"})),
            StatusCode::BAD_REQUEST,
        ));
    }

    info!("Buscando KYC para: {}", email);

    match service.get_kyc_by_email(email.clone()).await {
        Ok(Some(kyc)) => {
            info!("KYC encontrado para: {}", email);
            Ok(warp::reply::with_status(
                warp::reply::json(&kyc),
                StatusCode::OK,
            ))
        }
        Ok(None) => {
            warn!("Nenhum KYC encontrado para: {}", email);
            Ok(warp::reply::with_status(
                warp::reply::json(&json!({"error": "KYC não encontrado"})),
                StatusCode::NOT_FOUND,
            ))
        }
        Err(e) => {
            error!("Erro ao buscar KYC para {}: {}", email, e);
            Ok(warp::reply::with_status(
                warp::reply::json(&json!({"error": "Erro interno ao buscar KYC"})),
                StatusCode::INTERNAL_SERVER_ERROR,
            ))
        }
    }
}

/// Handler para atualizar status do KYC com logs detalhados
async fn handle_update_kyc(
    email: String,
    status: String,
    service: Arc<dyn KYCService + Send + Sync>,
) -> Result<impl Reply, Rejection> {
    if email.trim().is_empty() {
        warn!("Tentativa de atualização de KYC com email vazio");
        return Ok(warp::reply::with_status(
            warp::reply::json(&json!({"error": "Email não pode ser vazio"})),
            StatusCode::BAD_REQUEST,
        ));
    }

    if status.trim().is_empty() {
        warn!("Tentativa de atualização de KYC sem status informado");
        return Ok(warp::reply::with_status(
            warp::reply::json(&json!({"error": "Status não pode ser vazio"})),
            StatusCode::BAD_REQUEST,
        ));
    }

    info!("Atualizando status do KYC para: {} -> {}", email, status);

    match service
        .update_kyc_status(email.clone(), status.clone())
        .await
    {
        Ok(updated) => {
            info!(
                "Status do KYC atualizado com sucesso para {} -> {}",
                email, status
            );
            Ok(warp::reply::with_status(
                warp::reply::json(&updated),
                StatusCode::OK,
            ))
        }
        Err(e) => {
            error!("Erro ao atualizar status do KYC para {}: {}", email, e);
            Ok(warp::reply::with_status(
                warp::reply::json(&json!({"error": "Erro interno ao atualizar status do KYC"})),
                StatusCode::INTERNAL_SERVER_ERROR,
            ))
        }
    }
}

/// Handler para deletar um KYC pelo email
async fn handle_delete_kyc(
    email: String,
    service: Arc<dyn KYCService + Send + Sync>,
) -> Result<impl Reply, Rejection> {
    match service.delete_kyc_by_email(email).await {
        Ok(_) => Ok(warp::reply::with_status(
            warp::reply::json(&json!({"message": "KYC deletado com sucesso"})),
            StatusCode::OK,
        )),
        Err(e) => Ok(warp::reply::with_status(
            warp::reply::json(&json!({"error": e})),
            StatusCode::INTERNAL_SERVER_ERROR,
        )),
    }
}
