locals {
#  # Default values used for deployment logic, the contents of variables.yml would seldom change
  variables = yamldecode(file("./modules/schema/variables.yml"))
#
#


# #environment
#   environment = local.variables.environments
#   database = "${local.environment}_${local.variables.database}"

#   schema_details = { for schm in local.variables.database : schm.name => {
#     database = "${local.environment}_${db.name}"
#     name = schm.name
#     comment = schm.comment
#     } 
#   }

# }

  # Environment
  environment = local.variables.environments


# Flatten the structure so that we can iterate over each schema in each database
  schema_details = flatten([
    for db in local.variables.databases : [
      for schm in db.schemas : {
        database = "${local.environment}_${db.name}"
        name     = schm.name
        comment  = schm.comment
      }
    ]
  ])
}