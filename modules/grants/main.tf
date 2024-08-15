terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.89.0"
      configuration_aliases = [
        snowflake.snow_db_admin, 
        snowflake.snow_role_admin
      ]
    }
  }
}

resource "snowflake_role_grants" "role_hierarchy_grants" {
  provider = snowflake.snow_role_admin
  for_each = local.role_hierarchy

  role_name = each.value.child_role
  roles     = [each.value.parent_role]

  lifecycle {
    ignore_changes = [roles]
  }
}

resource "snowflake_grant_privileges_to_account_role" "schema_grant" {
  provider          = snowflake.snow_db_admin
  for_each          = local.merged_privileges

  privileges        = [each.value.privilege]
  account_role_name = each.value.role
  on_schema {
    schema_name = "\"${each.value.database}\".\"${each.value.schema}\""
  }
}

# Grant SELECT privilege on future tables
resource "snowflake_grant_privileges_to_account_role" "select_on_future_tables" {
  provider          = snowflake.snow_db_admin
  for_each          = local.merged_privileges

  privileges        = ["SELECT"]
  account_role_name = each.value.role
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = "\"${each.value.database}\".\"${each.value.schema}\""
    }
  }
}

# Grant SELECT privilege on future views
resource "snowflake_grant_privileges_to_account_role" "select_on_future_views" {
  provider          = snowflake.snow_db_admin
  for_each          = local.merged_privileges

  privileges        = ["SELECT"]
  account_role_name = each.value.role
  on_schema_object {
    future {
      object_type_plural = "VIEWS"
      in_schema          = "\"${each.value.database}\".\"${each.value.schema}\""
    }
  }
}


# Grant ownership on specific object types to RW roles
resource "snowflake_grant_ownership" "schema_object_ownership" {
  provider = snowflake.snow_db_admin
  for_each = local.ownership_grants_map

  account_role_name = each.value[0].role
  on {
    future {
      object_type_plural = each.value[0].object_type
      in_schema          = "\"${each.value[0].database}\".\"${each.value[0].schema}\""
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = all
  }
}
