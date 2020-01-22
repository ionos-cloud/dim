DROP TABLE department;

ALTER TABLE history_usergroup
      ADD COLUMN ldap_base varchar(128),
      ADD COLUMN ldap_filter varchar(128),
      DROP COLUMN `department_number`,
      MODIFY COLUMN `name` VARCHAR(64);

ALTER TABLE ippool
      DROP FOREIGN KEY `ippool_ibfk_2`,
      DROP COLUMN owner_id;

ALTER TABLE user
      DROP COLUMN `department_number`,
      DROP COLUMN `ldap_cn`,
      DROP INDEX ldap_uid,
      DROP COLUMN `ldap_uid`;

ALTER TABLE usergroup
      ADD COLUMN ldap_base varchar(128),
      ADD COLUMN ldap_filter varchar(128),
      DROP COLUMN department_number,
      ADD UNIQUE KEY ldap_base(ldap_base, ldap_filter),
      MODIFY COLUMN `name` VARCHAR(64) NOT NULL;

ALTER TABLE zone
      DROP FOREIGN KEY zone_ibfk_1,
      DROP COLUMN owner_id;

UPDATE schemainfo SET version=8;

COMMIT;
