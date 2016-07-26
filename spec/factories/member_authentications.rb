FactoryGirl.define do
  factory :member_authentication do
    member nil
    password_digest do
      BCrypt::Password.create(Digest::MD5.hexdigest(Faker::Lorem.characters))
    end
    facebook_uid { Faker::Number.number(8) }
    facebook_token { Digest::SHA256.hexdigest(Faker::Lorem.characters) }
    facebook_token_expiry { Faker::Date.forward }
  end
end

