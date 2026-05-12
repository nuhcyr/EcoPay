CREATE TABLE companies (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    email_domain VARCHAR(255) NOT NULL,
    invite_code VARCHAR(16) NOT NULL,
    owner_user_id BIGINT NOT NULL REFERENCES users (id),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE UNIQUE INDEX ux_companies_invite_code ON companies (invite_code);
CREATE UNIQUE INDEX ux_companies_email_domain ON companies (email_domain);

ALTER TABLE users
    ADD COLUMN company_id BIGINT REFERENCES companies (id);

CREATE INDEX ix_users_company_id ON users (company_id);
