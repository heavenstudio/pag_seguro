# PagSeguro

Esta gem foi criada com o intuito de facilitar o uso da versão 2 das APIs do PagSeguro, como pagamento e notificações através de código Ruby. Esta gem não depende de rails e portanto pode ser utilizada com uma aplicação Rack ou como Backend de outra aplicação sem precisar carregar um environment rails. Utilizando esta gem é possível enviar informações de compra ao pag seguro sem necessitar renderizar um formulário, impedindo o usuário de forjar informações pois as informações são trocadas apenas entre a sua aplicação e o pagseguro sem intermédio do usuário.

## Instalação

Adicione a gem "pag_seguro" ao seu Gemfile:

    gem 'pag_seguro'
	
Além disso, é necessário que tenha uma conta no pag seguro, e que habilite as seguintes configurações:
    Em Integrações -> Token de segurança clique em Gerar novo token e guarde esta informação em local seguro
    Em Integrações -> Pagamentos via API é necessário ativar a opção "Quero receber somente pagamentos via API."
    Em Integrações -> Notificação de transações é necessário ativar a notificação de transações e definir a url de retorno
	
## Documentação da API e dos attributos

A nomenclatura dos atributos esperados pelo PagSeguro foram mantidas porém no padrão underscore (que é o padrão de ruby, ao invés do camelcase utilizado pelo pagseguro). Seguem os links das documentações dos attributos no pagseguro:

* [API de pagamentos](https://pagseguro.uol.com.br/v2/guia-de-integracao/api-de-pagamentos.html#v2-item-api-de-pagamentos-parametros-api)
* [API de notificação](https://pagseguro.uol.com.br/v2/guia-de-integracao/api-de-notificacoes.html)

## Documentação

Segue um exemplo de uso desta gem (para mais exemplos, olhe o arquivo spec/integration/checkout_spec.rb):

    payment = PagSeguro::Payment.new(EMAIL, TOKEN)
    
    payment.items = [
      PagSeguro::Item.new(id: 25, description: "A Bic Pen", amount: "1.50",  quantity: "4", shipping_cost: "1.00",  weight: 10),
      PagSeguro::Item.new(id: 17, description: "A pipe",    amount: "3.00",  quantity: "89")
    ]
    
    redirect_to_url = payment.checkout_payment_url
    
Além dos items presentes no exemplo acima, é possível configurar payment.sender (com informações do usuário que está efetuando a compra) e `payment.shipping` ( com as informações de endereço ).

## Validações

Os modelos utilizados nesta gem utilizam as validações do ActiveModel (semelhantes às presentes em ActiveRecord/Rails) e incluem diversas validações, permitindo que se verifique a validade (utilizando object.valid?) dos dados antes de enviá-los ao PagSeguro. A gem não bloqueia o envio das informações caso os dados estejam inválidos, deixando este passo a cargo da sua aplicação, mas levanta erros caso o pag seguro retorne algum erro relativo às informações enviadas.

## Testes

Esta gem possui testes extensivos utilizando Rspec. Para rodar os estes, altere o arquivo spec/pag_seguro/integration/config.yml com seus dados no pag_seguro, e execute:

    bundle
    guard

## Contribuindo

Caso queira contribuir, faça um fork desta gem no [github](https://github.com/heavenstudio/pag_seguro), escreva os testes respectivos ao bug/feature desejados e faça um merge request.

## TODO

Permitir realizar [consultas de transações](https://pagseguro.uol.com.br/v2/guia-de-integracao/consultas.html)

## Sobre

Desenvolvida por [Stefano Diem Benatti](stefano.diem@gmail.com)