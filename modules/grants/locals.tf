# locals {
#   # Load the variables from the YAML file
#   variables = yamldecode(file("${path.module}/variables.yml"))

#   # Environment
#   env = local.variables.environments

#   # Standard privileges for RW and RO roles
#   standard_privileges = {
#     RW_ROLE = sort(["CREATE SEQUENCE", "CREATE VIEW", "CREATE FILE FORMAT", "CREATE TAG", "CREATE TASK", "USAGE", "CREATE FUNCTION","CREATE PROCEDURE", "CREATE STAGE", "CREATE TABLE", "CREATE TEMPORARY TABLE", "CREATE PIPE", "MODIFY", "CREATE DYNAMIC TABLE", "MONITOR", "CREATE STREAM"])
#     RO_ROLE = sort(["USAGE"])
#   }

#   # Generate schema-level privileges based on variables.yml input
#   merged_privileges_list = distinct(flatten([
#     for v in local.variables.schema_privileges : [
#       for schema in sort(v.schemas) : [
#         for priv in local.standard_privileges[v.role_category] : [
#           for role in sort(v.role) : {
#             privilege = priv
#             role      = role
#             database  = "${local.env}_${v.database}"
#             schema    = schema
#           }
#         ]
#       ]
#     ]
#   ]))

#   # Convert merged_privileges_list to a map with unique keys for schema-level grants
#   merged_privileges = {
#     for v in local.merged_privileges_list :
#     "${v.role}_${v.database}_${v.schema}_${v.privilege}" => v
#   }

#   # Role hierarchy, removing duplicates
#   role_hierarchy = {
#     for v in distinct(local.variables.role_hierarchy) :
#     "${v.parent_role}_${v.child_role}_${local.env}" => {
#       parent_role = "${v.parent_role}"
#       child_role  = "${v.child_role}"
#     }
#   }

# ######## Object types for which RW_ROLE should have ownership
#   object_type_plural = ["TABLES", "TAGS", "TASKS", "VIEWS", "SEQUENCES", "STAGES", "PROCEDURES", "STREAMS", "FUNCTIONS", "FILE FORMATS", "PIPES"]

#   # Generate the necessary data structure for ownership grants
#   ownership_grants = flatten([
#     for merged_priv in local.merged_privileges : [
#       for object_type in local.object_type_plural : {
#         role        = merged_priv.role
#         database    = merged_priv.database
#         schema      = merged_priv.schema
#         object_type = object_type
#       }
#       if contains(["RW_ROLE"], merged_priv.role)
#     ]
#   ])

#   # Convert the list to a map with unique keys for for_each in the resource
#   ownership_grants_map = {
#     for grant in local.ownership_grants : 
#     "${grant.role}_${grant.database}_${grant.schema}_${grant.object_type}" => grant
#   }


# }

locals {
  # Load the variables from the YAML file
  variables = yamldecode(file("${path.module}/variables.yml"))

  # Environment
  env = local.variables.environments

  # Standard privileges for RW and RO roles
  standard_privileges = {
    RW_ROLE = sort(["CREATE SEQUENCE", "CREATE VIEW", "CREATE FILE FORMAT", "CREATE TAG", "CREATE TASK", "USAGE", "CREATE FUNCTION", "CREATE PROCEDURE", "CREATE STAGE", "CREATE TABLE", "CREATE TEMPORARY TABLE", "CREATE PIPE", "MODIFY", "CREATE DYNAMIC TABLE", "MONITOR", "CREATE STREAM"])
    RO_ROLE = sort(["USAGE"])
  }

  # Generate schema-level privileges based on variables.yml input
  merged_privileges_list = distinct(flatten([
    for v in local.variables.schema_privileges : [
      for schema in sort(v.schemas) : [
        for priv in local.standard_privileges[v.role_category] : [
          for role in sort(v.role) : {
            privilege = priv,
            role      = role,
            database  = "${local.env}_${v.database}",
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
      parent_role = "${v.parent_role}",
      child_role  = "${v.child_role}"
    }
  }

  ######## Object types for which RW_ROLE should have ownership
  object_type_plural = ["TABLES", "VIEWS", "SEQUENCES", "STAGES", "PROCEDURES", "STREAMS", "FUNCTIONS", "FILE FORMATS", "PIPES"]

  # Generate the necessary data structure for ownership grants
  ownership_grants = flatten([
    for merged_priv in local.merged_privileges : [
      for object_type in local.object_type_plural : {
        role        = merged_priv.role,
        database    = merged_priv.database,
        schema      = merged_priv.schema,
        object_type = object_type
      }
      if can(regex(".*_RW$", merged_priv.role))  # Adjusted condition to match roles ending in _RW
    ]
  ])

  # Convert the list to a map with unique keys for for_each in the resource, handling duplicates by grouping them
  ownership_grants_map = {
    for grant in local.ownership_grants :
    "${grant.role}_${grant.database}_${grant.schema}_${grant.object_type}" => grant...
  }
}
