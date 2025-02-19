use dotenv::dotenv;
use env_logger;
use std::sync::Arc;
use warp::Filter;

mod adapters;
mod application;
mod domain;
mod infrastructure;

use adapters::kyc_adapter::KYCAdapter;
use infrastructure::database::connection::init_db;
use infrastructure::http::routes::kyc_routes::kyc_routes;

#[tokio::main]
async fn main() {
    dotenv().ok();
    env_logger::init();

    // Inicializa o banco de dados
    let db_pool = match init_db() {
        Ok(pool) => Arc::new(pool),
        Err(e) => {
            eprintln!("❌ Erro ao inicializar o banco de dados: {:?}", e);
            return;
        }
    };

    // Instancia o serviço de KYC usando o Adapter
    let kyc_service = Arc::new(KYCAdapter::new(db_pool.clone()));

    // Configura as rotas
    let routes = kyc_routes(kyc_service).with(warp::log("kyc_service"));

    // Inicia o servidor
    println!("🚀 Servidor rodando em http://localhost:8080");
    warp::serve(routes).run(([127, 0, 0, 1], 8080)).await;
}
