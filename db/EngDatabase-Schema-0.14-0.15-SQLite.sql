-- Convert schema 'db/LinWin-Schema-0.14-SQLite.sql' to 'db/LinWin-Schema-0.15-SQLite.sql':;

BEGIN;

ALTER TABLE PP_GROUP_MEMBERSHIPS ADD COLUMN PRIMARY_GROUP integer NOT NULL;

ALTER TABLE PP_GROUP_MEMBERSHIPS ADD COLUMN AFFILIATION_GROUP integer NOT NULL;


COMMIT;

