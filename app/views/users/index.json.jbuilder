json.array!(@users) do |user|
  json.extract! user, :id, :name, :email, :password_digest, :phone_number, :phone_number_public, :address, :address_public, :graduation_year, :description, :profile_picture_url, :admin, :out_of_town, :willing_to_pay_amount, :paid_amount
  json.url user_url(user, format: :json)
end
