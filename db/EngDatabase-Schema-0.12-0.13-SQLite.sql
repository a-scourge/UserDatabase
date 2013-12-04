-- Convert schema 'db/LinWin-Schema-0.12-SQLite.sql' to 'db/LinWin-Schema-0.13-SQLite.sql':;

BEGIN;

CREATE TEMPORARY TABLE PP_USER_ATTRIBUTES_temp_alter (
  USER_ATTRIBUTE_ID INTEGER PRIMARY KEY NOT NULL,
  USER_ID text NOT NULL,
  ATTRIBUTE_ID integer NOT NULL,
  ATTRIBUTE_VALUE ,
  ATTRIBUTE_EFFECTIVE_DATE ,
  ATTRIBUTE_EXPIRY_DATE ,
  FOREIGN KEY (ATTRIBUTE_ID) REFERENCES PP_ATTRIBUTES(ATTRIBUTE_ID),
  FOREIGN KEY (USER_ID) REFERENCES PP_USERS(USER_ID) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO PP_USER_ATTRIBUTES_temp_alter( USER_ATTRIBUTE_ID) SELECT USER_ATTRIBUTE_ID FROM PP_USER_ATTRIBUTES;

DROP TABLE PP_USER_ATTRIBUTES;

CREATE TABLE PP_USER_ATTRIBUTES (
  USER_ATTRIBUTE_ID INTEGER PRIMARY KEY NOT NULL,
  USER_ID text NOT NULL,
  ATTRIBUTE_ID integer NOT NULL,
  ATTRIBUTE_VALUE ,
  ATTRIBUTE_EFFECTIVE_DATE ,
  ATTRIBUTE_EXPIRY_DATE ,
  FOREIGN KEY (ATTRIBUTE_ID) REFERENCES PP_ATTRIBUTES(ATTRIBUTE_ID),
  FOREIGN KEY (USER_ID) REFERENCES PP_USERS(USER_ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX PP_USER_ATTRIBUTES_idx_ATTR00 ON PP_USER_ATTRIBUTES (ATTRIBUTE_ID);

CREATE INDEX PP_USER_ATTRIBUTES_idx_USER00 ON PP_USER_ATTRIBUTES (USER_ID);

INSERT INTO PP_USER_ATTRIBUTES SELECT USER_ATTRIBUTE_ID, USER_ID, ATTRIBUTE_ID, ATTRIBUTE_VALUE, ATTRIBUTE_EFFECTIVE_DATE, ATTRIBUTE_EXPIRY_DATE FROM PP_USER_ATTRIBUTES_temp_alter;

DROP TABLE PP_USER_ATTRIBUTES_temp_alter;


COMMIT;

