#!/bin/bash

TOKEN=$(cat /etc/CodexBotFile/info-bot)
MP=$(cat /etc/CodexBotFile/info-mp)
SALVAR_PEDIDO=$(cat /etc/CodexBotFile/info-save-order)
VALOR=$(cat /etc/CodexBotFile/valor-arquivo)
[[ -f criarteste.sh ]] && chmod +x criarteste.sh

CHAT_ID=""
URL="https://api.telegram.org/bot$TOKEN/sendMessage"

FILE_PATH=$(pwd)


[[ ! -d "./FILES" ]] && mkdir "./FILES"

check_key_user(){
  key=$(cat /etc/CodexBotFile/info-key)
  verified=$(curl -s -X POST "https://SSH2-Connect.renatoalcantar3.repl.co/verificaChave.php" -d key=$key)
 
  if [ $(echo $verified | jq -r '.validate') == "Success" ]
  then
    main
  else
    exit 1
  fi

}

handler_bot(){

local result=$(curl -s --request POST \
     --url https://api.telegram.org/bot$TOKEN/getUpdates \
     --header 'Accept: application/json' \
     --header 'Content-Type: application/json' \
     --data '
{
     "offset": -1,
     "limit": 1,
     "timeout": 5
}
')
  conexao=$(echo $result | jq -r '.result[-1]')

  if [ -n "$conexao" ]
  then
    CHAT_ID=$(echo $result | jq -r '.result[-1].message.from.id')
        echo $result 
  fi
    #CHAT_ID=$(echo $result | jq -r 'result[-1].message.from.id
}

api(){

    #Pega a resposta inline_keyboard
    json=$(curl -s "https://api.telegram.org/bot$TOKEN/getUpdates" |  jq -r  '.result[-1].callback_query.data' )

    return "$json"
}

send_file(){
  count=0
  IFs=\n
  while read file; do
    (( count++ ))
    listFiles[$count]=$file
  done <<< $files
  $send="${listFiles[1]}"

  curl -v -F "chat_id=$1" -F document="@/root/FILES/$send" "https://api.telegram.org/bot$TOKEN/sendDocument"
  
}


mainMenu(){


replay_markup='{
"inline_keyboard": [
    [
      {
        "text": "〘 GERAR LOGIN DE 6 HORAS 〙",
        "callback_data": "Teste"
      }
    ],
    [
        {
        "text": "〘 OBTER ARQUIVO 〙",
        "callback_data": "Arquivo"
      }
   ],
   [
        {
            "text": "〘 SEJA REVENDEDOR 〙",
            "callback_data": "Revender"
          }

    ],
    [
    {
        "text": "〘 PAGAMENTO VIA PIX 〙",
        "callback_data": "Pagamento"
      }

    ]
  ]
}'




   
curl -s -X POST $URL -d chat_id=$CHAT_ID  -d text="
Olá <b>$1</b>, Bem vindo!
▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
<b>COM ESSE BOT VOCÊ PODE</b>
▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
✅ Comprar login 1 mês
✅ Criar conta teste 6H
✅ Ser revendedor
✅ Entrar em contato
✅ Baixar arquivo de conexão "  -d reply_markup="$replay_markup" -d parse_mode="HTML"
}

sendPixCode(){
  payment_result=$(pagamento)

  
  paymentID=$(echo $payment_result | jq -r '.id')
  code=$(echo $payment_result | jq -r    '.point_of_interaction.transaction_data.qr_code')
   base64=$(echo $payment_result | jq -r    '.point_of_interaction.transaction_data.qr_code_base64')
  
   paymentlog=$(curl -s -X POST $SALVAR_PEDIDO  -d  chatId=$1 -d paymentID=$paymentID)

   
  
   curl -s -X POST $URL -d chat_id=$1  -d text="O código de pagamento foi gerado, toque nele para copiar." d parse_mode="HTML"
        
         curl -s -X POST $URL -d chat_id="$1"  -d text="$code"
         
         curl -s -X POST $URL -d chat_id=$1 -d text="Assim que recebermos a confirmação do pagamento enviaremos a sua conta automaticamente." d parse_mode="HTML"

   
}

pagamento(){
  
  local  transaction_request=$(curl -X POST \
    -H 'accept: application/json' \
    -H 'content-type: application/json' \
    -H 'Authorization: Bearer '$MP\
    'https://api.mercadopago.com/v1/payments' \
    -d '{
      "transaction_amount": '$VALOR',
      "description": "Login de 30 dias",
      "payment_method_id": "pix",
      "payer": {
        "email": "luciaaliciasantos@tribunadeindaia.com.br",
        "first_name": "Lúcia",
        "last_name": "Alícia Santos",
        "identification": {
            "type": "CPF",
            "number": "98535094075"
        },
        "address": {
            "zip_code": "60763096",
            "street_name": "Travessa Brumado",
            "street_number": "467",
            "neighborhood": "Bonfim",
            "city": "Fortaleza",
            "federal_unit": "CE"
        }
      }
    }'
)

 echo $transaction_request

}
send_test(){
  chmod +x criarteste.sh
  ./criarteste.sh $1  
}
update_id=0
send_apk=0
from_id=0
currentChat=0
first=0

main(){
  while :
  do
    handle=$(handler_bot)
    echo $handle > /etc/CodexBotFile/log
    update=$(echo $handle | jq -r    '.result[-1].update_id')
    
    id=$(echo $handle | jq -r '.result[-1].message.from.id')
      CHAT_ID=$id
      currentChat=$id
     
        if [ $update_id != $update ] 
        then
            if [  $(echo $handle | jq -r '.result[-1].message.text')  == "/start" ];
            then
                user=$(echo $handle | jq -r '.result[-1].message.from.username')
                
                  update_id=$update
                  mainMenu "$user"
                  update_id=$update
                
           fi
     fi

      fromId=$( echo $handle | jq -r '.result[-1].callback_query.message.chat.id')
        
      if [  $( echo $handle | jq -r '.result[-1].callback_query.data') == "Pagamento" ]
         then
            if [ $update_id != $update ] 
            then
              update_id=$update
              sendPixCode $fromId
              update_id=$update
            fi
         fi

        if [  $( echo $handle | jq -r '.result[-1].callback_query.data') == "Arquivo" ]
         then
            if [ $update_id != $update ] 
            then
              
              update_id=$update
              send_file $fromId
              update_id=$update
            fi
         fi
        if [ $( echo $handle | jq -r '.result[-1].callback_query.data') == "Teste" ]
        then
            if [ $update_id != $update]
            then
               update_id=$update
               send_test $fromId
               update_id=$update
            fi
        fi
done
 
}


check_key_user