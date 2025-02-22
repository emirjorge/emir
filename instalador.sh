#!/bin/bash

# EMPIEZA EL CODIGO
clear && clear
apt install net-tools -y &>/dev/null
myip=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -n1)
myint=$(ifconfig | grep -B1 "inet addr:$myip" | head -n1 | awk '{print $1}')
rm -rf /etc/localtime &>/dev/null
ln -s /usr/share/zoneinfo/America/Lima /etc/localtime &>/dev/null
rm -rf /usr/local/lib/systemubu1 &>/dev/null
rm -rf /etc/versin_script &>/dev/null
v1=$(curl -sSL "https://raw.githubusercontent.com/emirjorge/premium/master/version")
echo "$v1" >/etc/versin_script
[[ ! -e /etc/versin_script ]] && echo 1 >/etc/versin_script
v22=$(cat /etc/versin_script)
vesaoSCT="\033[1;31m [ \033[1;32m($v22)\033[1;97m\033[1;31m ]"

mkdir -p /etc/VPS-MX/protocolos
SCPdir="/etc/VPS-MX"
[[ ! -e ${SCPdir}/tmp ]] && mkdir ${SCPdir}/tmp

# LA CONDICIONAL [  ] hace q si existe el archivo, por consecuencia && no hace la accion 
[[ ! -e /bin/desbloqueo.sh ]] && wget -O /bin/desbloqueo.sh https://raw.githubusercontent.com/emirjorge/premium/master/librerias/desbloqueo.sh &> /dev/null
chmod +x /bin/desbloqueo.sh
[[ ! -e /bin/monitor.sh ]] && wget -O /bin/monitor.sh https://raw.githubusercontent.com/emirjorge/premium/master/librerias/monitor.sh &> /dev/null
chmod +x /bin/monitor.sh
#[[ ! -e /etc/VPS-MX/protocolos/wireguard.sh ]] && wget -O /etc/VPS-MX/protocolos/wireguard.sh https://raw.githubusercontent.com/emirjorge/premium/master/update/wireguard.sh &> /dev/null
#chmod +x /etc/VPS-MX/protocolos/wireguard.sh
#[[ ! -e /etc/VPS-MX/protocolos/checkuser.sh ]] && wget -O /etc/VPS-MX/protocolos/checkuser.sh https://raw.githubusercontent.com/emirjorge/premium/master/update/checkuser.sh &> /dev/null
#chmod +x /etc/VPS-MX/protocolos/checkuser.sh
#[[ ! -e /etc/VPS-MX/protocolos/checkuser.py ]] && wget -O /etc/VPS-MX/protocolos/checkuser.py https://raw.githubusercontent.com/emirjorge/premium/master/update/chekuser.py &> /dev/null
#chmod +x /etc/VPS-MX/protocolos/checkuser.py
[[ ! -e /var/www/html/estilos.css ]] && wget -O /var/www/html/estilos.css https://raw.githubusercontent.com/emirjorge/premium/master/librerias/estilos.css &> /dev/null
[[ ! -e ${SCPdir}/tmp/style ]] && wget -O ${SCPdir}/tmp/style https://raw.githubusercontent.com/emirjorge/premium/master/update/style &> /dev/null


### COLORES Y BARRA
msg() {
  BRAN='\033[1;37m' && VERMELHO='\e[31m' && VERDE='\e[32m' && AMARELO='\e[33m'
  AZUL='\e[34m' && MAGENTA='\e[35m' && MAG='\033[1;36m' && NEGRITO='\e[1m' && SEMCOR='\e[0m'
  case $1 in
  -ne) cor="${VERMELHO}${NEGRITO}" && echo -ne "${cor}${2}${SEMCOR}" ;;
  -ama) cor="${AMARELO}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}" ;;
  -verm) cor="${AMARELO}${NEGRITO}[!] ${VERMELHO}" && echo -e "${cor}${2}${SEMCOR}" ;;
  -azu) cor="${MAG}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}" ;;
  -verd) cor="${VERDE}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}" ;;
  -bra) cor="${VERMELHO}" && echo -ne "${cor}${2}${SEMCOR}" ;;
  -nazu) cor="${COLOR[6]}${NEGRITO}" && echo -ne "${cor}${2}${SEMCOR}" ;;
  -gri) cor="\e[5m\033[1;100m" && echo -ne "${cor}${2}${SEMCOR}" ;;
  "-bar2" | "-bar") cor="${VERMELHO}————————————————————————————————————————————————————" && echo -e "${SEMCOR}${cor}${SEMCOR}" ;;
  esac
}
fun_bar() {
  comando="$1"
  _=$(
    $comando >/dev/null 2>&1
  ) &
  >/dev/null
  pid=$!
  while [[ -d /proc/$pid ]]; do
    echo -ne " \033[1;33m["
    for ((i = 0; i < 20; i++)); do
      echo -ne "\033[1;31m##"
      sleep 0.5
    done
    echo -ne "\033[1;33m]"
    sleep 1s
    echo
    tput cuu1
    tput dl1
  done
  echo -e " \033[1;33m[\033[1;31m########################################\033[1;33m] - \033[1;32m100%\033[0m"
  sleep 1s
}

