-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Wed Sep 11 16:41:41 2013
-- 

BEGIN TRANSACTION;

--
-- Table: PP_ATTRIBUTES
--
DROP TABLE PP_ATTRIBUTES;

CREATE TABLE PP_ATTRIBUTES (
  ATTRIBUTE_ID INTEGER PRIMARY KEY NOT NULL,
  ATTRIBUTE_NAME text NOT NULL
);

CREATE UNIQUE INDEX PP_ATTRIBUTES_ATTRIBUTE_NAME ON PP_ATTRIBUTES (ATTRIBUTE_NAME);

--
-- Table: PP_GROUPS
--
DROP TABLE PP_GROUPS;

CREATE TABLE PP_GROUPS (
  GROUP_ID INTEGER PRIMARY KEY NOT NULL,
  GID integer NOT NULL,
  GROUP_NAME text NOT NULL,
  GROUP_DESC 
);

CREATE UNIQUE INDEX PP_GROUPS_GROUP_NAME_GID ON PP_GROUPS (GROUP_NAME, GID);

--
-- Table: PP_STATUSES
--
DROP TABLE PP_STATUSES;

CREATE TABLE PP_STATUSES (
  STATUS_ID INTEGER PRIMARY KEY NOT NULL,
  STATUS_NAME ,
  AD_PASSWORD ,
  AUTOMOUNTER ,
  AD_ENABLED ,
  TRUST_ALLOWED ,
  UNIX_PASSWD ,
  UNIX_ENABLED ,
  PROP_DEPT ,
  PROP_MAIL ,
  PROP_DIVA ,
  PROP_DIVB ,
  PROP_DIVF ,
  PROP_FLUID ,
  PROP_STRUCT ,
  PROP_WHITTLE ,
  PROP_WORKS ,
  PROP_TEST 
);

CREATE UNIQUE INDEX PP_STATUSES_STATUS_NAME ON PP_STATUSES (STATUS_NAME);

--
-- Table: PP_USERS
--
DROP TABLE PP_USERS;

CREATE TABLE PP_USERS (
  USER_ID INTEGER PRIMARY KEY NOT NULL,
  CRSID text NOT NULL,
  ENGID text,
  UID integer NOT NULL,
  GECOS ,
  HOMEDIR ,
  PASSWORD_EXPIRY_DATE ,
  PROPAGATION ,
  STATUS_ID integer NOT NULL,
  STATUS_DATE ,
  FOREIGN KEY (STATUS_ID) REFERENCES PP_STATUSES(STATUS_ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX PP_USERS_idx_STATUS_ID ON PP_USERS (STATUS_ID);

CREATE UNIQUE INDEX PP_USERS_ENGID_CRSID_UID ON PP_USERS (ENGID, CRSID, UID);

--
-- Table: PP_USER_CAPABILITIES
--
DROP TABLE PP_USER_CAPABILITIES;

CREATE TABLE PP_USER_CAPABILITIES (
  CAPABILITIES_ID INTEGER PRIMARY KEY NOT NULL,
  USER_ID integer NOT NULL,
  AD_ENABLED  NOT NULL,
  AD_PASSWORD  NOT NULL,
  TRUST_ALLOWED  NOT NULL,
  UNIX_PASSWD  NOT NULL,
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
  USER_ATTRIBUTE_ID INTEGER PRIMARY KEY NOT NULL,
  AD_PASSWORD ,
  AUTOMOUNTER ,
  AD_ENABLED ,
  TRUST_ALLOWED ,
  UNIX_PASSWD ,
  UNIX_ENABLED ,
  PROP_DEPT ,
  PROP_MAIL ,
  PROP_DIVA ,
  PROP_DIVB ,
  PROP_DIVF ,
  PROP_FLUID ,
  PROP_STRUCT ,
  PROP_WHITTLE ,
  PROP_WORKS ,
  PROP_TEST ,
  FOREIGN KEY (ATTRIBUTE_ID) REFERENCES PP_ATTRIBUTES(ATTRIBUTE_ID),
  FOREIGN KEY (USER_ID) REFERENCES PP_USERS(USER_ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX PP_USER_ATTRIBUTES_idx_ATTRIBUTE_ID ON PP_USER_ATTRIBUTES (ATTRIBUTE_ID);

CREATE INDEX PP_USER_ATTRIBUTES_idx_USER_ID ON PP_USER_ATTRIBUTES (USER_ID);

COMMIT;
