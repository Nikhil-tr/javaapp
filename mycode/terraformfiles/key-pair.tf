#KEY_1
resource "tls_private_key" "dev-rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "dev-tf-key" {
  key_name = "dev-proj-key"    #Name of the key (Stored on aws console)
  public_key = tls_private_key.dev-rsa.public_key_openssh
}

resource "local_file" "dev-tf_key" {
 content  = tls_private_key.dev-rsa.private_key_pem
 filename = "dev-proj-key"     #Name of the key (Stored on the local-folder)
}

resource "tls_private_key" "prod-rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#KEY_2
resource "aws_key_pair" "prod-tf-key" {
  key_name = "prod-proj-key"    #Name of the key (Stored on aws console)
  public_key = tls_private_key.prod-rsa.public_key_openssh
}

resource "local_file" "prod-tf_key" {
 content  = tls_private_key.prod-rsa.private_key_pem
 filename = "prod-proj-key"     #Name of the key (Stored on the local-folder)
}
