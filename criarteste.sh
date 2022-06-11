#!/bin/bash
IP=$(cat /etc/IP)
if [ ! -d /etc/SSHPlus/userteste ]; then
mkdir /etc/SSHPlus/userteste
fi

nome=$(echo $RANDOM | md5sum | head -c 9; echo;)
if [[ -z $nome ]]
then
	exit 1
fi
awk -F : ' { print $1 }' /etc/passwd > /tmp/users 
if grep -Fxq "$nome" /tmp/users
then
	 	exit 1
fi
pass=$(echo $RANDOM | md5sum | head -c 5; echo;)
if [[ -z $pass ]]
then
	exit 1
fi
limit=1
if [[ -z $limit ]]
then
exit 1
fi
u_temp=60
if [[ -z $u_temp ]]
then
	exit 1
fi

useradd -M -s /bin/false $nome
(echo $pass;echo $pass) |passwd $nome > /dev/null 2>&1
echo "$pass" > /etc/SSHPlus/senha/$nome
echo "$nome $limit" >> /root/users.db
echo "#!/bin/bash
pkill -f "$nome"
userdel --force $nome
grep -v ^$nome[[:space:]] /root/users.db > /tmp/ph ; cat /tmp/ph > /root/users.db
rm /etc/SSHPlus/senha/$nome > /dev/null 2>&1
rm -rf /etc/SSHPlus/userteste/$nome.sh
exit" > /etc/SSHPlus/userteste/$nome.sh
chmod +x /etc/SSHPlus/userteste/$nome.sh
at -f /etc/SSHPlus/userteste/$nome.sh now + $u_temp min > /dev/null 2>&1

chat_id=$1

curl -s -X POST $URL -d chat_id=$chat_id -d text="
<b>Conta de teste criada!</b>
▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
<b>Servidor: $ip</b>
<b>Usuario: $nome</b>
<b>Senha: $pass</b>
<b>Conexao: $limit Apenas</b>
<b>Duracao: $u_temp Minutos</b>
▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
Depois do tempo de $limit terminar
Sera desconectado e aconta deletada
" d parse_mode="HTML"
