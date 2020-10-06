
-- Dumping structure for table redemrp.user_storage
CREATE TABLE IF NOT EXISTS `user_storage` (
  `identifier` varchar(50) COLLATE utf8mb4_bin NOT NULL,
  `charid` int(11) NOT NULL,
  `items` varchar(8000) COLLATE utf8mb4_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC;