print_center() {
  if [[ -z $2 ]]; then
    text="$1"
  else
    col="$1"
    text="$2"
  fi

  while read line; do
    unset space
    x=$(((54 - ${#line}) / 2))
    for ((i = 0; i < $x; i++)); do
      space+=' '
    done
    space+="$line"
    if [[ -z $2 ]]; then
      msg -azu "$space"
    else
      msg "$col" "$space"
    fi
  done <<<$(echo -e "$text")
}

title() {
  clear
  msg -bar
  if [[ -z $2 ]]; then
    print_center -azu "$1"
  else
    print_center "$1" "$2"
  fi
  msg -bar
}

stop_install() {
  title "INSTALACION CANCELADA"
  exit
}

time_reboot() {
  print_center -ama "REINICIANDO VPS EN $1 SEGUNDOS"
  REBOOT_TIMEOUT="$1"

  while [ $REBOOT_TIMEOUT -gt 0 ]; do
    print_center -ne "-$REBOOT_TIMEOUT-\r"
    sleep 1
    : $((REBOOT_TIMEOUT--))
  done
  reboot
}

os_system() {
  system=$(cat -n /etc/issue | grep 1 | cut -d ' ' -f6,7,8 | sed 's/1//' | sed 's/      //')
  distro=$(echo "$system" | awk '{print $1}')

  case $distro in
  Debian) vercion=$(echo $system | awk '{print $3}' | cut -d '.' -f1) ;;
  Ubuntu) vercion=$(echo $system | awk '{print $2}' | cut -d '.' -f1,2) ;;
  esac
}

repo() {
  link="https://raw.githubusercontent.com/emirjorge/premium/master/lista/$1.list"
  case $1 in
  8 | 9 | 10 | 11 | 16.04 | 18.04 | 20.04 | 20.10 | 21.04 | 21.10 | 22.04) wget -O /etc/apt/sources.list ${link} &>/dev/null ;;
  esac
}

dependencias() {
  soft="sudo bsdmainutils zip unzip ufw curl python python3 python3-pip openssl screen cron iptables lsof pv boxes nano at mlocate gawk grep bc jq curl npm nodejs socat netcat netcat-traditional net-tools cowsay figlet lolcat apache2"

  for i in $soft; do
    leng="${#i}"
    puntos=$((21 - $leng))
    pts="."
    for ((a = 0; a < $puntos; a++)); do
      pts+="."
    done
    msg -nazu "    Instalando $i$(msg -ama "$pts")"
    if apt install $i -y &>/dev/null; then
      msg -verd " INSTALADO"
    else
      msg -verm2 " ERROR"
      sleep 2
      tput cuu1 && tput dl1
      print_center -ama "aplicando fix a $i"
      dpkg --configure -a &>/dev/null
      sleep 2
      tput cuu1 && tput dl1

      msg -nazu "    Instalando $i$(msg -ama "$pts")"
      if apt install $i -y &>/dev/null; then
        msg -verd " INSTALADO"
      else
        msg -verm2 " ERROR"
      fi
    fi
  done
}

post_reboot() {
  echo 'wget -O /root/instalador.sh "https://raw.githubusercontent.com/emirjorge/premium/master/instalador.sh"; clear; sleep 2; chmod +x /root/instalador.sh; /root/instalador.sh --continue' >>/root/.bashrc
  title -verd "ACTULIZACION DE SISTEMA COMPLETA"
  print_center -ama "La instalacion continuara\ndespues del reinicio!!!"
  msg -bar
}

install_start() {
  msg -bar

  echo -e "\e[1;97m           \e[5m\033[1;100m   ACTULIZACION DE SISTEMA   \033[1;37m"
  msg -bar
  print_center -ama "Se actualizaran los paquetes del sistema.\n Puede demorar y pedir algunas confirmaciones.\n"
  msg -bar3
  msg -ne "\n Desea continuar? [S/N]: "
  read opcion
  [[ "$opcion" != @(s|S) ]] && stop_install
  clear && clear
  msg -bar
  echo -e "\e[1;97m           \e[5m\033[1;100m   ACTULIZACION DE SISTEMA   \033[1;37m"
  msg -bar
  os_system
  repo "${vercion}"
  apt update -y
  apt upgrade -y
}

install_continue() {
  os_system
  msg -bar
  echo -e "      \e[5m\033[1;100m   COMPLETANDO PAQUETES PARA EL SCRIPT   \033[1;37m"
  msg -bar
  print_center -ama "$distro $vercion"
  print_center -verd "INSTALANDO DEPENDENCIAS"
  msg -bar3
  dependencias
  msg -bar3
  sed -i "s;Listen 80;Listen 81;g" /etc/apache2/ports.conf >/dev/null 2>&1
  service apache2 restart >/dev/null 2>&1
  print_center -azu "Removiendo paquetes obsoletos"
  apt autoremove -y &>/dev/null
  sleep 2
  tput cuu1 && tput dl1
  msg -bar
  print_center -ama "Si algunas de las dependencias fallo!!!\nal terminar, puede intentar instalar\nla misma manualmente usando el siguiente comando\napt install nom_del_paquete"
  msg -bar
  read -t 60 -n 1 -rsp $'\033[1;39m       << Presiona enter para Continuar >>\n'
}

while :; do
  case $1 in
  -s | --start) install_start && post_reboot && time_reboot "5" ;;
  -c | --continue)
    rm /root/instalador.sh &>/dev/null
    sed -i '/Instalador/d' /root/.bashrc
    install_continue
    break
    ;;
  # -u | --update)
  #   install_start
  #   install_continue
  #   break
  # ;;
  *) exit ;;
  esac
