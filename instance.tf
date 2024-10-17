# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
# Documentação para criação do recurso key_pair

# Recurso Key pair é necessário para controlar os acessos a instância EC2 que será criada abaixo.
# Ele conterá a chave pública criada pelo owner, que ficará registrada na AWS para liberar acesso a instância EC2
resource "aws_key_pair" "keypair" {
  key_name   = "aws-key"

  # argumento obrigatório
  # Criação do par de chaves por linha de comando: "ssh-keygen -f aws-key"
  # Utilizar a função file() para referenciar o arquivo com a chave pública, localizada no mesmo diretório deste código
  public_key = file("./aws-key.pub")
}


# https://registry.terraform.io/providers/hashicorp/aws/2.36.0/docs/resources/instance
# Documentação de criação de instancia AWS EC2

# Criação do resource ec2 instance de fato

resource "aws_instance" "instance" {
  # Argumento obrigatório: 
  # Amazon Machine Image. Imagem de SO a qual a instância será baseada.
  ami                             = "ami-0c5410a9e09852edd"     # lista disponivel na console aws "ec2->instancias->executar instancias->clicar em cada uma na parte inferior e o ID será mostrado"  
  instance_type                   = "t2.micro"                  # Argumetno obrigatório. Tipo gratuito de instancia.
  key_name                        = aws_key_pair.keypair.key_name    # Referencia key pair criado anteriormente

  # Aqui, será necessário o remote state datasource criado no exerício de criação da VPC, para utilizarmos
  subnet_id                       = data.terraform_remote_state.vpc.outputs.subnet_id    # o ID da subnet configurado no outputs.tf daquele código
  vpc_security_group_ids          = [ data.terraform_remote_state.vpc.outputs.security_group_id ]    # Referencia as IDs dos grupos criados no exercício anterior. 
                                                                                            # [] pois o argumento espera uma lista de strings
  associate_public_ip_address     = true    # Indica que a instância EC2 terá IP público e poderá ser acessada através de "ssh"
  user_data = file ("./docs/docker.sh")

  tags = {
    Name = "ec2-terraform"
  }
}