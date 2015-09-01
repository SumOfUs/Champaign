FactoryGirl.define do
  factory :action_user do
    first_name   { Faker::Name.first_name             }
    last_name    { Faker::Name.last_name              }
    email        { Faker::Internet.email              }
    country      { Faker::Address.country             }
    city         { Faker::Address.city                }
    postal_code  { Faker::Address.zip_code            }
    title        { Faker::Address.prefix              }
    address1     { Faker::Address.street_address      }
    address2     { Faker::Address.secondary_address   }
  end
end
