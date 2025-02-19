
### KYC Service

#### Configuración

Postgreesql 

```bash
docker run --name kyc-postgres -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=admin -e POSTGRES_DB=kyc_db -p 5432:5432 -d postgres

```
ENV

DATABASE_URL=postgres://admin:admin@localhost:5432/kyc_db
JWT_SECRET=supersecreto


## instalar cli do diesel

```bash
cargo install diesel_cli --no-default-features --features postgres

```

## Diesel setup

```bash
diesel setup
```


## Generar modelos

```bash
diesel migration generate create_kyc_entries

```

## T arquivos (up.sql e down.sql). Edite o up.sql para definir a estrutura da tabela:

no up.sql
```bash
CREATE TABLE kyc_entries (
    id SERIAL PRIMARY KEY,
    user_email TEXT NOT NULL UNIQUE,
    identity_hash TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

```
no down.sql

```bash
DROP TABLE kyc_entries;
```

## Ejecutar migraciones

```bash
diesel migration run
```





# Arquitetura do projeto: 

📁  adapters: Deve conter adaptadores que fazem a interface entre a aplicação e o mundo externo (ex.: HTTP, banco de dados, filas de mensagens).
📁 application: Deve conter a lógica de negócios, incluindo kyc_service.rs.
📁 domain: Deve conter entidades e regras de negócio.
📁 infrastructure: Deve conter implementações concretas, como kyc_service_impl.rs.