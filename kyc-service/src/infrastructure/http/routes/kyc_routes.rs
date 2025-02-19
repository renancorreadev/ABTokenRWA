use crate::application::kyc_service::KYCService;
use crate::domain::kyc_model::NewKYCEntry;
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

    // Rota para criar um novo KYC
    let create_kyc = warp::post()
        .and(warp::path("kyc"))
        .and(warp::body::json())
        .and(kyc_service.clone())
        .and_then(handle_create_kyc);

    // Rota para obter KYC pelo email
    let get_kyc = warp::get()
        .and(warp::path!("kyc" / String))
        .and(kyc_service.clone())
        .and_then(handle_get_kyc);

    // Rota para atualizar o status do KYC
    let update_kyc = warp::put()
        .and(warp::path!("kyc" / String / String))
        .and(kyc_service.clone())
        .and_then(handle_update_kyc);

    create_kyc.or(get_kyc).or(update_kyc)
}

/// Handler para criar um novo KYC
async fn handle_create_kyc(
    entry: NewKYCEntry,
    service: Arc<dyn KYCService + Send + Sync>,
) -> Result<impl Reply, Rejection> {
    match service.create_kyc_entry(entry).await {
        Ok(created) => Ok(warp::reply::with_status(
            warp::reply::json(&created),
            StatusCode::CREATED,
        )),
        Err(e) => Ok(warp::reply::with_status(
            warp::reply::json(&json!({"error": e})),
            StatusCode::INTERNAL_SERVER_ERROR,
        )),
    }
}

/// Handler para buscar KYC por email
async fn handle_get_kyc(
    email: String,
    service: Arc<dyn KYCService + Send + Sync>,
) -> Result<impl Reply, Rejection> {
    match service.get_kyc_by_email(email).await {
        Ok(Some(kyc)) => Ok(warp::reply::with_status(
            warp::reply::json(&kyc),
            StatusCode::OK,
        )),
        Ok(None) => Ok(warp::reply::with_status(
            warp::reply::json(&json!({"error": "Not found"})),
            StatusCode::NOT_FOUND,
        )),
        Err(e) => Ok(warp::reply::with_status(
            warp::reply::json(&json!({"error": e})),
            StatusCode::INTERNAL_SERVER_ERROR,
        )),
    }
}

/// Handler para atualizar status do KYC
async fn handle_update_kyc(
    email: String,
    status: String,
    service: Arc<dyn KYCService + Send + Sync>,
) -> Result<impl Reply, Rejection> {
    match service.update_kyc_status(email, status).await {
        Ok(updated) => Ok(warp::reply::with_status(
            warp::reply::json(&updated),
            StatusCode::OK,
        )),
        Err(e) => Ok(warp::reply::with_status(
            warp::reply::json(&json!({"error": e})),
            StatusCode::INTERNAL_SERVER_ERROR,
        )),
    }
}
