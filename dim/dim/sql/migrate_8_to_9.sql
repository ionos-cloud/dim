CREATE TABLE `department` (
  `department_number` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  PRIMARY KEY (`department_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE history_usergroup
      DROP COLUMN ldap_base,
      DROP COLUMN ldap_filter,
      ADD COLUMN `department_number` int DEFAULT NULL,
      MODIFY COLUMN `name` VARCHAR(128);

ALTER TABLE ippool
      ADD COLUMN owner_id bigint DEFAULT NULL,
      ADD FOREIGN KEY (owner_id) REFERENCES usergroup(id) ON DELETE SET NULL;

ALTER TABLE user
      ADD COLUMN `department_number` int(11) DEFAULT NULL,
      ADD COLUMN `ldap_cn` varchar(128) DEFAULT NULL,
      ADD COLUMN `ldap_uid` int(11) DEFAULT NULL,
      ADD UNIQUE KEY ldap_uid(ldap_uid);

ALTER TABLE usergroup
      DROP COLUMN ldap_base,
      DROP COLUMN ldap_filter,
      ADD COLUMN department_number int DEFAULT NULL,
      ADD UNIQUE KEY department_number(department_number),
      MODIFY COLUMN `name` VARCHAR(128) NOT NULL;

ALTER TABLE zone
      ADD COLUMN owner_id bigint DEFAULT NULL,
      ADD FOREIGN KEY (owner_id) REFERENCES usergroup(id) ON DELETE SET NULL;

UPDATE schemainfo SET version=9;

COMMIT;
