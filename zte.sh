#!/bin/bash

user=yotta				#login olt
senha=vcdsFGHJK6543 			#senha olt
host=172.31.255.2 			#ip da OLT
data=$(date +%Y-%m-%d) 				
pasta=/home/anderson/olt_zte_sarandi 	#pasta de destino dos arquivos
n_slot=2				#quantidade de slots de placas na olt
n_pon=16 				#numero porstas pon na olt
num_onu=128 				#numero maximo de clientes por porta
############# SUMARIO #####################
#porta_pon = ID da porta
#num_onu = quantidade de ONUs ativas em cada porta PON
#cli_id = ID da onu do cliente registrado
#
##########################################

#echo "data = $data"
cd $pasta || return
echo "Entrando na Pasta $pasta"

#limpar arquivo de clientes
echo "Limpando arquivo de clientes..."
echo -n > clientes.txt

#for slot_olt in $(seq $n_slot); 	#descomentar se houver mais de um slot de portas
#do					#descomentar se houver mais de um slot de portas
for porta_pon in $(seq $n_pon); 	#for para as postar da olt
do
for cli_id in $(seq $num_onu);		#for para os clientes da porta
do
	echo "Processando: Porta = $porta_pon / cliente = $cli_id";
	(
		echo "$user";
		sleep 1;
		echo "$senha";
		sleep 1;
		echo "configure terminal";
		sleep 1;
		echo "show gpon onu detail-info gpon-onu_1/$n_slot/$porta_pon:$cli_id" 
		sleep 1;
		echo "s";
		sleep 1;
		echo "show pon power attenuation gpon-onu_1/$n_slot/$porta_pon:$cli_id";	
		sleep 1) | telnet $host > $pasta/PON_"$porta_pon"/cliente_"$porta_pon"'_'"$cli_id"'_'"$data"


###### entrar na pasta da porta PON
cd  $pasta/PON_"$porta_pon" || return

###### remover caracteres
echo "Removendo caracteres inuteis..."
cat cliente_"$porta_pon"'_'"$cli_id"'_'"$data" | sed s/// > 2cliente_"$porta_pon"'_'"$cli_id"'_'"$data"
cat 2cliente_"$porta_pon"'_'"$cli_id"'_'"$data" | sed s/// > cliente_"$porta_pon"'_'"$cli_id"'_'"$data"
cat cliente_"$porta_pon"'_'"$cli_id"'_'"$data" | sed s/// > 2cliente_"$porta_pon"'_'"$cli_id"'_'"$data"
cat 2cliente_"$porta_pon"'_'"$cli_id"'_'"$data" | sed s/// > cliente_"$porta_pon"'_'"$cli_id"'_'"$data"

##### remover linhas inuteis
echo "Removendo linhas inuteis..."
sed -i 1,13d cliente_"$porta_pon"'_'"$cli_id"'_'"$data"
sed -i 17,20d cliente_"$porta_pon"'_'"$cli_id"'_'"$data"
sed -i 18,20d cliente_"$porta_pon"'_'"$cli_id"'_'"$data"
sed -i 23d cliente_"$porta_pon"'_'"$cli_id"'_'"$data"

#remove arquivo antigo com caracteres
echo "Removendo arquivo..."
rm 2cliente_"$porta_pon"'_'"$cli_id"'_'"$data"

#procura o nome do cliente para renomaer o arquivo
echo "Renomeando arquivo..."
nome_cliente=$(grep "Name:" cliente_"$porta_pon"'_'"$cli_id"'_'"$data" | tr -s ' ' | cut -d: -f2 | sed 's/ //')
mv  cliente_"$porta_pon"'_'"$cli_id"'_'"$data" "$nome_cliente"'_'"$data"

#colocando todos os clientes dentro de um arquivo
echo "Atualizando arquivo de nomes...$nome_cliente"
echo "$nome_cliente"
if [ "$nome_cliente" != '' ];then
	echo "$nome_cliente" >> "$pasta"/PON_"$porta_pon"/clientes.txt
fi



#voltar a pasta anterior
cd $pasta || return

done
done
#done				#descomentar se houver mais de um slot de placas

