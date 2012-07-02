# PagSeguro

Esta gem foi criada com o intuito de facilitar o uso da versão 2 das APIs do PagSeguro, como pagamento e notificações através de código Ruby. Esta gem não depende de rails e portanto pode ser utilizada com uma aplicação Rack ou como Backend de outra aplicação sem precisar carregar um environment rails.

Utilizando esta gem é possível enviar informações de compra ao pag seguro sem necessitar renderizar um formulário, impedindo o usuário de forjar informações pois as informações são trocadas apenas entre a sua aplicação e o pagseguro sem intermédio do usuário.

Esta gem foi desenvolvida para utilizar Ruby 1.9.2 ou superior, e não têm compatibilidade com versões anteriores. Caso deseje utilizar esta gem com versões anteriores de ruby, faça um fork desta gem e corrija os problemas encontrados.

## Instalação

Adicione a `gem "pag_seguro"` ao seu Gemfile:

    gem 'pag_seguro'

Além disso, é necessário que tenha uma conta no pag seguro, e que habilite as seguintes configurações:

    Em [Integrações -> Token](https://pagseguro.uol.com.br/integracao/token-de-seguranca.jhtml) de segurança clique em Gerar novo token e guarde esta informação em local seguro
    Em [Integrações -> Pagamentos via API](https://pagseguro.uol.com.br/integracao/pagamentos-via-api.jhtml) é necessário ativar a opção "Quero receber somente pagamentos via API."
    Em [Integrações -> Notificação de transações](https://pagseguro.uol.com.br/integracao/notificacao-de-transacoes.jhtml) é necessário ativar a notificação de transações e definir a url de retorno

## Documentação

### Classes e Atributos

A nomenclatura dos atributos e recursos (classes) esperados pelo PagSeguro foram mantidas porém usando o padrão de nomenclatura do ruby (ao invés do camelcase utilizado pelo pagseguro). Seguem os links das documentações dos atributos no pagseguro:

* [API de pagamentos](https://pagseguro.uol.com.br/v2/guia-de-integracao/api-de-pagamentos.html#v2-item-api-de-pagamentos-parametros-api)
* [API de notificação](https://pagseguro.uol.com.br/v2/guia-de-integracao/api-de-notificacoes.html)
* [API de transações](https://pagseguro.uol.com.br/v2/guia-de-integracao/consulta-de-transacoes-por-codigo.html)

###  API de Pagamento

Segue um exemplo de uso para criação de um pagamento no PagSeguro:

    payment = PagSeguro::Payment.new(email, token, id: invoice.id)
    
    payment.items = [
      PagSeguro::Item.new(id: 25, description: "A Bic Pen", amount: "1.50",  quantity: "4", shipping_cost: "1.00",  weight: 10),
      PagSeguro::Item.new(id: 17, description: "A pipe",    amount: "3.00",  quantity: "89")
    ]
    
    redirect_to_url = payment.checkout_payment_url
    
O método checkout_payment_url envia as informações de `payment` ao PagSeguro e em caso de sucesso gera a url do PagSeguro para qual o comprador deverá ser redirecionado para efetuar a compra.

Além dos items presentes no exemplo acima, é possível configurar `payment.sender` (com informações do usuário que está efetuando a compra), `payment.shipping` ( com as informações de endereço ), entre outras opções (para mais exemplos, olhe o arquivo spec/integration/checkout_spec.rb). Em especial, o attributo `payment.id` deve ser utilizado para referenciar um pagamento único no seu sistema.

Segue um exemplo mais completo do uso da api de pagamentos:

    payment = PagSeguro::Payment.new(email, token, id: invoice.id)
    
    payment.items = [
      PagSeguro::Item.new(id: 25, description: "A Bic Pen", amount: "1.50",  quantity: "4", shipping_cost: "1.00",  weight: 10),
      PagSeguro::Item.new(id: 17, description: "A pipe",    amount: "3.00",  quantity: "89")
    ]
    
    payment.sender = PagSeguro::Sender.new(name: "Stefano Diem Benatti", email: "stefano@heavenstudio.com.br", phone_ddd: "11", phone_number: "93430994")
    payment.shipping = PagSeguro::Shipping.new(
      type: PagSeguro::Shipping::SEDEX,
      state: "SP",
      city: "São Paulo", postal_code: "05363000",
      district: "Jd. PoliPoli",
      street: "Av. Otacilio Tomanik",
      number: "775",
      complement: "apto. 92")
    
    redirect_to_url = payment.checkout_payment_url
    

Com exceção do atributo response (que é utilizado para armazenar a resposta enviada pelo PagSeguro), todos os outros atributos podem ser inicializados em formato hash na inicialização do `PagSeguro::Payment`:

    payment = PagSeguro::Payment.new(EMAIL, TOKEN, id: 2, items: [ PagSeguro::Item.new(id: 17, description: "A pipe", amount: "3.00",  quantity: "89") ], extra_amount: '1.00' )

### API de Notificação

As notificações de alteração no status da compra no PagSeguro serão enviadas para a URL que tiver configurado na [Notificação de transações](https://pagseguro.uol.com.br/v2/guia-de-integracao/consulta-de-transacoes-por-codigo.html). Obs.: Até o momento o PagSeguro não permite configurar uma url dinâmica para envio das notificação ( e apenas permite uma url por conta ), então provavelemente será necessário que crie uma conta diferente no PagSeguro para cada sistema que desenvolver.

O código da notificação é enviado pelo PagSeguro através do parâmentro `notificationCode` em uma requisição do tipo POST. Segue um exemplo de uso da notificação em uma aplicação rails (este exemplo supõe a existência de um `resources :notifications` em suas rotas, e um modelo `Invoice` responsável pelos pagamentos):

    class NotificationsController < ApplicationController
      def create
        email = "seu_email_cadastrado@nopagseguro.com.br"
        token = "SEU_TOKEN_GERADO_NO_PAG_SEGURO"
        notification_code = params[:notificationCode]
        
        notification = PagSeguro::Notification.new(email, token, notification_code)
        
        if notification.approved?
          # Idealmente faça alguns testes de sanidade, como notification.gross_amount, notification.item_count, etc
          # notification.id referencia o id do payment/invoice, caso tenha sido configurado
          # transacation_id identifica o código da transação no pag seguro
          Invoice.find(notification.id).approve!(notification.transaction_id)
        end
        
        if notification.cancelled? || notification.returned?
          Invoice.find(notification.id).void!
        end
      end
    end

Para este exemplo, o url configurada na [Notificação de transações](https://pagseguro.uol.com.br/v2/guia-de-integracao/consulta-de-transacoes-por-codigo.html) poderia ser algo como `http://lojamodelo.com.br/notifications`

### Consulta de Transações

Para realizar a consulta de uma transação é preciso obter o código da transação. Este código é enviado nas Notificações de Transações do PagSeguro (de forma assíncrona), através do método `notification.transaction_id` ou de forma síncrona assim que o usuário retorna à loja após ter concluído a compra.

Para buscar informações da transação de forma síncrona, é necessário que acesse sua conta no PagSeguro, e clique em [Integrações > Página de redirecionamento](https://pagseguro.uol.com.br/integracao/pagina-de-redirecionamento.jhtml) e ative o redirecionamento com o código da transação, definindo o nome do parâmetro que será enviado para sua aplicação (e.g.: http://lojamodelo.com.br/checkout?transaction_id=E884542-81B3-4419-9A75-BCC6FB495EF1 ). O redirecionamento para esta página é executado através de uma requisição GET.

Caso queira utilizar uma URL dinâmica de retorno, é necessário ativar a página de redirecionamento dinâmico em [Integrações > Página de redirecionamento](https://pagseguro.uol.com.br/integracao/pagina-de-redirecionamento.jhtml), e passar o argumento `redirect_url` para o objeto PagSeguro::Payment:

    PagSeguro::Payment.new(email, token, id: invoice.id, redirect_url: "http://lojamodelo.com.br/checkout")

Você pode consultar as informações da transação através do `PagSeguro::Query`, que possui os mesmos attributos e métodos que `PagSeguro::Notification` para consulta da transação:

    query = PagSeguro::Query.new(email, token, "E884542-81B3-4419-9A75-BCC6FB495EF1")

    if query.approved?
      # ...
    end

## Validações

Os modelos utilizados nesta gem utilizam as validações do ActiveModel (semelhantes às presentes em ActiveRecord/Rails) e incluem diversas validações, permitindo que se verifique a validade (utilizando object.valid?) dos dados antes de enviá-los ao PagSeguro. A gem não bloqueia o envio das informações caso os dados estejam inválidos, deixando este passo a cargo da sua aplicação, mas levanta erros caso o pag seguro retorne algum erro relativo às informações enviadas.

## Testes

Esta gem possui testes extensivos utilizando Rspec. Para rodar os testes, altere o arquivo spec/pag_seguro/integration/config.yml com seus dados no pag_seguro, entre na pasta onde a gem está instalada e execute:

    bundle
    guard

## Todo

Adicionar código para realizar consultas ao [Histórico de Transações](https://pagseguro.uol.com.br/v2/guia-de-integracao/consulta-de-transacoes-por-intervalo-de-datas.html)

## Contribuindo

Caso queira contribuir, faça um fork desta gem no [github](https://github.com/heavenstudio/pag_seguro), escreva os testes respectivos ao bug/feature desejados e faça um merge request.

## Sobre

Desenvolvida por [Stefano Diem Benatti](mailto:stefano@heavenstudio.com.br)

## Colaboradores

Rafael Castilho (<http://github.com/castilhor>)