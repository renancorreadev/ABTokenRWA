use dotenv::dotenv;
use std::env;

/// Estrutura para armazenar configurações do sistema
#[derive(Debug, Clone)]
pub struct Config {
    pub database_url: String,
    pub server_port: u16,
}

impl Config {
    /// Carrega as variáveis de ambiente e retorna a configuração
    pub fn from_env() -> Result<Self, String> {
        dotenv().ok();

        let database_url =
            env::var("DATABASE_URL").map_err(|_| "DATABASE_URL não definida".to_string())?;
        let server_port = env::var("SERVER_PORT")
            .unwrap_or_else(|_| "8080".to_string())
            .parse::<u16>()
            .map_err(|_| "SERVER_PORT inválido".to_string())?;

        Ok(Self {
            database_url,
            server_port,
        })
    }
}
