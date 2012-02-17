# PagSeguro

Esta gem foi criada com o intuito de facilitar o uso da versão 2 das APIs do PagSeguro, como pagamento e notificações através de código Ruby. Esta gem não depende de rails e portanto pode ser utilizada com uma aplicação Rack ou como Backend de outra aplicação sem precisar carregar um environment rails.

Utilizando esta gem é possível enviar informações de compra ao pag seguro sem necessitar renderizar um formulário, impedindo o usuário de forjar informações pois as informações são trocadas apenas entre a sua aplicação e o pagseguro sem intermédio do usuário.

Esta gem foi desenvolvida para utilizar Ruby 1.9.2 ou superior, e não têm compatibilidade com versões anteriores. Caso deseje utilizar esta gem com versões anteriores de ruby, faça um fork desta gem e corrija os problemas encontrados.

## Instalação

Adicione a `gem "pag_seguro"` ao seu Gemfile:

    gem 'pag_seguro'
	
Além disso, é necessário que tenha uma conta no pag seguro, e que habilite as seguintes configurações:

    Em Integrações -> Token de segurança clique em Gerar novo token e guarde esta informação em local seguro
    Em Integrações -> Pagamentos via API é necessário ativar a opção "Quero receber somente pagamentos via API."
    Em Integrações -> Notificação de transações é necessário ativar a notificação de transações e definir a url de retorno
	
## Documentação
### Classes e Atributos

A nomenclatura dos atributos e recursos (classes) esperados pelo PagSeguro foram mantidas porém usando o padrão de nomenclatura do ruby (ao invés do camelcase utilizado pelo pagseguro). Seguem os links das documentações dos atributos no pagseguro:

* [API de pagamentos](https://pagseguro.uol.com.br/v2/guia-de-integracao/api-de-pagamentos.html#v2-item-api-de-pagamentos-parametros-api)
* [API de notificação](https://pagseguro.uol.com.br/v2/guia-de-integracao/api-de-notificacoes.html)

###  API de Pagamento

Segue um exemplo de uso para criação de um pagamento no PagSeguro:

    payment = PagSeguro::Payment.new(EMAIL, TOKEN)
    
    payment.items = [
      PagSeguro::Item.new(id: 25, description: "A Bic Pen", amount: "1.50",  quantity: "4", shipping_cost: "1.00",  weight: 10),
      PagSeguro::Item.new(id: 17, description: "A pipe",    amount: "3.00",  quantity: "89")
    ]
    
    redirect_to_url = payment.checkout_payment_url
    
O método checkout_payment_url envia as informações de `payment` ao PagSeguro e em caso de sucesso gera a url do PagSeguro para qual o comprador deverá ser redirecionado para efetuar a compra.

Além dos items presentes no exemplo acima, é possível configurar `payment.sender` (com informações do usuário que está efetuando a compra), `payment.shipping` ( com as informações de endereço ), entre outras opções (para mais exemplos, olhe o arquivo spec/integration/checkout_spec.rb). Em especial, o attributo `payment.id` deve ser utilizado para referenciar um pagamento único no seu sistema.

Com exceção do atributo response (que é utilizado para armazenar a resposta enviada pelo PagSeguro), todos os outros atributos podem ser inicialidos em formato hash na inicialização do `PagSeguro::Payment`:

    payment = PagSeguro::Payment.new(EMAIL, TOKEN, id: 2, items: [ PagSeguro::Item.new(id: 17, description: "A pipe", amount: "3.00",  quantity: "89") ], extra_amount: '1.00' )

### API de Notificação

As notificações de alteração no status da compra no PagSeguro serão enviadas para a URL que tiver configurado na Notificação de transações (vide Instalação). Obs.: Até o momento o PagSeguro não permite configurar uma url dinâmica para envio das notificação ( e apenas permite uma url por conta ), então provavelemente será necessário que crie uma conta diferente no PagSeguro para cada sistema que desenvolver.

O código da notificação é enviado pelo PagSeguro através do parâmentro `notificationCode` em uma requisição do tipo POST ( lembre-se de adicionar uma rota post respectiva ). Segue um exemplo de uso da notificação em uma aplicação rails:

    class PagSeguroNotificationController < ApplicationController
      def parse_notification
        EMAIL = "seu_email_cadastrado@nopagseguro.com.br"
        TOKEN = "SEU_TOKEN_GERADO_NO_PAG_SEGURO"
        NOTIFICATION_CODE = params(:notificationCode)
        
        notification = PagSeguro::Notification.new(EMAIL, TOKEN, NOTIFICATION_CODE)
        
        if notification.approved?
          # Idealmente faça alguns testes de sanidade, como notification.gross_amount, notification.item_count, etc
          # notification.id referencia o id do payment, caso tenha sido configurado
          # transacation_id identifica o código da transação no pag seguro
          Invoice.find(notification.id).approve!(notification.transaction_id)
        end
        
        if notification.cancelled? || notification.returned?
          Invoice.find(notification.id).void!
        end
      end
    end

## Validações

Os modelos utilizados nesta gem utilizam as validações do ActiveModel (semelhantes às presentes em ActiveRecord/Rails) e incluem diversas validações, permitindo que se verifique a validade (utilizando object.valid?) dos dados antes de enviá-los ao PagSeguro. A gem não bloqueia o envio das informações caso os dados estejam inválidos, deixando este passo a cargo da sua aplicação, mas levanta erros caso o pag seguro retorne algum erro relativo às informações enviadas.

## Testes

Esta gem possui testes extensivos utilizando Rspec. Para rodar os testes, altere o arquivo spec/pag_seguro/integration/config.yml com seus dados no pag_seguro, entre na pasta onde a gem está instalada e execute:

    bundle
    guard

## Contribuindo

Caso queira contribuir, faça um fork desta gem no [github](https://github.com/heavenstudio/pag_seguro), escreva os testes respectivos ao bug/feature desejados e faça um merge request.

## TODO

Permitir realizar [consultas de transações](https://pagseguro.uol.com.br/v2/guia-de-integracao/consultas.html)

## Sobre

Desenvolvida por [Stefano Diem Benatti](mailto:stefano.diem@gmail.com)