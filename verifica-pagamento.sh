#!/bin/bash
pagamentoId=$1

verifica_pagamento(){  
resultado=$(
  curl -s -X GET \
    'https://api.mercadopago.com/v1/payments/'$pagamentoId \
    -H 'Authorization: Bearer APP_USR-6702162676543402-063018-f604ce2bfa1461cd7876c6fb8fa395a0-484048900' 
)

  if [[ $(echo $resultado | jq -r '.status') == "approved" ]]
  then
      lista=(cat pagamento.db )
      for valor in $lista; do 
        id=$(echo $valor | cut -d"|" -f 1 )
        if [[ $( echo $id ) == $pagamentoId ]]
        then
              if [[ $( echo $valor | cut -d"|" -f 2 ) != "approved" ]]
              then
              cat pagamento.db | tr valor "$id|approved" > pagamento.db
              fi
         fi
      done
   else
      echo $pagamentoId
  fi
}

pagamento_pendente(){
  lista=$(cat pagamento.db)
  for valor in $lista; do
    status=$(echo $valor | cut -d"|" -f 2)
    if [[ $(echo $status ) == "pending"]] || [[ $(echo $status ) == "null" ]]
    then
      
    fi
  done
}

pagamento_pendente