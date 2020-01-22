ALTER TABLE history_ipblock
      ADD COLUMN `tool` varchar(64) DEFAULT NULL,
      ADD COLUMN `call_ip_address` decimal(40,0) DEFAULT NULL,
      ADD COLUMN `call_ip_version` int(11) DEFAULT NULL;

ALTER TABLE history_ippool
      ADD COLUMN `tool` varchar(64) DEFAULT NULL,
      ADD COLUMN `call_ip_address` decimal(40,0) DEFAULT NULL,
      ADD COLUMN `call_ip_version` int(11) DEFAULT NULL;

ALTER TABLE history_rr
      ADD COLUMN `tool` varchar(64) DEFAULT NULL,
      ADD COLUMN `call_ip_address` decimal(40,0) DEFAULT NULL,
      ADD COLUMN `call_ip_version` int(11) DEFAULT NULL;

ALTER TABLE history_zone
      ADD COLUMN `tool` varchar(64) DEFAULT NULL,
      ADD COLUMN `call_ip_address` decimal(40,0) DEFAULT NULL,
      ADD COLUMN `call_ip_version` int(11) DEFAULT NULL;

ALTER TABLE history_zonealias
      ADD COLUMN `tool` varchar(64) DEFAULT NULL,
      ADD COLUMN `call_ip_address` decimal(40,0) DEFAULT NULL,
      ADD COLUMN `call_ip_version` int(11) DEFAULT NULL;

ALTER TABLE history_zoneview
      ADD COLUMN `tool` varchar(64) DEFAULT NULL,
      ADD COLUMN `call_ip_address` decimal(40,0) DEFAULT NULL,
      ADD COLUMN `call_ip_version` int(11) DEFAULT NULL;

ALTER TABLE history_zonegroup
      ADD COLUMN `tool` varchar(64) DEFAULT NULL,
      ADD COLUMN `call_ip_address` decimal(40,0) DEFAULT NULL,
      ADD COLUMN `call_ip_version` int(11) DEFAULT NULL;

ALTER TABLE history_usergroup
      ADD COLUMN `ldap_base` varchar(128) DEFAULT NULL,
      ADD COLUMN `ldap_filter` varchar(128) DEFAULT NULL,
      ADD COLUMN `tool` varchar(64) DEFAULT NULL,
      ADD COLUMN `call_ip_address` decimal(40,0) DEFAULT NULL,
      ADD COLUMN `call_ip_version` int(11) DEFAULT NULL;

ALTER TABLE history_groupright
      ADD COLUMN `tool` varchar(64) DEFAULT NULL,
      ADD COLUMN `call_ip_address` decimal(40,0) DEFAULT NULL,
      ADD COLUMN `call_ip_version` int(11) DEFAULT NULL;

ALTER TABLE history_output
      ADD COLUMN `tool` varchar(64) DEFAULT NULL,
      ADD COLUMN `call_ip_address` decimal(40,0) DEFAULT NULL,
      ADD COLUMN `call_ip_version` int(11) DEFAULT NULL;

CREATE TABLE `ldapquery` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `base` varchar(128) NOT NULL,
  `filter` varchar(128) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `base` (`base`,`filter`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER IGNORE TABLE usergroupuser
      ADD COLUMN `ldapquery_id` bigint(20) DEFAULT NULL,
      ADD KEY `ldapquery_id` (`ldapquery_id`),
      ADD CONSTRAINT `usergroupuser_ibfk_3` FOREIGN KEY (`ldapquery_id`) REFERENCES `ldapquery` (`id`),
      ADD PRIMARY KEY (`usergroup_id`,`user_id`),
      ALTER COLUMN `user_id` DROP DEFAULT,
      ALTER COLUMN `usergroup_id` DROP DEFAULT;

CREATE TABLE `usergroupldapquery` (
  `ldapquery_id` bigint(20) DEFAULT NULL,
  `usergroup_id` bigint(20) DEFAULT NULL,
  CONSTRAINT `usergroupldapquery_ibfk_1` FOREIGN KEY (`usergroup_id`) REFERENCES `usergroup` (`id`),
  CONSTRAINT `usergroupldapquery_ibfk_2` FOREIGN KEY (`ldapquery_id`) REFERENCES `ldapquery` (`id`),
  KEY `ldapquery_id` (`ldapquery_id`),
  KEY `usergroup_id` (`usergroup_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

UPDATE schemainfo SET version=6;

COMMIT;
