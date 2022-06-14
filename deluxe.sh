#!/bin/bash

TOKEN=$(cat /etc/deluxbotFile/info-bot)
MP=$(cat /etc/deluxbotFile/info-mp)
SALVAR_PEDIDO=$(cat /etc/deluxbotFile/info-save-order)
VALOR=$(cat /etc/deluxbotFile/valor-arquivo)
REVENDA=$(cat /etc/deluxbotFile/link-revenda)
DATABASE=$(cat /etc/deluxbotFile/database.db)
MESSAGE_ID=""
[[ ! -f /etc/deluxbotFile/database.db ]] && touch /etc/deluxbotFile/database.db
  
MESSAGE=""
CHAT_ID=""
URL="https://api.telegram.org/bot$TOKEN/sendMessage"
update_id=0
FILE_PATH=$(pwd)

check_key_user(){
  key=$(cat /etc/deluxbotFile/info-key)
  verified=$(curl -s -X POST "https://SSH2-Connect.renatoalcantar3.repl.co/verificaChave.php" -d key=$key)
 
  if [ $(echo $verified | jq -r '.validate') == "Success" ]
  then
    main
  else
    exit 1
  fi

}

handler_bot(){

  result=$(curl -s --request POST \
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
    
    MESSAGE=$result
    update_id=$( echo $MESSAGE | jq -r '.result[-1].update_id')
    MESSAGE_ID=$(echo $MESSAGE | jq -r '.result[-1].message_id')


        #CHAT_ID=$(echo $MESSAGE | jq -r 'result[-1].message.from.id')
        
        CHAT_ID=$(echo $MESSAGE | jq -r '.result[-1].message.from.id')
        
        echo $result > log
  fi
    #CHAT_ID=$(echo $result | jq -r 'result[-1].message.from.id
}

send_file(){
  count=0
  IFs=\n
  files=$(ls /etc/deluxbotFile/files)
  while read file; do
    (( count++ ))
    listFiles[$count]=$file
  done <<< $files
 send="${listFiles[1]}"
  curl -v -F "chat_id=$1" -F document="@/etc/deluxbotFile/files/$send" "https://api.telegram.org/bot$TOKEN/sendDocument"
  
}


mainMenu(){


replay_markup='{
"inline_keyboard": [
    [
      {
        "text": "〘 GERAR LOGIN DE 1 HORAS 〙",
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
            "callback_data": "Revender",
            "url": "'${REVENDA}'"
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


echo $replay_markup

   
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

  if [ -n "${payment_result}" ]
  then
  paymentID=$(echo $payment_result | jq -r '.id')
  code=$(echo $payment_result | jq -r    '.point_of_interaction.transaction_data.qr_code')
   base64=$(echo $payment_result | jq -r    '.point_of_interaction.transaction_data.qr_code_base64')
  
   paymentlog=$(curl -s -X POST $SALVAR_PEDIDO  -d  chatId=$1 -d paymentID=$paymentID)

   
  
   curl -s -X POST $URL -d chat_id=$1  -d text="O código de pagamento foi gerado, toque nele para copiar." d parse_mode="HTML"
        
         curl -s -X POST $URL -d chat_id="$1"  -d text="$code"
         
         curl -s -X POST $URL -d chat_id=$1 -d text="Assim que recebermos a confirmação do pagamento enviaremos a sua conta automaticamente." -d parse_mode="HTML"

   fi
}

pagamento(){
  if [ -n "${MP}" ]
  then
    echo "MP"$MP
    echo "VALOR"$VALOR
    
     local  transaction_request=$(
    curl -X POST \
    -H 'accept: application/json' \
    -H 'content-type: application/json' \
    -H 'Authorization: Bearer ' $MP \
    'https://api.mercadopago.com/v1/payments' \
    -d '{
      "transaction_amount": ${VALOR},
      "description": "Título do produto",
      "payment_method_id": "pix",
      "payer": {
        "email": "test@test.com",
        "first_name": "Test",
        "last_name": "User",
        "identification": {
            "type": "CPF",
            "number": "19119119100"
        },
        "address": {
            "zip_code": "06233200",
            "street_name": "Av. das Nações Unidas",
            "street_number": "3003",
            "neighborhood": "Bonfim",
            "city": "Osasco",
            "federal_unit": "SP"
        }
      }
    }'
  )
   echo $transaction_request
  fi



}
send_test(){
  lista=$(awk -F\|n '{print}' /etc/deluxbotFile/database.db)
  n=0

  for id in $lista;do
    if [ $1 == $id ]
    then
      n=1
    fi
  done

  if [ $n == 0 ]
  then
    chmod +x /etc/deluxbotFile/criarteste.sh
    echo $1 >> /etc/deluxbotFile/database.db
    /etc/deluxbotFile/./criarteste.sh $1  
   else
    curl -s -X POST $URL -d chat_id=$1  -d text="<b>Você já recebeu seu teste grátis</b>" -d parse_mode="HTML"  
  fi

}


from_id=0
currentChat=0
NEXT_MESSAGE=0
CALLBACK=0
NEW_UPDATE=0
main(){
  while :
  do
    handler_bot
    if [ $update_id != $NEW_UPDATE ]
    then
      echo $MESSAGE > /etc/deluxbotFile/log
      MESSAGE_ID=$(echo $MESSAGE | jq -r '.result[-1].message.message_id')
  
           if [  $(echo $MESSAGE | jq -r '.result[-1].message.text')  == "/start" ];
           then
               user=$(echo $MESSAGE | jq -r '.result[-1].message.from.username')
                
                  
                  mainMenu "$user"
                 NEW_UPDATE=$(echo $MESSAGE | jq -r '.result[-1].update_id')
           
          fi
     fi
      echo $MESSAGE | jq -r '.result[-1]'
      if [ $(echo $MESSAGE | jq -r '.result[-1].callback_query.data') ]
      then

        if [ $update_id != $NEW_UPDATE ]
        then
          if [  $( echo $MESSAGE | jq -r '.result[-1].callback_query.data') == "Arquivo" ];
          then
        
              CHAT_ID=$(echo $MESSAGE | jq -r '.result[-1].callback_query.from.id')
                send_file $CHAT_ID
                
                NEW_UPDATE=$(echo $MESSAGE | jq -r '.result[-1].update_id')
           fi
        fi


        if [ $update_id != $NEW_UPDATE ]
        then
              if [  $( echo $MESSAGE | jq -r '.result[-1].callback_query.data') == "Pagamento" ]
                 then
                    CHAT_ID=$(echo $MESSAGE | jq -r '.result[-1].callback_query.from.id')
                    
                    sendPixCode $CHAT_ID
                    
                    NEW_UPDATE=$(echo $MESSAGE | jq -r '.result[-1].update_id')
              fi

          fi
        
        
        if [ $update_id != $NEW_UPDATE ]
        then
              if [  $( echo $MESSAGE | jq -r '.result[-1].callback_query.data') == "Teste" ]
                 then
                    CHAT_ID=$(echo $MESSAGE | jq -r '.result[-1].callback_query.from.id')
                    
                    send_test $CHAT_ID
                    
                    NEW_UPDATE=$(echo $MESSAGE | jq -r '.result[-1].update_id')
              fi
          fi


        
     fi

done
 
}


check_key_user