variable "os_image" {
  default = "Debian-10.1-202004"
}
variable "external_network_name" {
  default = "ext-net"
}
variable "flavour_name" {
  default = "Standard-4-4"
}
variable "user_name" {
  default = ""
}
variable "password" {
  default = "8x-JvQ@coEA778!pZsnB"
}
variable "tenant_id" {
  default = ""
}
variable "user_domain_name" {
  default = "users"
}
variable "auth_url" {
  default = "https://infra.mail.ru:35357/v3/"
}
# TF_VAR_user_name=$OS_USERNAME TF_VAR_password=$OS_PASSWORD TF_VAR_tenant_id=$OS_PROJECT_ID terraform apply