resource "shoreline_notebook" "tomcat_ssl_handshake_failure_incident" {
  name       = "tomcat_ssl_handshake_failure_incident"
  data       = file("${path.module}/data/tomcat_ssl_handshake_failure_incident.json")
  depends_on = [shoreline_action.invoke_check_certificate,shoreline_action.invoke_update_cipher_suites]
}

resource "shoreline_file" "check_certificate" {
  name             = "check_certificate"
  input_file       = "${path.module}/data/check_certificate.sh"
  md5              = filemd5("${path.module}/data/check_certificate.sh")
  description      = "Check the SSL certificate configuration and make sure that it is valid and properly installed on the server."
  destination_path = "/agent/scripts/check_certificate.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "update_cipher_suites" {
  name             = "update_cipher_suites"
  input_file       = "${path.module}/data/update_cipher_suites.sh"
  md5              = filemd5("${path.module}/data/update_cipher_suites.sh")
  description      = "Verify that the cipher suites used by the client and server are compatible and properly configured. If necessary, update the cipher suite configuration on either the client or server to match the other."
  destination_path = "/agent/scripts/update_cipher_suites.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_check_certificate" {
  name        = "invoke_check_certificate"
  description = "Check the SSL certificate configuration and make sure that it is valid and properly installed on the server."
  command     = "`chmod +x /agent/scripts/check_certificate.sh && /agent/scripts/check_certificate.sh`"
  params      = ["PATH_TO_CERTIFICATE"]
  file_deps   = ["check_certificate"]
  enabled     = true
  depends_on  = [shoreline_file.check_certificate]
}

resource "shoreline_action" "invoke_update_cipher_suites" {
  name        = "invoke_update_cipher_suites"
  description = "Verify that the cipher suites used by the client and server are compatible and properly configured. If necessary, update the cipher suite configuration on either the client or server to match the other."
  command     = "`chmod +x /agent/scripts/update_cipher_suites.sh && /agent/scripts/update_cipher_suites.sh`"
  params      = ["CLIENT_CIPHER_SUITE","SERVER_CIPHER_SUITE"]
  file_deps   = ["update_cipher_suites"]
  enabled     = true
  depends_on  = [shoreline_file.update_cipher_suites]
}

