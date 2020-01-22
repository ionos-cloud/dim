UPDATE `output` SET db_uri=pdns_slave_db_uri, plugin='pdns-db'
 WHERE plugin='pdns-sign-agent';

-- DIM-347 Merge _sign outputs with non-_sign ones
UPDATE outputzonegroup
  JOIN zonegroup ON zonegroup.id=outputzonegroup.zonegroup_id
  JOIN output ON output.id=outputzonegroup.output_id
   SET output_id=(SELECT o2.id FROM output o2 WHERE o2.name=REPLACE(output.name, '_sign', ''))
 WHERE output.name LIKE '%_sign%';
DELETE FROM output WHERE output.name LIKE '%_sign%';

CREATE TABLE `registraraccount` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  `plugin` varchar(20) NOT NULL,
  `url` varchar(255) NOT NULL,
  `username` varchar(128) NOT NULL,
  `password` varchar(128) NOT NULL,
  `subaccount` varchar(128) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `registraraccountzonekey` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `zone_id` bigint(20) NOT NULL,
  `pubkey` mediumtext NOT NULL,
  `algorithm` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `zone_id` (`zone_id`),
  CONSTRAINT `registraraccountzonekey_ibfk_1` FOREIGN KEY (`zone_id`) REFERENCES `zone` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `registraraction` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `zone_id` bigint(20) NOT NULL,
  `status` enum('pending','running','done','failed','unknown') NOT NULL,
  `error` mediumtext,
  `started` timestamp NULL DEFAULT NULL,
  `completed` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `zone_id` (`zone_id`),
  CONSTRAINT `registraraction_ibfk_1` FOREIGN KEY (`zone_id`) REFERENCES `zone` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `output`
      DROP FOREIGN KEY output_ibfk_1,
      DROP COLUMN softhsm_agent_id,
      DROP COLUMN pdns_sign_cfgname,
      DROP COLUMN pdns_sign_db_uri,
      DROP COLUMN pdns_sign_ip,
      DROP COLUMN pdns_slave_cfgname,
      DROP COLUMN pdns_slave_db_uri;

ALTER TABLE zonekey
      DROP FOREIGN KEY zonekey_ibfk_1,
      DROP FOREIGN KEY zonekey_ibfk_2,
      DROP COLUMN softhsm_agent_id,
      MODIFY COLUMN pubkey MEDIUMTEXT NOT NULL,
      ADD COLUMN privkey MEDIUMTEXT NOT NULL;

ALTER TABLE zonekey
      ADD COLUMN `registraraction_id` bigint(20) DEFAULT NULL,
      ADD KEY `registraraction_id` (`registraraction_id`),
      ADD CONSTRAINT `zonekey_ibfk_1` FOREIGN KEY (`zone_id`) REFERENCES `zone` (`id`),
      ADD CONSTRAINT `zonekey_ibfk_2` FOREIGN KEY (`registraraction_id`) REFERENCES `registraraction` (`id`);

ALTER TABLE zone
      ADD COLUMN `valid_begin` timestamp NULL DEFAULT NULL,
      ADD COLUMN `valid_end` timestamp NULL DEFAULT NULL,
      ADD COLUMN `registraraccount_id` bigint(20) DEFAULT NULL,
      ADD KEY `registraraccount_id` (`registraraccount_id`),
      ADD CONSTRAINT `zone_ibfk_2` FOREIGN KEY (`registraraccount_id`) REFERENCES `registraraccount` (`id`);

ALTER TABLE zoneview
      DROP COLUMN nsec3_opt_out;

DROP TABLE softhsm_agent;

DROP TABLE history_zonealias;

CREATE TABLE `history_registraraccount` (
  `action_info` varchar(4096) DEFAULT NULL,
  `action` varchar(32) NOT NULL,
  `call_ip_address` decimal(40,0) DEFAULT NULL,
  `call_ip_version` int(11) DEFAULT NULL,
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT '1970-01-02 00:00:01',
  `tool` varchar(64) DEFAULT NULL,
  `user` varchar(128) NOT NULL,
  `zone` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_history_registraraccount_timestamp` (`timestamp`),
  KEY `ix_history_registraraccount_user` (`user`),
  KEY `ix_history_registraraccount_zone` (`zone`),
  KEY `ix_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `history_zonekey` (
  `action` varchar(32) NOT NULL,
  `call_ip_address` decimal(40,0) DEFAULT NULL,
  `call_ip_version` int(11) DEFAULT NULL,
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `label` varchar(255) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT '1970-01-02 00:00:01',
  `tool` varchar(64) DEFAULT NULL,
  `user` varchar(128) NOT NULL,
  `zone` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_history_zonekey_timestamp` (`timestamp`),
  KEY `ix_history_zonekey_user` (`user`),
  KEY `ix_history_zonekey_zone` (`zone`),
  KEY `ix_label` (`label`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

UPDATE schemainfo SET version=10;
COMMIT;
