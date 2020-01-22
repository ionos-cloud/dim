ALTER TABLE `usergroupuser`
      DROP FOREIGN KEY `usergroupuser_ibfk_3`,
      DROP COLUMN ldapquery_id,
      ADD COLUMN `from_ldap` tinyint(1) NOT NULL;
DROP TABLE `usergroupldapquery`;
DROP TABLE `ldapquery`;

ALTER TABLE `usergroup`
      ADD COLUMN `ldap_base` varchar(128) DEFAULT NULL,
      ADD COLUMN `ldap_filter` varchar(128) DEFAULT NULL,
      ADD UNIQUE KEY `ldap_base` (`ldap_base`,`ldap_filter`);

UPDATE schemainfo SET version=8;

COMMIT;
