#!/bin/bash -l


getBotToken(){
  echo $1 > /etc/deluxbotFile/info-bot
}
getMpToken(){
  echo $1 > /etc/deluxbotFile/info-mp
}
getPageOrder(){
  echo $1 > /etc/deluxbotFile/info-save-order
}
pararBot(){
  screen -X -S deluxbot quit
}

prepararAmbiente(){
  [[ ! -d /etc/deluxbotFile ]] && mkdir /etc/deluxbotFile

[[ ! -f /etc/deluxbotFile/info-bot ]] && touch /etc/deluxbotFile/info-bot

[[ ! -f /etc/deluxbotFile/info-mp ]] && touch /etc/deluxbotFile/info-mp

[[ ! -f /etc/deluxbotFile/info-key ]] && touch /etc/deluxbotFile/info-key

[[ ! -f /etc/deluxbotFile/info-save-order ]] && touch /etc/deluxbotFile/page-save-order

[[ ! -f /etc/deluxbotFile/info-save-order ]] && touch /etc/deluxbotFile/page-webhook

[[ ! -f /etc/deluxbotFile/link-revenda ]] && touch /etc/deluxbotFile/link-revenda

}

banner(){
cat <<FECHA

_________________________________________________
      ____ ____ ___  ____ _  _    ___  ____ ___ 
      |    |  | |  \ |___  \/     |__] |  |  |  
      |___ |__| |__/ |___ _/\_    |__] |__|  | 
_________________________________________________

FECHA

}
executarBot(){
  key=$(cat /etc/deluxbotFile/info-key)
  
      result=$(curl -s -X POST "https://SSH2-Connect.renatoalcantar3.repl.co/verificaChave.php" -d key=$key)
    
         if [ $(echo $result | jq -r '.validate') == "Success" ]
          then
              echo "[-] Iniciando bot"
                screen -dmS deluxbot 
                screen -S deluxbot -p 0 -X stuff '/etc/deluxbotFile/./deluxe.sh\n'
                

          else
            exit 1
          fi
  
}

revenda(){
  echo $1 > /etc/deluxbotFile/link-revenda
}
valorArquivo(){
  echo $1 > /etc/deluxbotFile/valor-arquivo
}

verificar_chave(){
 [[ -d /etc/deluxbotFile ]] && key=$(cat /etc/deluxbotFile/info-key) || key=""
  
  if [ ! -f /etc/deluxbotFile/info-key ] &&      [ -z $key ] 
  then
     
    
     read -p "Digite sua chave: " key
   
      result=$(curl -s -X POST "https://SSH2-Connect.renatoalcantar3.repl.co/verificaChave.php" -d key=$key)
    
         if [ $(echo $result | jq -r '.validate') == "Success" ]
          then
               echo -e "[*] Preparando o ambiente"
                sleep 2
                prepararAmbiente
                echo $key > /etc/deluxbotFile/info-key
          
              sleep 1
              menu
            else
              exit 1
          fi
    else
      key=$(cat /etc/deluxbotFile/info-key)
      result=$(curl -s -X POST "https://SSH2-Connect.renatoalcantar3.repl.co/verificaChave.php" -d key=$key)
    
         if [ $(echo $result | jq -r '.validate') == "Success" ]
          then
             
                menu
          else
            exit 1
          fi
     
    fi
}

escolha(){
  echo "Escolha o que deseja fazer: "
  read -p "  ▍" leitor
  [[ $leitor == 1 ]] && setup
  [[ $leitor == 2 ]] && executarBot
  [[ $leitor == 3 ]] && pararBot
  [[ $leitor == 4 ]] && exit 1
  
}


menu(){ 
banner
printf """
 ===============================
 | 1) Instalar Telegram Bot    | 
 ===============================
 | 2 ) Executar Bot            | 
 ===============================
 | 3 ) Parar Bot               | 
 ===============================
 | 4 ) Sair                    |
 ===============================\n
 """
escolha
 }
 
 
 setup(){
  
    
    read -p "Digite o token do seu bot: " token_bot
    getBotToken $token_bot
    [[ -z $token_bot ]] && exit 1
    
    read -p "Digite o token da API Mercado Pago: " token_mp
    getMpToken $token_mp
    [[ -z $token_mp ]] && exit 1
    
    read -p "Digite a pagina para salvar os pedidos. EX> https://meusite.com.br/salvarPedido.php : " paginaOrdem
    getPageOrder $paginaOrder
     [[ -z $paginaOrdem ]] && exit 1
     
     read -p "Digite o link de revenda: " linkRevenda
     revenda $linkRevenda
     [[ -z $linkRevenda ]] && exit 1
     
    read -p "Digite o valor do arquivo 30 dias. Ex> 10.00: " valor_arquivo
    valorArquivo $valor_arquivo
    
    echo -e "[*] Baixando recursos necessários...\n"
    sleep 2
    apt install pv > /dev/null 2>&1
    sleep 1
    
    apt install screen > /dev/null 2>&1
     git clone https://github.com/Git-RenatoAlcantara/CodexBot > /dev/null 2>&1
      mv CodexBot/* /etc/deluxbotFile
      chmod +x /etc/deluxbotFile/deluxe.sh
      chmod +x /etc/deluxbotFile/criarUsuario.sh
      chmod +x /etc/deluxbotFile/criarteste.
      rm -R CodexBot
      clear 
      menu
}

verificar_chave