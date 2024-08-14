terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.87.2"
    }
    snowsql = {
      source  = "aidanmelen/snowsql"
      version = ">= 0.1.0"
    }
  }
}

##################New Admin Roles###########
## Database Admin Role
provider "snowflake" {
  alias = "snow_db_admin"
  user = var.snowflake_username
  account  = var.snowflake_account
  password = var.snowflake_password
  role     = "SNOW_DB_ADMIN"
}


## Warehouse Admin Role
provider "snowflake" {
  alias = "snow_wh_admin"
  user = var.snowflake_username
  account  = var.snowflake_account
  password = var.snowflake_password
  role     = "SNOW_WH_ADMIN"
}

## Role Admin : Role
provider "snowflake" {
  alias = "snow_role_admin"
  user = var.snowflake_username
  account  = var.snowflake_account
  password = var.snowflake_password
  role     = "SNOW_ROLE_ADMIN"
}

