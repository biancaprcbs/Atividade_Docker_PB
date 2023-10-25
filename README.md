# Atividade_Docker_PB
Repositório destinado à atividade prática de Docker (Programa de Bolsas - AWS e DevSecOps).

## Descrição da atividade
__1.__ Instalação e configuração do DOCKER ou CONTAINERD no host EC2: ponto adicional para instalação via script de Start Instance (user_data.sh);  
__2.__ Deploy de uma aplicação Wordpress com: container de aplicação RDS database MySQL;  
__3.__ Configuração da utilização do serviço EFS AWS para estáticos do container da aplicação Wordpress;  
__4.__ Configuração do serviço de Load Balancer AWS para a aplicação Wordpress.

## Pontos importantes:
* Não utilizar IP público para saída do serviço WP (Evitar publicar o serviço WP via IP Público);
* Sugestão para o tráfego de internet: sair pelo LB (Load Balancer Classic);
* Pastas públicas e estáticos do Wordpress: sugestão de utilizar o EFS (Elastic File Sistem);
* Fica a critério de cada integrante usar Dockerfile ou Dockercompose;
* Necessário demonstrar a aplicação Wordpress funcionando (tela de login);
* A aplicação Wordpress precisa estar rodando na porta 80 ou 8080.

## Disposição da Arquitetura Básica
<img src="/img/arquitetura.jpg" width="750" title="Arquitetura Básica">

## Passos de Execução

### 1. Configuração da VPC
A VPC foi criada de acordo com as seguintes configurações:
* 2 sub-redes na zona de disponibilidade `us-east-1a`: uma pública (habilitação de endereço IPv4 público) e uma privada;
* 2 sub-redes na zona de disponibilidade `us-east-1b`: uma pública (habilitação de endereço IPv4 público) e uma privada;
* 2 tabelas de rotas: uma privada e uma pública;
* Associações das sub-redes privadas e públicas com a tabela de rotas correspondente;
* Criação de um gateway de internet e configuração da sua associação com a VPC correspondente;
* Adição da rota para a internet na tabela de rotas pública através da associação com o gateway de internet criado;
* Criação de um NAT gateway e configuração da sua associação com uma sub-rede pública (feita na zona `us-east-1a`), assim como a associação com um IP elástico;
* Adição da rota para a internet na tabela de rotas privada através da associação com o NAT gateway criado, garantindo somente o acesso de saída para a internet.

### 2. Configuração dos grupos de segurança
Os grupos de segurança criados referem-se a cada um dos serviços utilizados, permitindo o acesso específico às portas de entrada de acordo com as seguintes configurações:
* Grupo de segurança do Bastion Host
  
  | Tipo  | Protocolo | Porta | Origem | Descrição |
  | ----- | --------- | ----- | ------ | --------- |
  |  SSH  |    TCP    |   22  | MEU IP |    ssh    |

* Grupo de segurança do RDS
  
  | Tipo  | Protocolo | Porta | Origem | Descrição |
  | ----- | --------- | ----- | ------ | --------- |
  |  MYSQL/Aurora  |    TCP    |   3306  | 0.0.0.0/0 |    rds    |
  
* Grupo de segurança do EFS
  
  | Tipo  | Protocolo | Porta | Origem | Descrição |
  | ----- | --------- | ----- | ------ | --------- |
  |  NFS  |    TCP    |   2049  | 0.0.0.0/0 |    efs    |
  | UDP personalizado | UDP | 2049 | 0.0.0.0/0 | efs |
  
* Grupo de segurança do Load Balancer
  
  | Tipo  | Protocolo | Porta | Origem | Descrição |
  | ----- | --------- | ----- | ------ | --------- |
  |  HTTP  |    TCP    |   80  | 0.0.0.0/0 |    http    |
  
* Grupo de segurança das instâncias referentes às aplicações

  | Tipo  | Protocolo | Porta | Origem | Descrição |
  | ----- | --------- | ----- | ------ | --------- |
  |  SSH  |    TCP    |   22  | grupo de segurança do Bastion Host |    ssh    |
  |  NFS  |    TCP    |   2049  | grupo de segurança do EFS |    efs    |
  | UDP personalizado | UDP | 2049 | grupo de segurança do EFS | efs |
  |  HTTP  |    TCP    |   80  | grupo de segurança do Load Balancer |    http    |
  |  MYSQL/Aurora  |    TCP    |   3306  | grupo de segurança do RDS |    rds    |

### 3. Configuração dos pares de chaves
Foram criados dois pares de chaves distintos para acesso às instâncias privadas e públicas, de acordo com as seguintes configurações:
* `chave_execucao.pem`: tipo RSA, chave para o acesso das instâncias públicas;
* `chave_aplicacao.pem`: tipo RSA, chave para o acesso das instâncias privadas.

### 4. Configuração do Bastion Host
A configuração do Bastion Host refere-se à execução de uma instância que conta com as seguintes características:
* Tags de acordo com a utilização (CostCenter e Project);
* AMI: Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type, 64 bits (x86);
* Tipo de instância: t2.micro;
* Par de chaves: chave_execucao.pem;
* Associação à VPC criada anteriormente, com uma sub-rede pública;
* Atribuição de IP público habilitado;
* Grupo de segurança: grupo do Bastion Host criado anteriormente;
* Armazenamento: 16GB GP2.

Após acessar a instância através do IP público, o par de chaves `chave_aplicacao.pem` foi movido para a instância de forma a garantir o acesso SSH das instâncias privadas pelo Bastion Host.

### 5. Configuração do RDS
O RDS armazenará os arquivos referentes ao WordPress e a criação do banco de dados contém as seguintes características:
* Método de criação: padrão;
* Tipo de mecanismo: MySQL;
* Modelo: nível gratuito;
* Definição de um nome para a instância de banco de dados;
* Definição de nome e senha para o usuário principal;
* Associação com a VPC criada anteriormente;
* Associação com o grupo de segurança do RDS criado anteriomente;
* Associação com a sub-rede `us-east-1a`;
* Acesso público habilitado;
* Definição de um nome inicial do banco de dados.

### 6. Configuração do EFS
O EFS armazenará os arquivos estáticos do WordPress e sua criação contém as seguintes características:
* Definição de um nome para o sistema de arquivos;
* Associação com a VPC criada anteriormente;
* Alteração na seção de Rede do sistema de arquivos para alterar o grupo de segurança específico do EFS criado anteriormente.
