CREATE TABLE `softhsm_agent` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uri` varchar(255) NOT NULL,
  `api_key` varchar(255) DEFAULT NULL,
  `pin` varchar(4) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uri` (`uri`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `zonekey` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `bits` int(11) NOT NULL,
  `type` enum('ksk','zsk') NOT NULL,
  `label` varchar(255) NOT NULL,
  `algorithm` int(11) NOT NULL,
  `pubkey` mediumtext,
  `softhsm_agent_id` bigint(20) NOT NULL,
  `zone_id` bigint(20) NOT NULL,
  `created` timestamp NOT NULL DEFAULT '1970-01-02 00:00:01',
  PRIMARY KEY (`id`),
  UNIQUE KEY `zone_id` (`zone_id`,`label`),
  KEY `softhsm_agent_id` (`softhsm_agent_id`),
  CONSTRAINT `zonekey_ibfk_1` FOREIGN KEY (`softhsm_agent_id`) REFERENCES `softhsm_agent` (`id`),
  CONSTRAINT `zonekey_ibfk_2` FOREIGN KEY (`zone_id`) REFERENCES `zone` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `output`
      ADD COLUMN `pdns_sign_db_uri` varchar(255) DEFAULT NULL,
      ADD COLUMN `pdns_sign_cfgname` varchar(255) DEFAULT NULL,
      ADD COLUMN `pdns_sign_ip` varchar(255) DEFAULT NULL,
      ADD COLUMN `pdns_slave_db_uri` varchar(255) DEFAULT NULL,
      ADD COLUMN `pdns_slave_cfgname` varchar(255) DEFAULT NULL,
      ADD COLUMN `softhsm_agent_id` bigint(20) DEFAULT NULL,
      ADD KEY `softhsm_agent_id` (`softhsm_agent_id`),
      ADD CONSTRAINT `output_ibfk_1` FOREIGN KEY (`softhsm_agent_id`) REFERENCES `softhsm_agent` (`id`);

ALTER TABLE `zoneview`
      ADD COLUMN `nsec3_opt_out` tinyint(1) NOT NULL;

ALTER TABLE `zone`
      ADD COLUMN `nsec3_algorithm` int(11) DEFAULT NULL,
      ADD COLUMN `nsec3_iterations` int(11) DEFAULT NULL,
      ADD COLUMN `nsec3_salt` varchar(510) DEFAULT NULL;

UPDATE schemainfo SET version=7;

COMMIT;
