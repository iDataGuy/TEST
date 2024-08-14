terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.87.2"
      configuration_aliases = [snowflake.snow_db_admin]
    }
  }
}

resource "snowflake_database" "db" {
  provider = snowflake.snow_db_admin
  name     = each.value.name
  comment = each.value.comment
  is_transient = each.value.is_transient
  data_retention_time_in_days = each.value.retention_time
  for_each = local.db_map

}

resource "snowflake_database_grant" "grant" {
  provider = snowflake.snow_db_admin
  for_each = {
    for db, values in local.db_map : "${db}_${join("_", values.role)}" => {
      database_name      = values.name
      privilege          = "USAGE"
      roles              = values.role
      with_grant_option  = false
    }
  }

  database_name      = each.value.database_name
  privilege          = each.value.privilege
  roles              = each.value.roles
  with_grant_option  = each.value.with_grant_option

  depends_on = [
    snowflake_database.db
  ]
}
