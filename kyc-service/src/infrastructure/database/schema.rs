diesel::table! {
    kyc_entries (id) {
        id -> Int4,
        user_email -> Text,
        identity_hash -> Text,
        status -> Text,
        created_at -> Timestamp,
        updated_at -> Timestamp,
    }
}
