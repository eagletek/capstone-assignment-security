json.extract! user, :id, :uid, :name, :email, :created_at, :updated_at
json.roles(user.roles) do |role|
    json.partial! "roles/role", role: role
end
