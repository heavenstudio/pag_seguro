# encoding: UTF-8
FactoryGirl.define do
  factory :day_of_year, class: PagSeguro::DayOfYear do
    day                   7
    month                 7
  end

  factory :item, class: PagSeguro::Item do
    id                    1
    description           "descrevendo um item"
    amount                "100.50"
    quantity              1
    shipping_cost         nil
    weight                nil

    factory :item_1 do
      id                  25
      description         'A Bic Pen'
      amount              '1.50'
      quantity            '4'
      shipping_cost       '1.00'
      weight              10
    end

    factory :item_2 do
      id                  73
      description         'A Book & Cover'
      amount              '38.23'
      quantity            '1'
      shipping_cost       '12.00'
      weight              300
    end

    factory :item_3 do
      id                  95
      description         'A Towel'
      amount              '69.35'
      quantity            '2'
      weight              400
    end

    factory :item_4 do
      id                  17
      description         'A pipe'
      amount              '3.00'
      quantity            '89'
    end
  end

  factory :payment, class: PagSeguro::Payment do
    ignore do
      email               'myemail'
      token               'mytoken'
    end
    items                 []
    shipping              nil
    sender                nil
    pre_approval          nil

    initialize_with { new(email, token) }

    factory(:payment_with_item)                 { items { [build(:item)] } }
    factory(:payment_with_items)                { items { [build(:item_1), build(:item_2), build(:item_3), build(:item_4)] } }
    factory(:payment_with_sender)               { sender { build(:sender) } }
    factory(:payment_with_shipping)             { shipping { build(:shipping) } }
    factory(:payment_with_pre_approval)         { pre_approval { build(:pre_approval) } }
    factory(:payment_with_weekly_pre_approval)  { pre_approval { build(:weekly_pre_approval) } }
    factory(:payment_with_monthly_pre_approval) { pre_approval { build(:monthly_pre_approval) } }
    factory(:payment_with_yearly_pre_approval)  { pre_approval { build(:yearly_pre_approval) } }
    factory :payment_with_all_fields do
      items               { [build(:item_1), build(:item_2), build(:item_3), build(:item_4)] }
      shipping            { build(:shipping) }
      sender              { build(:sender) }
      pre_approval        { build(:weekly_pre_approval) }
    end
  end

  factory :payment_method, class: PagSeguro::PaymentMethod do
    code                  101
    type                  1
  end

  factory :minimum_pre_approval, class: PagSeguro::PreApproval do
    name                  "Super seguro para notebook"
    final_date            Date.new(2014, 1, 17)
    max_amount_per_period BigDecimal.new('200.00')
    max_total_amount      BigDecimal.new('900.00')
    period                :weekly
    day_of_week           :monday
    details               nil
    initial_date          nil
    amount_per_payment    nil
    review_URL            nil

    factory :pre_approval do
      details             "Toda segunda feira será cobrado o valor de R$150,00 para o seguro do notebook"
      amount_per_payment  BigDecimal.new('150.00')
      initial_date        Date.new(2015, 1, 17)
      final_date          Date.new(2017, 1, 17)
      review_URL          "http://sounoob.com.br/produto1"
    end

    factory :weekly_pre_approval do
      period              :weekly
      day_of_week         :monday
    end

    factory :monthly_pre_approval do
      period              :monthly
      day_of_month        3
    end

    factory :yearly_pre_approval do
      period              :yearly
      day_of_year         PagSeguro::DayOfYear.new(day: 1, month: 3)
    end
  end

  factory :shipping, class: PagSeguro::Shipping do
    type                  PagSeguro::Shipping::SEDEX
    state                 "SP"
    city                  "São Paulo"
    postal_code           "05363000"
    district              "Jd. PoliPoli"
    street                "Av. Otacilio Tomanik"
    number                "775"
    complement            "apto. 92"
    cost                  "12.13"
  end

  factory :sender, class: PagSeguro::Sender do
    name                  "Stefano Diem Benatti"
    email                 "stefano@heavenstudio.com.br"
    phone_ddd             11
    phone_number          993430994
  end
end
