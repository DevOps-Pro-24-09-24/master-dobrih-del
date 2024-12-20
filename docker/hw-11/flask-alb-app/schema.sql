CREATE TABLE IF NOT EXISTS `requests` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
  	`hostname` varchar(50) NOT NULL,
  	`remote_ip` varchar(20) NOT NULL,
  	`date` varchar(100) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;