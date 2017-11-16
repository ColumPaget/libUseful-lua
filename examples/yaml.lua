require("dataparser")


yaml=[[
receipt:     Oz-Ware Purchase Invoice
date:        2012-08-06
customer:
    first_name:   Dorothy
    family_name:  Gale

items:
    - part_no:   A4786
      descrip:   Water Bucket (Filled)
      price:     1.47
      quantity:  4

    - part_no:   E1628
      descrip:   High Heeled Ruby Slippers
      size:      8
      price:     133.7
      quantity:  1

bill-to:  &id001
    street: |
            123 Tornado Alley
            Suite 16
    city:   East Centerville
    state:  KS

ship-to:  *id001

specialDelivery:  >
    Follow the Yellow Brick
    Road to the Emerald City.
    Pay no attention to the
    man behind the curtain.
]]

P=dataparser.PARSER("yaml",yaml)

print("DP: ".. P:value("receipt") .. "  " .. P:value("date"))

I=P:open("/customer")
print("Cust: ".. I:value("first_name") .. "  " .. I:value("family_name"))
print("Cust: ".. P:value("/customer/first_name") .. "  " .. P:value("/customer/family_name"))