done

clear && clear
msg -bar2
echo -e " \e[5m\033[1;100m   =====>> ►► 🐲 MULTI - SCRIPT  🐲 ◄◄ <<=====   \033[1;37m"
msg -bar2
print_center -ama "LISTADO DE SCRIPT DISPONIBLES"
msg -bar

#-BASH SOPORTE ONLINE
wget https://raw.githubusercontent.com/emirjorge/premium/master/librerias/SPR.sh -O /usr/bin/SPR >/dev/null 2>&1
chmod +x /usr/bin/SPR

#VPS-PREMIUM 8.6x
install_mod() {
  clear && clear
  msg -bar
  echo -ne "\033[1;97m Digite su slogan: \033[1;32m" && read slogan
  tput cuu1 && tput dl1
  echo -e "$slogan"
  msg -bar
  clear && clear
  mkdir /etc/VPS-MX >/dev/null 2>&1
  cd /etc
  wget https://raw.githubusercontent.com/emirjorge/premium/master/premium.tar.xz >/dev/null 2>&1
  tar -xf premium.tar.xz >/dev/null 2>&1
  chmod +x premium.tar.xz >/dev/null 2>&1
  rm -rf premium.tar.xz
  cd
  chmod -R 755 /etc/VPS-MX
  rm -rf /etc/VPS-MX/MEUIPvps
  echo "/etc/VPS-MX/menu" >/usr/bin/menu && chmod +x /usr/bin/menu
  echo "/etc/VPS-MX/menu" >/usr/bin/VPSMX && chmod +x /usr/bin/VPSMX
  echo "$slogan" >/etc/VPS-MX/message.txt
  [[ ! -d /usr/local/lib ]] && mkdir /usr/local/lib
  [[ ! -d /usr/local/lib/ubuntn ]] && mkdir /usr/local/lib/ubuntn
  [[ ! -d /usr/local/lib/ubuntn/apache ]] && mkdir /usr/local/lib/ubuntn/apache
  [[ ! -d /usr/local/lib/ubuntn/apache/ver ]] && mkdir /usr/local/lib/ubuntn/apache/ver
  [[ ! -d /usr/share ]] && mkdir /usr/share
  [[ ! -d /usr/share/mediaptre ]] && mkdir /usr/share/mediaptre
  [[ ! -d /usr/share/mediaptre/local ]] && mkdir /usr/share/mediaptre/local
  [[ ! -d /usr/share/mediaptre/local/log ]] && mkdir /usr/share/mediaptre/local/log
  [[ ! -d /usr/share/mediaptre/local/log/lognull ]] && mkdir /usr/share/mediaptre/local/log/lognull
  [[ ! -d /etc/VPS-MX/B-VPS-MXuser ]] && mkdir /etc/VPS-MX/B-VPS-MXuser
  [[ ! -d /usr/local/protec ]] && mkdir /usr/local/protec
  [[ ! -d /usr/local/protec/rip ]] && mkdir /usr/local/protec/rip
  [[ ! -d /etc/protecbin ]] && mkdir /etc/protecbin
  cd
  [[ ! -d /etc/VPS-MX/v2ray ]] && mkdir /etc/VPS-MX/v2ray
  [[ ! -d /etc/VPS-MX/Slow ]] && mkdir /etc/VPS-MX/Slow
  [[ ! -d /etc/VPS-MX/Slow/install ]] && mkdir /etc/VPS-MX/Slow/install
  [[ ! -d /etc/VPS-MX/Slow/Key ]] && mkdir /etc/VPS-MX/Slow/Key
  touch /usr/share/lognull &>/dev/null
  wget -O /bin/resetsshdrop https://raw.githubusercontent.com/emirjorge/premium/master/librerias/resetsshdrop &>/dev/null
  chmod +x /bin/resetsshdrop
  grep -v "^PasswordAuthentication" /etc/ssh/sshd_config >/tmp/passlogin && mv /tmp/passlogin /etc/ssh/sshd_config
  echo "PasswordAuthentication yes" >>/etc/ssh/sshd_config
  rm -rf /usr/local/lib/systemubu1 &>/dev/null
  rm -rf /etc/versin_script &>/dev/null
  v1=$(curl -sSL "https://raw.githubusercontent.com/emirjorge/premium/master/version")
  echo "$v1" >/etc/versin_script
  wget -O /etc/versin_script_new https://raw.githubusercontent.com/emirjorge/premium/master/version &>/dev/null
  echo '#!/bin/sh -e' >/etc/rc.local
  sudo chmod +x /etc/rc.local
  echo "sudo resetsshdrop" >>/etc/rc.local
  echo "sleep 2s" >>/etc/rc.local
  echo "exit 0" >>/etc/rc.local
  echo 'clear' >>.bashrc
  echo 'echo ""' >>.bashrc
  echo 'echo -e "\t\033[91m __     ______  ____        __  ____  __ " ' >>.bashrc
  echo 'echo -e "\t\033[91m \ \   / /  _ \/ ___|      |  \/  \ \/ / " ' >>.bashrc
  echo 'echo -e "\t\033[91m  \ \ / /| |_) \___ \ _____| |\/| |\  /  " ' >>.bashrc
  echo 'echo -e "\t\033[91m   \ V / |  __/ ___) |_____| |  | |/  \  " ' >>.bashrc
  echo 'echo -e "\t\033[91m    \_/  |_|   |____/      |_|  |_/_/\_\ " ' >>.bashrc
  echo 'wget -O /etc/versin_script_new https://raw.githubusercontent.com/emirjorge/premium/master/version &>/dev/null' >>.bashrc
  echo 'echo "" ' >>.bashrc
  echo 'mess1="$(less /etc/VPS-MX/message.txt)" ' >>.bashrc
  echo 'echo "" ' >>.bashrc
  echo 'echo -e "\t\033[92mRESELLER : $mess1 "' >>.bashrc
  echo 'echo -e "\t\e[1;33mVERSION: \e[1;31m$(cat /etc/versin_script_new)"' >>.bashrc
  echo 'echo "" ' >>.bashrc
  echo 'echo -e "\t\033[97mPARA MOSTAR PANEL BASH ESCRIBA: menu "' >>.bashrc
  echo 'echo ""' >>.bashrc
  rm -rf /usr/bin/pytransform &>/dev/null
  rm -rf VPS-MX.sh
  rm -rf lista-arq
  service ssh restart &>/dev/null
  clear && clear
  msg -bar
  echo -e "\e[1;92m             >> INSTALACION COMPLETADA <<" && msg bar2
  echo -e "      COMANDO PRINCIPAL PARA ENTRAR AL PANEL "
  echo -e "                      \033[1;41m  menu  \033[0;37m" && msg -bar2
}

salir() {
  exit
}

#MENUS
/bin/cp /etc/skel/.bashrc ~/
/bin/cp /etc/skel/.bashrc /etc/bash.bashrc

echo -ne " \e[1;93m [\e[1;32m0\e[1;93m]\033[1;31m > \033[1;97m Salir \e[97m \n"
echo -ne " \e[1;93m [\e[1;32m1\e[1;93m]\033[1;31m > \033[1;97m INSTALAR 8.6x VPS \e[97m \n"

echo -ne "\033[1;97mDigite solo el numero segun su respuesta:\e[32m "
read opcao
case $opcao in

0)
  salir
  ;;

1)
  install_mod
  ;;
esac
exit
