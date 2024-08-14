locals {
  # Load the variables from the YAML file
  variables = yamldecode(file("${path.module}/variables.yml"))

  # Environment
  env = local.variables.environments

  # Standard privileges for RW and RO roles
  standard_privileges = {
    RW_ROLE = sort(["CREATE SEQUENCE", "CREATE VIEW", "CREATE FILE FORMAT", "CREATE TAG", "CREATE TASK", "USAGE", "CREATE FUNCTION", "CREATE EXTERNAL TABLE", "CREATE PROCEDURE", "CREATE STAGE", "CREATE TABLE", "CREATE TEMPORARY TABLE", "CREATE PIPE", "MODIFY", "CREATE DYNAMIC TABLE", "MONITOR", "CREATE STREAMLIT"])
    RO_ROLE = sort(["USAGE", "SELECT"])
  }

  # Generate privileges for each role, schema, and database based on variables.yml input
  merged_privileges_list = flatten([
    for v in local.variables.schema_privileges : [
      for schema in sort(v.schemas) : [
        for priv in local.standard_privileges[v.role_category] : [
          for role in sort(v.role) : {
            privilege = priv
            role      = role
            database  = "${local.env}_${v.database}"
            schema    = schema
          }
        ]
      ]
    ]
  ])

  # Convert merged_privileges_list to a map with unique keys
  merged_privileges = { for v in local.merged_privileges_list : "${v.role}_${v.database}_${v.schema}_${v.privilege}" => v }

  # Default database-level privileges (USAGE)
  privilegemaps_db_list = flatten([
    for v in local.variables.schema_privileges : [
      for role in sort(v.role) : {
        privilege = "USAGE"
        role      = role
        database  = "${local.env}_${v.database}"
      }
    ]
  ])

  # Convert the list to a map with proper keys
  privilegemaps_db = { for v in local.privilegemaps_db_list : "${v.role}_${v.database}_${v.privilege}" => {
    role      = v.role,
    database  = v.database,
    privilege = v.privilege
  } }

  # Role hierarchy
  role_hierarchy = {
    for v in local.variables.role_hierarchy : "${v.parent_role}_${v.child_role}_${local.env}" => {
      parent_role = "${v.parent_role}"
      child_role  = "${v.child_role}"
    }
  }
}
