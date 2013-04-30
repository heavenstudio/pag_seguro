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

As notificações de alteração no status da compra no PagSeguro serão enviadas para a URL que tiver configurado na [Notificação de transações](https://pagseguro.uol.com.br/v2/guia-de-integracao/consulta-de-transacoes-por-codigo.html). Se quiser configurar uma url dinâmica para envio das notificação é necessário ativar a página de redirecionamento dinâmico em [Integrações > Página de redirecionamento](https://pagseguro.uol.com.br/integracao/pagina-de-redirecionamento.jhtml), e passar o argumento `redirect_url` para o objeto PagSeguro::Payment:

    PagSeguro::Payment.new(email, token, id: invoice.id, redirect_url: "http://lojamodelo.com.br/checkout")

O código da notificação é enviado pelo PagSeguro através do parâmentro `notificationCode` em uma requisição do tipo POST. Segue um exemplo de uso da notificação em uma aplicação rails (este exemplo supõe a existência de um `resources :notifications` em suas rotas, e um modelo `Invoice` responsável pelos pagamentos):

    class NotificationsController < ApplicationController
      skip_before_filter :verify_authenticity_token
    
      def create
        return unless request.post?
      
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
        
        render :nothing => true
      end
    end

Para este exemplo, o url configurada na [Notificação de transações](https://pagseguro.uol.com.br/v2/guia-de-integracao/consulta-de-transacoes-por-codigo.html) poderia ser algo como `http://lojamodelo.com.br/notifications`

### Consulta de Transações

Há duas maneiras de se realizar a consulta das transações, a primeira delas buscando o código de uma transação, e outra buscando por todas as transações em um determinado período

#### Consulta de Transações por Período

Você pode consultar as transações por uma data através do método `PagSeguro::Query::find`, informando seu email, token, e algumas opções adicionais:

    transactions = PagSeguro::Query.find(email, token, initial_date: 30.days.ago, final_date: Time.now)

    transactions.each do |transaction|
      puts "id: #{transaction.id}, transaction_id: #{transaction.transaction_id}"
      ...
    end

Além das opções acima, você pode enviar também as opções `:page` (que pelo padrão é a primeira), `:max_page_results` (que por padrão é 50) e `abandoned`, que por padrão é falso mas caso seja passado como verdadeiro irá buscar as transações abandonadas (onde o processo de cadastro/compra não foi concluído). Obviamente a data final precisa ser maior que a inicial, não podem haver mais de 30 dias de diferença entre as duas, e a data inicial precisa estar dentro dos últimos 6 meses.

Obs.: Se for consultar as transações abandonadas, não utilize Time.now como `final_date`. Por algum motivo o PagSeguro não permite consultar as transações abandonadas até o momento atual, resultando em um erro 400 (bad request). Utilize 15.minutes.ago ou Date.today.

#### Consulta de Transação por código

O código das transações são enviadas nas Notificações de Transações do PagSeguro (de forma assíncrona), e podem ser obtidas através do método `notification.transaction_id`, e também podem ser obtidas de forma síncrona assim que o usuário retorna à loja após ter concluído a compra. Este código também pode ser encontrado através da busca de transações por período.

Para buscar informações da transação de forma síncrona, é necessário que acesse sua conta no PagSeguro, e clique em [Integrações > Página de redirecionamento](https://pagseguro.uol.com.br/integracao/pagina-de-redirecionamento.jhtml) e ative o redirecionamento com o código da transação, definindo o nome do parâmetro que será enviado para sua aplicação (e.g.: http://lojamodelo.com.br/checkout?transaction_id=E884542-81B3-4419-9A75-BCC6FB495EF1 ). O redirecionamento para esta página é executado através de uma requisição GET.

Você pode consultar as informações da transação instanciando a classe `PagSeguro::Query`, que possui os mesmos attributos e métodos que uma notificação:

    query = PagSeguro::Query.new(email, token, "E884542-81B3-4419-9A75-BCC6FB495EF1")

    if query.approved?
      # ...
    end

### Pagamento Recorrente

**Primeiro de tudo vale ressaltar que a API de pagamento recorrente não está documentada oficialmente pelo pagseguro, apesar de ter sido lançada em dezembro de 2012. Esta funcionalidade foi criada com base em um post em um [blog](http://sounoob.com.br/requisicao-de-pagamento-do-pagseguro-com-assinatura-associada-usando-php/) e em tentativa e erro. Use por sua conta e risco.**

É possível enviar a requisição de uma pagamento recorrente juntamente com o pedido de compra (e por enquanto não é possível enviar um pedido de assinatura sem enviar adicionar nenhum ítem ao pagamento). Para usá-la, basta adicionar um `pre_approval` a um pagamento:
    
    # suponho que uma variavel payment (do tipo PagSeguro::Payment) já foi instanciada, e que o payment.items não está vazio
    payment.pre_approval = PagSeguro::PreApproval.new

    # obrigatório. Recebe uma string (de até 100 caracteres) e representa o nome da sua assinatura
    payment.pre_approval.name = "nome da minha assinatura"

    # obrigatório. Recebe uma data e representa a data em que sua assinatura termina. Não pode ser maior do que a data de início (ou hoje) em mais de 744 dias (pouco menos de 3 anos)
    payment.pre_approval.pre_approval.final_date = Date.new(2014, 6, 12)

    # obrigatório. Valor máximo da assinatura por período/cobrança. Recebe uma string (formatada como "%.2f"), um float ou um BigDecimal
    payment.pre_approval.max_amount_per_period = '200.00'

    # obrigatório. Valor máximo total da assinatura. Recebe uma string (formatada como "%.2f"), um float ou um BigDecimal
    payment.pre_approval.max_total_amount = '1000.00'

    # obrigatório. Representa a periodicidade da cobraça. Recebe uma string ou símbolo e pode ser: weekly, monthly, bimonthly, trimonthly, semiannually, ou yearly
    payment.pre_approval.period = :monthly

    # obrigatório no caso de pagamentos de periodicidade monthly, bimonthly ou trimonthly. Recebe um número (dia do mês) de 1 à 28
    payment.pre_approval.day_of_month = 10

    # obrigatório no caso de pagamentos de periodicidade weekly. Recebe uma string ou símbolo representando o dia na semana, e pode ser monday, tuesday, wednesday, thursday, friday, saturday ou sunday
    payment.pre_approval.day_of_week = :friday

    # obrigatório no caso de pagamentos de periodicidade yearly. Recebe uma string representando o dia do mês e o mês do ano no formato 'MM-dd'. Para facilitar use a classe DayOfYear que gera a string no formato correto.
    payment.pre_approval.day_of_year = PagSeguro::DayOfYear.new(day: 10, month: 4)

    # estranhamente é opcional! Valor de cada cobrança. Recebe uma string (no formato "%.2f"), um float ou um BigDecimal
    payment.pre_approval.amount_per_payment = '200.00'

    # opcional. Recebe uma string (de até 255 caracteres) e representa os detalhes da assinatura
    payment.pre_approval.details = "detalhes da assinatura"

    # opcional. Recebe uma data de quando a assinatura passa a valer. Não pode ser maior do que 2 anos da data atual, e precisa ser inferior a data de final_date (que pode ser maior em até 744 dias da data de início)
    payment.pre_approval.initial_date = Date.new(2014, 3, 12)

    # opcional. Recebe uma string que supostamente deveria levar às condições da sua assinatura
    payment.pre_approval.reviewURL = "http://seuproduto.com/assinatura"

    # Por fim gere a URL do pagseguro da mesma forma como nas compras/pagamentos normais.
    redirect_to_url = payment.checkout_payment_url

## Validações

Os modelos utilizados nesta gem utilizam as validações do ActiveModel (semelhantes às presentes em ActiveRecord/Rails) e incluem diversas validações, permitindo que se verifique a validade (utilizando object.valid?) dos dados antes de enviá-los ao PagSeguro. A gem não bloqueia o envio das informações caso os dados estejam inválidos, deixando este passo a cargo da sua aplicação, mas levanta erros caso o pag seguro retorne algum erro relativo às informações enviadas.

## Testes

Esta gem possui testes extensivos utilizando Rspec. Para rodar os testes, altere o arquivo spec/pag_seguro/integration/config.yml com seus dados no pag_seguro, entre na pasta onde a gem está instalada e execute:

    bundle
    guard

## Contribuindo

Caso queira contribuir, faça um fork desta gem no [github](https://github.com/heavenstudio/pag_seguro), escreva os testes respectivos ao bug/feature desejados e faça um merge request.

## Sobre

Desenvolvida por [Stefano Diem Benatti](mailto:stefano@heavenstudio.com.br)

## Colaboradores

Rafael Castilho (<http://github.com/castilhor>)

Rafael Ivan Garcia (https://github.com/rafaelivan)

efmiglioranza (https://github.com/efmiglioranza)
