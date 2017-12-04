json.array!(@roles) do |role|
  json.partial! "roles/role", role: role
end
