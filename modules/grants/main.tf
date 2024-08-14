terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.87.2"
      configuration_aliases = [snowflake.snow_db_admin, snowflake.snow_role_admin]
    }
  }
}

# Grant database-level privileges
resource "snowflake_database_grant" "db_grants" {
  provider = snowflake.snow_db_admin
  for_each = local.privilegemaps_db

  database_name = each.value.database
  roles         = [each.value.role]
  privilege     = each.value.privilege

  lifecycle {
    ignore_changes = [roles]  # Prevent Terraform from detecting changes if the list ordering differs
  }
}

# Grant schema-level privileges
resource "snowflake_schema_grant" "schema_grants" {
  provider = snowflake.snow_db_admin
  for_each = local.merged_privileges
  #schema_name    = each.value.schema
  database_name  = each.value.database
  roles          = [each.value.role]
  privilege      = each.value.privilege
  on_future      = true
  lifecycle {
    ignore_changes = [roles]  # Prevent Terraform from detecting changes if the list ordering differs
  }
}

# Grant role hierarchy
resource "snowflake_role_grants" "role_hierarchy_grants" {
  provider = snowflake.snow_role_admin
  for_each = local.role_hierarchy

  role_name = each.value.child_role
  roles     = [each.value.parent_role]

  lifecycle {
    ignore_changes = [roles]  # Prevent Terraform from detecting changes if the list ordering differs
  }
}
