CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS leads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    business_name TEXT NOT NULL,
    industry TEXT NOT NULL,
    city TEXT NOT NULL,

    website TEXT,
    contact TEXT,
    whatsapp_evidence TEXT,

    source TEXT NOT NULL,

    status TEXT NOT NULL
        CHECK (status IN ('verified', 'partial', 'unverified')),

    verification_score INTEGER
        CHECK (verification_score >= 0 AND verification_score <= 100),

    verification_notes TEXT[] NOT NULL DEFAULT '{}',
    missing_fields TEXT[] NOT NULL DEFAULT '{}',

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Prevent the same business from being inserted twice
CREATE UNIQUE INDEX IF NOT EXISTS leads_business_city_unique
ON leads (LOWER(business_name), LOWER(city));

-- Official website is the strongest deduplication key
CREATE UNIQUE INDEX IF NOT EXISTS leads_website_unique
ON leads (LOWER(website))
WHERE website IS NOT NULL;

-- Useful for fetching existing leads before a new search
CREATE INDEX IF NOT EXISTS leads_industry_city_idx
ON leads (LOWER(industry), LOWER(city));