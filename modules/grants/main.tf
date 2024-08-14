terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.87.2"
      configuration_aliases = [
        snowflake.snow_db_admin, 
        snowflake.snow_role_admin
      ]
    }
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

# Grant privileges to account role at the schema level
resource "snowflake_grant_privileges_to_account_role" "schema_grant" {
  provider          = snowflake.snow_db_admin
  for_each          = local.merged_privileges

  privileges        = [each.value.privilege]
  account_role_name = each.value.role
  on_schema {
    schema_name = "\"${each.value.database}\".\"${each.value.schema}\""
  }
}
