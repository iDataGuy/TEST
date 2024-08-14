locals {
  # Load the variables from the YAML file
  variables = yamldecode(file("${path.module}/variables.yml"))

  # Environment
  env = local.variables.environments

  # Standard privileges for RW and RO roles
  standard_privileges = {
    RW_ROLE = sort(["CREATE SEQUENCE", "CREATE VIEW", "CREATE FILE FORMAT", "CREATE TAG", "CREATE TASK", "USAGE", "CREATE FUNCTION", "CREATE EXTERNAL TABLE", "CREATE PROCEDURE", "CREATE STAGE", "CREATE TABLE", "CREATE TEMPORARY TABLE", "CREATE PIPE", "MODIFY", "CREATE DYNAMIC TABLE", "MONITOR"])
    RO_ROLE = sort(["USAGE"])
  }

  # Generate schema-level privileges based on variables.yml input
  merged_privileges_list = distinct(flatten([
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
  ]))

  # Convert merged_privileges_list to a map with unique keys for schema-level grants
  merged_privileges = {
    for v in local.merged_privileges_list :
    "${v.role}_${v.database}_${v.schema}_${v.privilege}" => v
  }

  # Role hierarchy, removing duplicates
  role_hierarchy = {
    for v in distinct(local.variables.role_hierarchy) :
    "${v.parent_role}_${v.child_role}_${local.env}" => {
      parent_role = "${v.parent_role}"
      child_role  = "${v.child_role}"
    }
  }
}

