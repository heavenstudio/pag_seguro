# encoding: utf-8
module PagSeguro
  class PaymentMethod
    attr_accessor :code, :type

    # Payment Method types
    CREDIT_CARD        = 1
    BANK_BILL          = 2
    ONLINE_DEBIT       = 3
    PAG_SEGURO_BALANCE = 4
    OI_PAGGO           = 5

    def initialize(options = {})
      @code = options[:code]
      @type = options[:type]
    end

    def code
      @code.to_i
    end

    def type
      @type.to_i
    end

    def credit_card?
      CREDIT_CARD == type
    end

    def bank_bill?
      BANK_BILL == type
    end

    def online_debit?
      ONLINE_DEBIT == type
    end

    def pag_seguro_balance?
      PAG_SEGURO_BALANCE == type
    end

    def oi_paggo?
      OI_PAGGO == type
    end

    def name
      case code
      when 101 then "Cartão de crédito Visa"
      when 102 then "Cartão de crédito MasterCard"
      when 103 then "Cartão de crédito American Express"
      when 104 then "Cartão de crédito Diners"
      when 105 then "Cartão de crédito Hipercard"
      when 106 then "Cartão de crédito Aura"
      when 107 then "Cartão de crédito Elo"
      when 108 then "Cartão de crédito PLENOCard"
      when 109 then "Cartão de crédito PersonalCard"
      when 201 then "Boleto Bradesco"
      when 202 then "Boleto Santander"
      when 301 then "Débito online Bradesco"
      when 302 then "Débito online Itaú"
      when 303 then "Débito online Unibanco"
      when 304 then "Débito online Banco do Brasil"
      when 305 then "Débito online Banco Real"
      when 306 then "Débito online Banrisul"
      when 307 then "Débito online HSBC"
      when 401 then "Saldo PagSeguro"
      when 501 then "Oi Paggo"
      else "Desconhecido"
      end
    end
  end
end
