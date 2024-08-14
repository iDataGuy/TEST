module "roles" {
  source = "./modules/roles"
  providers = {
    snowflake.snow_role_admin = snowflake.snow_role_admin
  }
}

module "database" {
  source   = "./modules/database"
  providers = {
    snowflake.snow_db_admin      = snowflake.snow_db_admin
  }
  depends_on = [
    module.roles
  ]
}

module "warehouse" {
  source = "./modules/warehouse"
  providers = {
    snowflake.snow_wh_admin = snowflake.snow_wh_admin
  }
  depends_on = [
    module.roles
  ]
}


module "schema" {
 source = "./modules/schema"
 providers = {
   snowflake.snow_db_admin  = snowflake.snow_db_admin
 }
 depends_on = [
   module.database
 ]
}

#
module "grants" {
 source = "./modules/grants"
 providers = {
   snowflake.snow_db_admin  = snowflake.snow_db_admin
   snowflake.snow_role_admin = snowflake.snow_role_admin

 }
 depends_on = [
   module.roles,
   module.schema
 ]
}