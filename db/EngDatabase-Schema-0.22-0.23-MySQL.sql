-- Convert schema 'db/EngDatabase-Schema-0.22-MySQL.sql' to 'EngDatabase::Schema v0.23':;

BEGIN;

ALTER TABLE PP_ATTRIBUTES CHANGE COLUMN ATTRIBUTE_NAME ATTRIBUTE_NAME varchar(100) NOT NULL;

ALTER TABLE PP_GROUPS CHANGE COLUMN GROUP_NAME GROUP_NAME varchar(50) NULL,
                      CHANGE COLUMN GROUP_DESC GROUP_DESC varchar(100) NULL;

ALTER TABLE PP_GROUP_MEMBERSHIPS DROP INDEX affiliationgroup,
                                 DROP INDEX both,
                                 DROP INDEX primarygroup,
                                 CHANGE COLUMN PRIMARY_GROUP PRIMARY_GROUP integer(1) NULL,
                                 CHANGE COLUMN AFFILIATION_GROUP AFFILIATION_GROUP integer(1) NULL,
                                 ADD UNIQUE affiliationgroup (AFFILIATION_GROUP),
                                 ADD UNIQUE both (PRIMARY_GROUP, AFFILIATION_GROUP),
                                 ADD UNIQUE primarygroup (PRIMARY_GROUP);

ALTER TABLE PP_STATUSES CHANGE COLUMN STATUS_NAME STATUS_NAME varchar(100) NULL;

ALTER TABLE PP_USERS CHANGE COLUMN CRSID CRSID varchar(10) NOT NULL,
                     CHANGE COLUMN ENGID ENGID text NULL,
                     CHANGE COLUMN GECOS GECOS varchar(100) NULL,
                     CHANGE COLUMN HOMEDIR HOMEDIR varchar(100) NULL,
                     CHANGE COLUMN PASSWORD_EXPIRY_DATE PASSWORD_EXPIRY_DATE varchar(100) NULL,
                     CHANGE COLUMN PROPAGATION PROPAGATION varchar(100) NULL;

ALTER TABLE PP_USER_ATTRIBUTES CHANGE COLUMN ATTRIBUTE_VALUE ATTRIBUTE_VALUE varchar(100) NULL;


COMMIT;

