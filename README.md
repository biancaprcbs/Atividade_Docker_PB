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
