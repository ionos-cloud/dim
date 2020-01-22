CREATE TABLE `favoritezoneview` (
  `user_id` bigint(20) NOT NULL,
  `zoneview_id` bigint(20) NOT NULL,
  PRIMARY KEY (`zoneview_id`,`user_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `favoritezoneview_ibfk_1` FOREIGN KEY (`zoneview_id`) REFERENCES `zoneview` (`id`),
  CONSTRAINT `favoritezoneview_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `favoriteippool` (
  CONSTRAINT `favoriteippool_ibfk_1` FOREIGN KEY (`ippool_id`) REFERENCES `ippool` (`id`),
  CONSTRAINT `favoriteippool_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  KEY `user_id` (`user_id`),
  PRIMARY KEY (`ippool_id`,`user_id`),
  `ippool_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE user ADD COLUMN `preferences` text;

CREATE TABLE `layer3domain` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  `type` varchar(20) NOT NULL,
  `comment` varchar(255) DEFAULT NULL,
  `rd` bigint(20) DEFAULT NULL,
  `created` timestamp NOT NULL DEFAULT '1970-01-02 00:00:01',
  `created_by` varchar(128) DEFAULT NULL,
  `modified` timestamp NOT NULL DEFAULT '1970-01-02 00:00:01',
  `modified_by` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `rd` (`rd`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `history_layer3domain` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `timestamp` timestamp(6) NOT NULL DEFAULT '1970-01-02 00:00:01.000000',
  `user` varchar(128) NOT NULL,
  `action` varchar(32) NOT NULL,
  `call_ip_version` int(11) DEFAULT NULL,
  `call_ip_address` decimal(40,0) DEFAULT NULL,
  `tool` varchar(64) DEFAULT NULL,
  `name` varchar(128) DEFAULT NULL,
  `comment` varchar(255) DEFAULT NULL,
  `attrname` varchar(256) DEFAULT NULL,
  `newvalue` varchar(256) DEFAULT NULL,
  `oldvalue` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_name` (`name`),
  KEY `ix_history_layer3domain_timestamp` (`timestamp`),
  KEY `ix_history_layer3domain_user` (`user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO layer3domain (name, type, rd) VALUES ('default', 'vrf', 560988161);

SET foreign_key_checks = 0;
ALTER TABLE `ipblock`
      ADD COLUMN `layer3domain_id` bigint(20) NOT NULL,
      ADD KEY `layer3domain_id` (`layer3domain_id`),
      ADD CONSTRAINT `ipblock_ibfk_5` FOREIGN KEY (`layer3domain_id`) REFERENCES `layer3domain` (`id`),
      DROP INDEX `address`,
      ADD UNIQUE KEY `address` (`address`,`prefix`,`layer3domain_id`);

UPDATE ipblock SET layer3domain_id = (SELECT layer3domain.id FROM layer3domain LIMIT 1);

ALTER TABLE `ippool`
      ADD COLUMN `layer3domain_id` bigint(20) NOT NULL,
      ADD KEY `layer3domain_id` (`layer3domain_id`),
      ADD CONSTRAINT `ippool_ibfk_3` FOREIGN KEY (`layer3domain_id`) REFERENCES `layer3domain` (`id`);

UPDATE ippool SET layer3domain_id = (SELECT layer3domain.id FROM layer3domain LIMIT 1);
SET foreign_key_checks = 1;

-- History
ALTER TABLE `history_ipblock`
      ADD COLUMN `layer3domain` varchar(128) DEFAULT NULL;
UPDATE history_ipblock SET layer3domain = (SELECT layer3domain.name FROM layer3domain LIMIT 1);

ALTER TABLE `history_ippool`
      ADD COLUMN `layer3domain` varchar(128) DEFAULT NULL;
UPDATE history_ippool SET layer3domain = (SELECT layer3domain.name FROM layer3domain LIMIT 1);

ALTER TABLE `history_rr`
      ADD COLUMN `layer3domain` varchar(128) DEFAULT NULL;
UPDATE history_rr SET layer3domain = (SELECT layer3domain.name FROM layer3domain LIMIT 1);

UPDATE schemainfo SET version=12;
COMMIT;
