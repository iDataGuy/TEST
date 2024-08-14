terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.87.2"
      configuration_aliases = [snowflake.snow_wh_admin]
    }
  }
}

resource "snowflake_warehouse" "wh" {
  provider = snowflake.snow_wh_admin
  name                = "${each.value.name}_WH"
  comment             = each.value.comment
  warehouse_size      = each.value.size
  auto_resume         = true
  auto_suspend        = 60   
  max_cluster_count   = each.value.max
  min_cluster_count   = each.value.min
  scaling_policy      = "ECONOMY"
  initially_suspended = true

  for_each            = local.warehouse_map
}

resource "snowflake_warehouse_grant" "wh_grant" {
  provider = snowflake.snow_wh_admin
  warehouse_name = "${each.value.name}_WH"
  privilege      = "USAGE"
  roles = each.value.role
  with_grant_option = false
  for_each          = local.warehouse_map
  depends_on = [
    snowflake_warehouse.wh
  ]
}
