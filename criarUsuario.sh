

#[[ "$(grep -wc $username /etc/passwd)" != '0' ]] && {
#	echo -e "\n${cor1}Este usuário já existe. tente outro nome!${scor}\n"
#	exit 1
#}


#info=$(curl -s https://ssh2-connect.renatoalcantar3.repl.co/criarUsuario.php)
#user=$(echo $info | jq -r '.user')
#pass=$(echo $info | jq -r '.pass')
#expire=$(echo $info | jq -r '.expire')
#limite=$(echo $info | jq -r '.limite')

sshPlusUserCreate(){
TOKEN=$(cat /etc/CodexBotFile/info-bot)

URL="https://api.telegram.org/bot$TOKEN/sendMessage"

# Comando para pegar o IP da máquina
IP=$(curl -s http://whatismyip.akamai.com/)
#USERNAME Uso no máximo 10 caracteres - Maior que dois digitos - Não use espaço, acentos ou caracteres especiais - Não pode ficar vazio
username=$(echo $RANDOM | md5sum | head -c 9; echo;)
#PASSWORD Número no minimo 4 digitos - Não pode ficar vazio. 
password=$(echo $RANDOM | md5sum | head -c 5; echo;)
#SSHLIMITER Deve ser maior que zero - Apenas número - Não pode ficar vazio
sshlimiter=1
# DIAS Deve ser maior que zero - Deve ser apenas número - Não pode ficar vazio
dias=30

final=$(date "+%Y-%m-%d" -d "+$dias days")
gui=$(date "+%d/%m/%Y" -d "+$dias days")
pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
useradd -e $final -M -s /bin/false -p $pass $username >/dev/null 2>&1 &
echo "$password" >/etc/SSHPlus/senha/$username
echo "$username $sshlimiter" >>/root/usuarios.db
 
curl -s -X POST $URL -d chat_id=$1  -d text="
CONTA SSH CRIADA !
IP: $IP
Usuário: $username
Senha: $password
Expira em: $gui
Limite de conexões: $sshlimiter" -d parse_mode="HTML"

}

sshPlusUserCreate