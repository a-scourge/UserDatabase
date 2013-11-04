-- Convert schema 'db/EngDatabase-Schema-0.18-MySQL.sql' to 'EngDatabase::Schema v0.19':;

BEGIN;

ALTER TABLE PP_GROUPS ADD UNIQUE PP_GROUPS_GID (GID);

ALTER TABLE PP_STATUSES CHANGE COLUMN STATUS_NAME STATUS_NAME  NULL,
                        CHANGE COLUMN AD_PASSWORD AD_PASSWORD  NULL,
                        CHANGE COLUMN AUTOMOUNTER AUTOMOUNTER  NULL,
                        CHANGE COLUMN AD_ENABLED AD_ENABLED  NULL,
                        CHANGE COLUMN TRUST_ALLOWED TRUST_ALLOWED  NULL,
                        CHANGE COLUMN UNIX_PASSWD UNIX_PASSWD  NULL,
                        CHANGE COLUMN UNIX_ENABLED UNIX_ENABLED  NULL,
                        CHANGE COLUMN PROP_DEPT PROP_DEPT  NULL,
                        CHANGE COLUMN PROP_MAIL PROP_MAIL  NULL,
                        CHANGE COLUMN PROP_DIVA PROP_DIVA  NULL,
                        CHANGE COLUMN PROP_DIVB PROP_DIVB  NULL,
                        CHANGE COLUMN PROP_DIVF PROP_DIVF  NULL,
                        CHANGE COLUMN PROP_FLUID PROP_FLUID  NULL,
                        CHANGE COLUMN PROP_STRUCT PROP_STRUCT  NULL,
                        CHANGE COLUMN PROP_WHITTLE PROP_WHITTLE  NULL,
                        CHANGE COLUMN PROP_WORKS PROP_WORKS  NULL,
                        CHANGE COLUMN PROP_TEST PROP_TEST  NULL;

ALTER TABLE PP_USERS CHANGE COLUMN GECOS GECOS  NULL,
                     CHANGE COLUMN HOMEDIR HOMEDIR  NULL,
                     CHANGE COLUMN PASSWORD_EXPIRY_DATE PASSWORD_EXPIRY_DATE  NULL,
                     CHANGE COLUMN PROPAGATION PROPAGATION  NULL,
                     CHANGE COLUMN STATUS_DATE STATUS_DATE  NULL,
                     ADD UNIQUE PP_USERS_CRSID (CRSID),
                     ADD UNIQUE PP_USERS_ENGID (ENGID),
                     ADD UNIQUE PP_USERS_UID (UID);

ALTER TABLE PP_USER_ATTRIBUTES CHANGE COLUMN ATTRIBUTE_VALUE ATTRIBUTE_VALUE  NULL,
                               CHANGE COLUMN ATTRIBUTE_EFFECTIVE_DATE ATTRIBUTE_EFFECTIVE_DATE  NULL,
                               CHANGE COLUMN ATTRIBUTE_EXPIRY_DATE ATTRIBUTE_EXPIRY_DATE  NULL;

ALTER TABLE PP_USER_CAPABILITIES DROP COLUMN STATUS_NAME,
                                 CHANGE COLUMN AD_ENABLED AD_ENABLED integer NULL,
                                 CHANGE COLUMN AD_PASSWORD AD_PASSWORD integer NULL,
                                 CHANGE COLUMN AUTOMOUNTER AUTOMOUNTER integer NULL,
                                 CHANGE COLUMN TRUST_ALLOWED TRUST_ALLOWED integer NULL,
                                 CHANGE COLUMN UNIX_PASSWD UNIX_PASSWD integer NULL,
                                 CHANGE COLUMN UNIX_ENABLED UNIX_ENABLED integer NULL,
                                 CHANGE COLUMN PROP_DEPT PROP_DEPT integer NULL,
                                 CHANGE COLUMN PROP_MAIL PROP_MAIL integer NULL,
                                 CHANGE COLUMN PROP_DIVA PROP_DIVA integer NULL,
                                 CHANGE COLUMN PROP_DIVB PROP_DIVB integer NULL,
                                 CHANGE COLUMN PROP_DIVF PROP_DIVF integer NULL,
                                 CHANGE COLUMN PROP_FLUID PROP_FLUID integer NULL,
                                 CHANGE COLUMN PROP_STRUCT PROP_STRUCT integer NULL,
                                 CHANGE COLUMN PROP_WHITTLE PROP_WHITTLE integer NULL,
                                 CHANGE COLUMN PROP_WORKS PROP_WORKS integer NULL,
                                 CHANGE COLUMN PROP_TEST PROP_TEST integer NULL;


COMMIT;

