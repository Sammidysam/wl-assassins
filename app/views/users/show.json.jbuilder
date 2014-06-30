json.extract! @user, :id, :name, :graduation_year, :description, :profile_picture_url, :out_of_town, :role, :created_at, :updated_at
json.extract!(@user, :email) if @user.email_public
json.extract!(@user, :phone_number) if @user.phone_number_public
json.extract!(@user, :address) if @user.address_public
