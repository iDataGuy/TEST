locals {
  # Default values used for deployment logic, the contents of variables.yml would seldom change
  variables = yamldecode(file("./modules/warehouse/variables.yml"))

  #environment
  environment = local.variables.environments

  warehouse_map = { for v in local.variables.warehouse : v.name => {
    name  = "${local.environment}_${v.name}"
    role  = tolist(v.role)
    max   = v.max
    min   = v.min
    multi = v.multi
    size  = v.size
    comment = v.comment
    }
  }

}
