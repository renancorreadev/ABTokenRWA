use diesel::r2d2::{ConnectionManager, Pool, PooledConnection};
use diesel::PgConnection;
use dotenv::dotenv;
use std::env;

/// Tipo para conexão pool de banco de dados.
pub type DbPool = Pool<ConnectionManager<PgConnection>>;

/// Inicializa a conexão com o banco de dados e retorna um Pool.
pub fn init_db() -> Result<DbPool, String> {
    dotenv().ok();

    let database_url =
        env::var("DATABASE_URL").map_err(|_| "DATABASE_URL não definida".to_string())?;
    let manager = ConnectionManager::<PgConnection>::new(database_url);

    Pool::builder()
        .build(manager)
        .map_err(|e| format!("Erro ao conectar no banco: {:?}", e))
}

/// Obtém uma conexão do pool.
pub fn get_connection(
    pool: &DbPool,
) -> Result<PooledConnection<ConnectionManager<PgConnection>>, String> {
    pool.get()
        .map_err(|e| format!("Erro ao obter conexão: {:?}", e))
}
