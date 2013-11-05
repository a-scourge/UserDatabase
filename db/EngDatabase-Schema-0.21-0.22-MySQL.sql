-- Convert schema 'db/EngDatabase-Schema-0.21-MySQL.sql' to 'EngDatabase::Schema v0.22':;

BEGIN;

ALTER TABLE PP_ATTRIBUTES CHANGE COLUMN ATTRIBUTE_NAME ATTRIBUTE_NAME varchar(100) NOT NULL;

ALTER TABLE PP_GROUPS CHANGE COLUMN GROUP_NAME GROUP_NAME varchar(50) NULL,
                      CHANGE COLUMN GROUP_DESC GROUP_DESC varchar(100) NULL;

ALTER TABLE PP_GROUP_MEMBERSHIPS CHANGE COLUMN PRIMARY_GROUP PRIMARY_GROUP integer(1) NOT NULL,
                                 CHANGE COLUMN AFFILIATION_GROUP AFFILIATION_GROUP integer(1) NOT NULL;

ALTER TABLE PP_STATUSES CHANGE COLUMN STATUS_NAME STATUS_NAME varchar(100) NULL,
                        CHANGE COLUMN AD_PASSWORD AD_PASSWORD integer(1) NULL,
                        CHANGE COLUMN AUTOMOUNTER AUTOMOUNTER integer(1) NULL,
                        CHANGE COLUMN AD_ENABLED AD_ENABLED integer(1) NULL,
                        CHANGE COLUMN TRUST_ALLOWED TRUST_ALLOWED integer(1) NULL,
                        CHANGE COLUMN UNIX_PASSWD UNIX_PASSWD integer(1) NULL,
                        CHANGE COLUMN UNIX_ENABLED UNIX_ENABLED integer(1) NULL,
                        CHANGE COLUMN PROP_TEACH PROP_TEACH integer(1) NULL,
                        CHANGE COLUMN PROP_MAIL PROP_MAIL integer(1) NULL,
                        CHANGE COLUMN PROP_DIVA PROP_DIVA integer(1) NULL,
                        CHANGE COLUMN PROP_DIVB PROP_DIVB integer(1) NULL,
                        CHANGE COLUMN PROP_DIVF PROP_DIVF integer(1) NULL,
                        CHANGE COLUMN PROP_FLUID PROP_FLUID integer(1) NULL,
                        CHANGE COLUMN PROP_STRUCT PROP_STRUCT integer(1) NULL,
                        CHANGE COLUMN PROP_WHITTLE PROP_WHITTLE integer(1) NULL,
                        CHANGE COLUMN PROP_WORKS PROP_WORKS integer(1) NULL,
                        CHANGE COLUMN PROP_TEST PROP_TEST integer(1) NULL;

ALTER TABLE PP_USERS DROP INDEX PP_USERS_ENGID_CRSID_UID,
                     CHANGE COLUMN CRSID CRSID varchar(10) NOT NULL,
                     CHANGE COLUMN ENGID ENGID text NULL,
                     CHANGE COLUMN GECOS GECOS varchar(100) NULL,
                     CHANGE COLUMN HOMEDIR HOMEDIR varchar(100) NULL,
                     CHANGE COLUMN PASSWORD_EXPIRY_DATE PASSWORD_EXPIRY_DATE varchar(100) NULL,
                     CHANGE COLUMN PROPAGATION PROPAGATION varchar(100) NULL,
                     CHANGE COLUMN STATUS_DATE STATUS_DATE date NULL,
                     ADD UNIQUE CRSID (CRSID),
                     ADD UNIQUE ENGID (ENGID),
                     ADD UNIQUE both (ENGID, CRSID);

ALTER TABLE PP_USER_ATTRIBUTES CHANGE COLUMN USER_ID USER_ID integer(11) NOT NULL,
                               CHANGE COLUMN ATTRIBUTE_VALUE ATTRIBUTE_VALUE varchar(100) NULL,
                               CHANGE COLUMN ATTRIBUTE_EFFECTIVE_DATE ATTRIBUTE_EFFECTIVE_DATE date NULL,
                               CHANGE COLUMN ATTRIBUTE_EXPIRY_DATE ATTRIBUTE_EXPIRY_DATE date NULL;

ALTER TABLE PP_USER_CAPABILITIES CHANGE COLUMN AD_ENABLED AD_ENABLED integer(1) NULL,
                                 CHANGE COLUMN AD_PASSWORD AD_PASSWORD integer(1) NULL,
                                 CHANGE COLUMN AUTOMOUNTER AUTOMOUNTER integer(1) NULL,
                                 CHANGE COLUMN TRUST_ALLOWED TRUST_ALLOWED integer(1) NULL,
                                 CHANGE COLUMN UNIX_PASSWD UNIX_PASSWD integer(1) NULL,
                                 CHANGE COLUMN UNIX_ENABLED UNIX_ENABLED integer(1) NULL,
                                 CHANGE COLUMN PROP_TEACH PROP_TEACH integer(1) NULL,
                                 CHANGE COLUMN PROP_MAIL PROP_MAIL integer(1) NULL,
                                 CHANGE COLUMN PROP_DIVA PROP_DIVA integer(1) NULL,
                                 CHANGE COLUMN PROP_DIVB PROP_DIVB integer(1) NULL,
                                 CHANGE COLUMN PROP_DIVF PROP_DIVF integer(1) NULL,
                                 CHANGE COLUMN PROP_FLUID PROP_FLUID integer(1) NULL,
                                 CHANGE COLUMN PROP_STRUCT PROP_STRUCT integer(1) NULL,
                                 CHANGE COLUMN PROP_WHITTLE PROP_WHITTLE integer(1) NULL,
                                 CHANGE COLUMN PROP_WORKS PROP_WORKS integer(1) NULL,
                                 CHANGE COLUMN PROP_TEST PROP_TEST integer(1) NULL;


COMMIT;

