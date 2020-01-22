SET foreign_key_checks = 0;

ALTER TABLE history_ipblock
      DROP COLUMN `tool`,
      DROP COLUMN `call_ip_address`,
      DROP COLUMN `call_ip_version`;

ALTER TABLE history_ippool
      DROP COLUMN `tool`,
      DROP COLUMN `call_ip_address`,
      DROP COLUMN `call_ip_version`;

ALTER TABLE history_rr
      DROP COLUMN `tool`,
      DROP COLUMN `call_ip_address`,
      DROP COLUMN `call_ip_version`;

ALTER TABLE history_zone
      DROP COLUMN `tool`,
      DROP COLUMN `call_ip_address`,
      DROP COLUMN `call_ip_version`;

ALTER TABLE history_zonealias
      DROP COLUMN `tool`,
      DROP COLUMN `call_ip_address`,
      DROP COLUMN `call_ip_version`;

ALTER TABLE history_zoneview
      DROP COLUMN `tool`,
      DROP COLUMN `call_ip_address`,
      DROP COLUMN `call_ip_version`;

ALTER TABLE history_zonegroup
      DROP COLUMN `tool`,
      DROP COLUMN `call_ip_address`,
      DROP COLUMN `call_ip_version`;

ALTER TABLE history_usergroup
      DROP COLUMN `ldap_base`,
      DROP COLUMN `ldap_filter`,
      DROP COLUMN `tool`,
      DROP COLUMN `call_ip_address`,
      DROP COLUMN `call_ip_version`;

ALTER TABLE history_groupright
      DROP COLUMN `tool`,
      DROP COLUMN `call_ip_address`,
      DROP COLUMN `call_ip_version`;

ALTER TABLE history_output
      DROP COLUMN `tool`,
      DROP COLUMN `call_ip_address`,
      DROP COLUMN `call_ip_version`;

DROP TABLE `ldapquery`;

ALTER TABLE `usergroupuser`
      DROP COLUMN `ldapquery_id`,
      DROP KEY `ldapquery_id`,
      DROP FOREIGN KEY `usergroupuser_ibfk_3`,
      DROP PRIMARY KEY,
      MODIFY COLUMN `user_id` bigint(20) DEFAULT NULL,
      MODIFY COLUMN `usergroup_id` bigint(20) DEFAULT NULL;

SET foreign_key_checks = 1;

UPDATE schemainfo SET version=5;

COMMIT;