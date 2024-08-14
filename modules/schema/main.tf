terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.87.2"
      configuration_aliases = [snowflake.snow_db_admin]
    }
  }
}

resource "snowflake_schema" "schema" {
  provider = snowflake.snow_db_admin
  
  for_each = { for index, value in local.schema_details : index => value }
  
  database = each.value.database
  name     = each.value.name
  comment  = each.value.comment
  is_transient = false
  is_managed   = false
  data_retention_days = 1
}

