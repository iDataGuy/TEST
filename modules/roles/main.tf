terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.87.2"
      configuration_aliases = [snowflake.snow_role_admin]
    }
  }
}

resource "snowflake_role" "role" {
  provider = snowflake.snow_role_admin
  name     =  each.value.name
  comment  = each.value.comment
  for_each = local.role_map
}


#resource "snowflake_role_grants" "grants" {
#  provider = snowflake.securityadmin
#  role_name = each.value.role
#  roles     = each.value.grantee
#  users     = ["SAYAN"] #Name of user who is the ACCOUNTADMIN.
#  for_each  = local.rolemaps
#  depends_on = [
#    snowflake_role.role,
#    snowflake_user.user
#  ]
#}
#
#resource "snowflake_role_grants" "system_grants" {
#  provider = snowflake.securityadmin
#  role_name = each.value.role
#  roles     = each.value.grantee
#  for_each  = local.system_rolemaps
#  depends_on = [
#    snowflake_role.role
#  ]
#}