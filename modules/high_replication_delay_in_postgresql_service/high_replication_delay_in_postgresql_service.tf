resource "shoreline_notebook" "high_replication_delay_in_postgresql_service" {
  name       = "high_replication_delay_in_postgresql_service"
  data       = file("${path.module}/data/high_replication_delay_in_postgresql_service.json")
  depends_on = [shoreline_action.invoke_stop_remove_start_standby,shoreline_action.invoke_check_standby_wal_files]
}

resource "shoreline_file" "stop_remove_start_standby" {
  name             = "stop_remove_start_standby"
  input_file       = "${path.module}/data/stop_remove_start_standby.sh"
  md5              = filemd5("${path.module}/data/stop_remove_start_standby.sh")
  description      = "Restart the replication process by resetting the standby server to the latest checkpoint on the primary server. This can be done by stopping the standby server, removing all files in the PostgreSQL data directory, and starting the server again."
  destination_path = "/agent/scripts/stop_remove_start_standby.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "check_standby_wal_files" {
  name             = "check_standby_wal_files"
  input_file       = "${path.module}/data/check_standby_wal_files.sh"
  md5              = filemd5("${path.module}/data/check_standby_wal_files.sh")
  description      = "Verify that the standby server is up to date with the primary server by checking the WAL files on the standby server. If there are any discrepancies, restore the missing files from the primary server."
  destination_path = "/agent/scripts/check_standby_wal_files.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_stop_remove_start_standby" {
  name        = "invoke_stop_remove_start_standby"
  description = "Restart the replication process by resetting the standby server to the latest checkpoint on the primary server. This can be done by stopping the standby server, removing all files in the PostgreSQL data directory, and starting the server again."
  command     = "`chmod +x /agent/scripts/stop_remove_start_standby.sh && /agent/scripts/stop_remove_start_standby.sh`"
  params      = ["STANDBY_SERVER"]
  file_deps   = ["stop_remove_start_standby"]
  enabled     = true
  depends_on  = [shoreline_file.stop_remove_start_standby]
}

resource "shoreline_action" "invoke_check_standby_wal_files" {
  name        = "invoke_check_standby_wal_files"
  description = "Verify that the standby server is up to date with the primary server by checking the WAL files on the standby server. If there are any discrepancies, restore the missing files from the primary server."
  command     = "`chmod +x /agent/scripts/check_standby_wal_files.sh && /agent/scripts/check_standby_wal_files.sh`"
  params      = []
  file_deps   = ["check_standby_wal_files"]
  enabled     = true
  depends_on  = [shoreline_file.check_standby_wal_files]
}

