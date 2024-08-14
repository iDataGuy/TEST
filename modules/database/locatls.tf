locals {
  # Default values used for deployment logic, the contents of variables.yml would seldom change
  #variables = yamldecode(file("variables.yml"))

  # The input variables to be defined by users are passed through user_input.yml
  user_input = yamldecode(file("./modules/database/user_input.yml"))

  # A list of new databases to be created
  environment = local.user_input.environments
  databases = tolist(local.user_input.databases)

  db_map = { for db in local.databases : db.name => {
    role  = tolist(db.role)
    name   = "${local.environment}_${db.name}"
    comment = db.comment
    retention_time = db.retention_time
    has_environment_schemas = db.has_environment_schema
    is_transient = db.is_transient

  } }

}
