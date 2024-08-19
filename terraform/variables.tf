variable tags {
  type    = map(string)
  default = {
    "env": "dev",
    "source": "terraform"
  }
}

variable "sql_administrator_login_password" {
  type      = string
  sensitive = true
}