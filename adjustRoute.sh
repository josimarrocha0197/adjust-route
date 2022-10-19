#!/bin/bash
logFile=/var/log/asterisk/rota_sbc_algar.log
algarRoute=179.108.97.46
algarSbc=201.48.56.86
destinationHosts=(34.160.111.145 201.48.56.86)

if ! ping -c 15 "${algarSbc}" 1> /dev/null 2> /dev/stdout
then
	if [[ $(ip route get ${algarSbc} | awk -F "via" '{ print $2 }' | awk -F " " '{ print $1 }') != ${algarRoute} ]]
	then
		echo -e "$(date) - ${algarSbc} saindo por: $(ip route get ${algarSbc}) \n" >> ${logFile}
                echo -e "$(date) - A navegação por esta rota está indisponível! \n" >> ${logFile}
		
		for destination in "${destinationHosts[@]}"
		do
			echo -e "$(date) - Criando rotas... \n" >> ${logFile}
                	echo -e "$(date) - route add -host ${destination} gw '${algarRoute}' \n" >> ${logFile}
                	route add -host ${destination} gw ${algarRoute}
			echo -e "$(date) - Rota adicionada! ${destination} saindo por: $(ip route get ${destination}) \n" >> ${logFile}
			exit
		done
	fi

	for destination in "${destinationHosts[@]}"
	do
		echo -e "$(date) - ${destination} saindo por: $(ip route get ${destination}) \n" >> ${logFile}
		echo -e "$(date) - Deletando rota... \n" >> ${logFile}
		echo -e "$(date) - route del -host ${destination} gw ${algarRoute} \n" >> ${logFile}
		route del -host ${destination} gw ${algarRoute}
		echo -e "$(date) - Rota deletada! ${destination} saindo por: $(ip route get ${destination}) \n" >> ${logFile}
	done
else
	echo -e "$(date) - Status da comunicação com ${algarSbc}: Disponível via $(ip route get ${algarSbc} | awk -F "via" '{ print $2 }' | awk -F " " '{ print $1 }')\n" >> ${logFile}
fi

#FIM
