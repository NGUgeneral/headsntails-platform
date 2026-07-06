CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS public.jwt_auth_sessions (
    id uuid not null default gen_random_uuid(),
    token_hash character varying(64) not null,
    created_at timestamp with time zone null default now(),
    expires_at timestamp with time zone not null,
    audience character varying(255) not null,
    constraint jwt_auth_sessions_pkey primary key (id),
    constraint jwt_auth_sessions_token_hash_key unique (token_hash)
);

CREATE INDEX IF NOT EXISTS idx_auth_sessions_hash 
ON public.jwt_auth_sessions using btree (token_hash);

CREATE TABLE IF NOT EXISTS public.feature_flags (
    service VARCHAR(100) NOT NULL,
    key VARCHAR(100) NOT NULL,
    value BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    CONSTRAINT feature_flags_pkey PRIMARY KEY (service, key)
);

CREATE INDEX IF NOT EXISTS idx_feature_flags_service 
ON public.feature_flags (service);