-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Tue Sep  3 11:18:49 2013
-- 

BEGIN TRANSACTION;

--
-- Table: PP_ATTRIBUTES
--
DROP TABLE PP_ATTRIBUTES;

CREATE TABLE PP_ATTRIBUTES (
  ATTRIBUTE_ID  NOT NULL,
  ATTRIBUTE_NAME  NOT NULL,
  PRIMARY KEY (ATTRIBUTE_ID)
);

CREATE UNIQUE INDEX PP_ATTRIBUTES_ATTRIBUTE_ID_ATTRIBUTE_NAME ON PP_ATTRIBUTES (ATTRIBUTE_ID, ATTRIBUTE_NAME);

--
-- Table: PP_GROUPS
--
DROP TABLE PP_GROUPS;

CREATE TABLE PP_GROUPS (
  GROUP_ID INTEGER PRIMARY KEY NOT NULL,
  GROUP_DESC ,
  GROUP_NAME  NOT NULL,
  GID  NOT NULL
);

CREATE UNIQUE INDEX PP_GROUPS_GROUP_ID_GROUP_NAME_GID ON PP_GROUPS (GROUP_ID, GROUP_NAME, GID);

--
-- Table: PP_STATUSES
--
DROP TABLE PP_STATUSES;

CREATE TABLE PP_STATUSES (
  STATUS_ID  NOT NULL,
  STATUS_NAME  NOT NULL,
  UNIX_PASSWORD  NOT NULL,
  AD_PASSWORD  NOT NULL,
  AUTOMOUNTER  NOT NULL,
  AD_ENABLED  NOT NULL,
  TRUST_ALLOWED  NOT NULL,
  UNIX_PASSWD  NOT NULL,
  UNIX_ENABLED  NOT NULL,
  PROP_DEPT  NOT NULL,
  PROP_MAIL  NOT NULL,
  PROP_DIVA  NOT NULL,
  PROP_DIVB  NOT NULL,
  PROP_DIVF  NOT NULL,
  PROP_FLUID  NOT NULL,
  PROP_STRUCT  NOT NULL,
  PROP_WHITTLE  NOT NULL,
  PROP_WORKS  NOT NULL,
  PROP_TEST  NOT NULL,
  PRIMARY KEY (STATUS_ID)
);

CREATE UNIQUE INDEX PP_STATUSES_STATUS_ID_STATUS_NAME ON PP_STATUSES (STATUS_ID, STATUS_NAME);

--
-- Table: PP_USERS
--
DROP TABLE PP_USERS;

CREATE TABLE PP_USERS (
  ENGID  NOT NULL,
  CRSID  NOT NULL,
  UID  NOT NULL,
  USER_ID INTEGER PRIMARY KEY NOT NULL,
  GECOS ,
  HOMEDIR ,
  PASSWORD_EXPIRY_DATE ,
  PROPAGATION ,
  STATUS_ID ,
  STATUS_EFFECTIVE_DATE ,
  FOREIGN KEY (STATUS_ID) REFERENCES PP_STATUSES(STATUS_ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX PP_USERS_idx_STATUS_ID ON PP_USERS (STATUS_ID);

CREATE UNIQUE INDEX PP_USERS_USER_ID_ENGID_CRSID_UID ON PP_USERS (USER_ID, ENGID, CRSID, UID);

--
-- Table: PP_USER_CAPABILITIES
--
DROP TABLE PP_USER_CAPABILITIES;

CREATE TABLE PP_USER_CAPABILITIES (
  CAPABILITIES_ID  NOT NULL,
  USER_ID  NOT NULL,
  AD_ENABLED  NOT NULL,
  AD_PASSWORD  NOT NULL,
  TRUST_ALLOWED  NOT NULL,
  UNIX_PASSWORD  NOT NULL,
  UNIX_ENABLED  NOT NULL,
  AUTOMOUNTER  NOT NULL,
  PROP_DEPT  NOT NULL,
  PROP_MAIL  NOT NULL,
  PROP_DIVA  NOT NULL,
  PROP_DIVB  NOT NULL,
  PROP_DIVF  NOT NULL,
  PROP_FLUID  NOT NULL,
  PROP_STRUCT  NOT NULL,
  PROP_WHITTLE  NOT NULL,
  PROP_WORKS  NOT NULL,
  PROP_TEST  NOT NULL,
  PRIMARY KEY (CAPABILITIES_ID),
  FOREIGN KEY (USER_ID) REFERENCES PP_USERS(USER_ID)
);

CREATE INDEX PP_USER_CAPABILITIES_idx_USER_ID ON PP_USER_CAPABILITIES (USER_ID);

CREATE UNIQUE INDEX PP_USER_CAPABILITIES_CAPABILITIES_ID_USER_ID ON PP_USER_CAPABILITIES (CAPABILITIES_ID, USER_ID);

--
-- Table: PP_GROUP_MEMBERSHIPS
--
DROP TABLE PP_GROUP_MEMBERSHIPS;

CREATE TABLE PP_GROUP_MEMBERSHIPS (
  GROUP_MEMBERSHIP_ID INTEGER PRIMARY KEY NOT NULL,
  USER_ID integer NOT NULL,
  GROUP_ID integer NOT NULL,
  FOREIGN KEY (GROUP_ID) REFERENCES PP_GROUPS(GROUP_ID) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (USER_ID) REFERENCES PP_USERS(USER_ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX PP_GROUP_MEMBERSHIPS_idx_GROUP_ID ON PP_GROUP_MEMBERSHIPS (GROUP_ID);

CREATE INDEX PP_GROUP_MEMBERSHIPS_idx_USER_ID ON PP_GROUP_MEMBERSHIPS (USER_ID);

--
-- Table: PP_USER_ATTRIBUTES
--
DROP TABLE PP_USER_ATTRIBUTES;

CREATE TABLE PP_USER_ATTRIBUTES (
  USER_ATTRIBUTE_ID  NOT NULL,
  USER_ID  NOT NULL,
  ATTRIBUTE_ID  NOT NULL,
  ATTRIBUTE_VALUE  NOT NULL,
  ATTRIBUTE_EFFECTIVE_DATE  NOT NULL,
  ATTRIBUTE_EXPIRY_DATE  NOT NULL,
  PRIMARY KEY (USER_ATTRIBUTE_ID),
  FOREIGN KEY (ATTRIBUTE_ID) REFERENCES PP_ATTRIBUTES(ATTRIBUTE_ID),
  FOREIGN KEY (USER_ID) REFERENCES PP_USERS(USER_ID)
);

CREATE INDEX PP_USER_ATTRIBUTES_idx_ATTRIBUTE_ID ON PP_USER_ATTRIBUTES (ATTRIBUTE_ID);

CREATE INDEX PP_USER_ATTRIBUTES_idx_USER_ID ON PP_USER_ATTRIBUTES (USER_ID);

COMMIT;
