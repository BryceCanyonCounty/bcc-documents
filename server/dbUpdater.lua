CreateThread(function()
    -- Create the bcc_documents table if it doesn't exist
    MySQL.query.await([[ 
        CREATE TABLE IF NOT EXISTS `bcc_documents` (
          `identifier` varchar(50) NOT NULL,
          `charidentifier` varchar(50) NOT NULL,
          `doc_type` varchar(50) NOT NULL,
          `firstname` varchar(50) DEFAULT NULL,
          `lastname` varchar(50) DEFAULT NULL,
          `nickname` varchar(50) DEFAULT NULL,
          `job` varchar(50) DEFAULT NULL,
          `age` varchar(50) DEFAULT NULL,
          `gender` varchar(50) DEFAULT NULL,
          `date` varchar(50) NOT NULL,
          `picture` longtext DEFAULT NULL,
          `expire_date` varchar(50) DEFAULT NULL,
          PRIMARY KEY (`identifier`, `charidentifier`, `doc_type`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
    ]])

    -- Insert items if they do not already exist
    MySQL.query.await([[ 
        INSERT INTO `items` (`item`, `label`, `limit`, `can_remove`, `type`, `usable`, `desc`)
        VALUES 
        ('goldpanninglicence', 'Gold Panning License', 1, 1, 'item_standard', 1, 'You cannot go to the river without this license'),
        ('huntinglicence', 'Hunting License', 1, 1, 'item_standard', 1, 'You need a license when you go hunting'),
        ('lumberlicence', 'Lumberjack License', 1, 1, 'item_standard', 1, 'You cannot cut wood without this license'),
        ('mininglicence', 'Mining License', 1, 1, 'item_standard', 1, 'You cannot go into the mine without this license'),
        ('idcard', 'Identification Card', 1, 1, 'item_standard', 1, 'You need an ID card to be registered')
        ON DUPLICATE KEY UPDATE 
        `label` = VALUES(`label`), 
        `limit` = VALUES(`limit`), 
        `can_remove` = VALUES(`can_remove`), 
        `type` = VALUES(`type`), 
        `usable` = VALUES(`usable`), 
        `desc` = VALUES(`desc`);
    ]])

    -- Commit any pending transactions to ensure changes are saved
    MySQL.query.await("COMMIT;")

    -- Print success message to console
    print("Database tables for \x1b[35m\x1b[1m*bcc-documents*\x1b[0m created or updated \x1b[32msuccessfully\x1b[0m.")
end)
