#!/bin/bash
#como eu separo o banco do front uso dois endereços distintos.
zabbix_server=x.x.x.x						#IP Servidor Zabbix
URL='http://x.x.x.x/zabbix/api_jsonrpc.php'  #URL da api zabbix
pasta=						#Pasta onde foram criadas a estrutura des portas PON
data=$(date +%Y-%m-%d)								#data
n_pon=16									#numero de portas, altere conforme a necessidade

HEADER='Content-Type:application/json'

USER="user"								#Usuario zabbix
PASS="senha"									#senha
grupo="nome_grupo" 								#nome do grupo que serão colocados os clientes				

autenticacao()
{
    JSON='
	{
    "jsonrpc": "2.0",
    "method": "user.login",
    "params": {
        "user": "'$USER'",
        "password": "'$PASS'"
    },
    "id": 1,
    "auth": null
}
    
'
    curl -s -X POST -H "$HEADER" -d "$JSON" "$URL" | cut -d '"' -f8
}

#cria grupo se não existir
criar_grupo()
{
    JSON='
        {
        "jsonrpc": "2.0",
        "method": "hostgroup.create",
        "params": {
            "name": "'$grupo'"
    },
    "auth": "'$TOKEN'",
    "id": 1
}
    '
    curl -s -X POST -H "$HEADER" -d "$JSON" "$URL" > /dev/null
}

criar_hosts()
{
    JSON='
    {
        "jsonrpc": "2.0",
        "method": "host.create",
        "params": {
            "host": "'$cliente'",
            "interfaces": [
                {
                    "type": 1,
                    "main": 1,
                    "useip": 1,
                    "ip": "127.0.0.1",
                    "dns": "",
                    "port": 10050
                }
            ],
            "groups": [
                {
                    "groupid": "'$id_grupo'"
                }
            ],
            "templates": [
                {
                    "templateid": "'$id_template'"
                }
            ]
        },
        "auth": "'$TOKEN'",
        "id": 1        
    }
    '
    curl -s -X POST -H "$HEADER" -d "$JSON" "$URL" > /dev/null
}

busca_id_template()
{
    JSON='
        {
           "jsonrpc": "2.0",
           "method": "template.get",
           "params": {
               "output": "extend",
               "filter": {
                  "host": [
                     "Clientes OLT"
                  ]
        }
    },
    "auth": "'$TOKEN'",
    "id": 1
}
    '
    curl -s -X POST -H "$HEADER" -d "$JSON" "$URL" | cut -d '"' -f130
}

busca_id_grupo()
{
  JSON='
    {
        "jsonrpc": "2.0",
        "method": "hostgroup.get",
        "params": {
          "output": "extend",
            "filter": {
              "name": [
                 "Cliente OLT"
                   ]
             }
    },
    "auth": "'$TOKEN'",
    "id": 1
        }
      '
    curl -s -X POST -H "$HEADER" -d "$JSON" "$URL" | cut -d '"' -f10 
}

#echo "Iniciando"
TOKEN=$(autenticacao)
#echo "token $TOKEN "
grupo=$(criar_grupo)
#echo "Grupo $grupo"
id_grupo=$(busca_id_grupo)
#echo "id grupo $id_grupo"
id_template=$(busca_id_template)
#echo "id template $id_template"


for porta_pon in $(seq $n_pon);						#le a quantidade de portas da olt
do
	echo "[$data $hora] Entrando na pasta PON_$porta_pon" >> log_zabbix_sender.log
	cd $pasta/PON_$porta_pon || return

while read cliente 									#ler arquivo de clientes ativos
do
	echo $'\n'
	echo "[$data $hora] lendo arquivo" >> log_zabbix_sender.log
	echo "[$data $hora] $cliente" >> log_zabbix_sender.log
	echo "[$data $hora] $pasta"/PON_"$porta_pon"/"$cliente"'_'"$data" >> log_zabbix_sender.log
		sinal_onu2=$(grep "up" "$pasta"/PON_"$porta_pon"/"$cliente"'_'"$data" | cut -d':' -f2)		#filtra sinl ONU
		sinal_olt2=$(grep "down" "$pasta"/PON_"$porta_pon"/"$cliente"'_'"$data" | cut -d':' -f3)		#filtra sinal OLT
	echo "sinal onu cliente $cliente"
		sinal_olt=$(echo "$sinal_olt2" | cut -c1-7) 
		sinal_onu=$(echo "$sinal_onu2" | cut -c1-7)

host=$cliente
#echo "Host $host "
#echo "sinal olt $sinal_olt"
#echo "sinal onu $sinal_onu"								#recebe o nome do cliente

criar_hosts
echo "[$data $hora]" >> log_zabbix_sender.log
zabbix_sender -z $zabbix_server -s "$host" -k sinal.olt -o "$sinal_olt" >> log_zabbix_sender.log	#envia para o zabbix
echo "[$data $hora]" >> log_zabbix_sender.log
zabbix_sender -z $zabbix_server -s "$host" -k sinal.onu -o "$sinal_onu" >> log_zabbix_sender.log

done < clientes.txt 								#recebe o arquivo para leitura dos clientes 
done


