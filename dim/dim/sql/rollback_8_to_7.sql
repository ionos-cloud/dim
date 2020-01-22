CREATE TABLE `ldapquery` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `base` varchar(128) NOT NULL,
  `filter` varchar(128) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `base` (`base`,`filter`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `usergroupldapquery` (
  `ldapquery_id` bigint(20) DEFAULT NULL,
  `usergroup_id` bigint(20) DEFAULT NULL,
  CONSTRAINT `usergroupldapquery_ibfk_1` FOREIGN KEY (`usergroup_id`) REFERENCES `usergroup` (`id`),
  CONSTRAINT `usergroupldapquery_ibfk_2` FOREIGN KEY (`ldapquery_id`) REFERENCES `ldapquery` (`id`),
  KEY `ldapquery_id` (`ldapquery_id`),
  KEY `usergroup_id` (`usergroup_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


ALTER TABLE `usergroupuser`
      ADD COLUMN `ldapquery_id` bigint(20) DEFAULT NULL,
      ADD KEY `ldapquery_id` (`ldapquery_id`),
      ADD CONSTRAINT `usergroupuser_ibfk_3` FOREIGN KEY (`ldapquery_id`) REFERENCES `ldapquery` (`id`),
      DROP COLUMN `from_ldap`;

ALTER TABLE `usergroup`
      DROP INDEX `ldap_base`,
      DROP COLUMN `ldap_base`,
      DROP COLUMN `ldap_filter`;

UPDATE schemainfo SET version=7;

COMMIT;
