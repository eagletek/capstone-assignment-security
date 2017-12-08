json.id role.id
json.user_id role.user_id
json.role_name role.role_name
json.mname role.mname
json.mid role.mid
if role.mname && role.mid
  item = role.mname.classify.constantize.find(role.mid)
  desc = item.respond_to?("name") ? item.name : (item.respond_to?("caption") ? item.caption : nil)
  json.mdescriptor desc
end
json.created_at role.created_at
json.updated_at role.updated_at
