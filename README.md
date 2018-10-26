# olt_zte
scripts para busca do sinal do cliente de onu zte modelo f601 e envio para zabbix

### COMO UTILIZAR
  - crie uma estrutura de Pastas:
    - mkdir PON_{1..N} #N = numero de portas da olt


![image](https://user-images.githubusercontent.com/8582515/47580860-60c04c80-d926-11e8-92a9-ebaaad328f6c.png)

### Tenha o zabbix_agent instalado

entre com os dados necessários nos arquivos sc_zabbix.sh e zte.sh

### Faça upload do template no zabbix

configure o cron para rodar nos horários desejados os dois scripts (configurei para 4 em 4 horas o zte.sh e a cada 20 min o sc_zabbix.sh)

### O QUE O SCRIPT zte.sh FAZ
 - acessa a olt e busca os dados do sinal optico de cada onu registrada 
 - filtra os dados do retorno de sinal da ONU*
 - cria um arquivo com o nomedocliente_data nas pastas
 
 ### O QUE O SCRIPT zte.sh NÃO FAZ
 - remover arquivos de clientes que foram deletados da OLT
 - remover arquivos antigos
 
 ### O QUE O SCRIPT sc_zabbix.sh FAZ
 - cria um grupo para os hosts
 - busca o id do template no zabbix
 - busca o id do grupo do zabbix
 - cria o host com nome da onu que esta registrado na OLT
 - filtra os dados de entrada com o sinal tx/rx do laser óptico
 - envia os dados para o host criado através do zabbix_sender
 
 ### O QUE O SCRIPT sc_zabbix.sh NÃO FAZ
 - excluir hosts antigos(que não estão mais na OLT)
 
 # *TESTADO NO MODELO ZTE F601 (BRIDGE)
 
 Como fica o grafico no zabbix após o termino
 ![image](https://user-images.githubusercontent.com/8582515/47582911-25288100-d92c-11e8-8b46-34f5a71f81ec.png)
 
 
