require 'rails_helper'

RSpec.describe "Roles", type: :request do
  include_context "db_cleanup_each"
  let!(:account) { signup FactoryGirl.attributes_for(:user) }
  let!(:alt_account) { signup FactoryGirl.attributes_for(:user) }
  let!(:admin_account) { apply_admin(signup FactoryGirl.attributes_for(:user)) }
  let!(:user_id)  { account[:id] }
  let!(:alt_user_id)  { alt_account[:id] }
  let!(:admin_id)  { admin_account[:id] }

  let!(:thing1) { FactoryGirl.create(:thing) }
  let!(:thing2) { FactoryGirl.create(:thing) }
  let!(:thing3) { FactoryGirl.create(:thing) }
  let!(:role1) { apply_organizer(account, thing1) }
  let!(:role2) { apply_member(account, thing1) }
  let!(:role3) { apply_member(account, thing2) }
  let!(:role4) { apply_organizer(account, thing3) }
  let!(:alt_role) { apply_member(alt_account, thing3) }

  shared_examples "cannot index" do |status=:unauthorized|
    it "index fails with #{status}" do
      jget user_roles_path(alt_user_id)
      expect(parsed_body).to include("errors")
    end
  end
  shared_examples "cannot show" do |status=:unauthorized|
    it "show fails with #{status}" do
      jget user_roles_path(alt_user_id)
      expect(response).to have_http_status(status)
      expect(parsed_body).to include("errors")
    end
  end
  shared_examples "cannot create" do |status=:unauthorized, role=Role::MEMBER|
    it "create #{role} fails with #{status}" do
      jpost user_roles_path(alt_user_id), {role_name: role, mname:Thing.name, mid:thing2[:id]}
      expect(response).to have_http_status(status)
      expect(parsed_body).to include("errors")
    end
  end
  shared_examples "cannot delete" do |status=:unauthorized|
    it "delete role fails with #{status}" do
      jdelete user_role_path(alt_user_id, User.find(alt_user_id).roles.first.id)
      expect(response).to have_http_status(status)
      expect(parsed_body).to include("errors")
    end
  end
  shared_examples "can index" do
    it "gets all user roles" do
      jget user_roles_path(user_id)
      expect(response).to have_http_status(:ok)
      payload=parsed_body
      expect(payload.length).to eq(4)
    end
  end
  shared_examples "can create" do |role=Role::MEMBER|
    it "creates #{role}" do
      jpost user_roles_path(alt_user_id), {role_name: role, mname:Thing.name, mid:thing1[:id]}
      expect(response).to have_http_status(:created)
      payload=parsed_body
      expect(payload).to include("role_name"=>role)
    end
  end
  shared_examples "can delete" do
    it "deletes role" do
      jdelete user_role_path(alt_user_id, User.find(alt_user_id).roles.first.id)
      expect(response).to have_http_status(:no_content)
    end
  end
  shared_examples "index other user roles" do |count=0|
    it "gets #{count} other user roles" do
      jget user_roles_path(alt_user_id)
      expect(response).to have_http_status(:ok)
      payload=parsed_body
      expect(payload.length).to eq(count)
    end
  end
  shared_examples "can show" do
    it "can show" do
      jget user_role_path(user_id, User.find(user['id']).roles.first[:id])
      expect(response).to have_http_status(:ok)
    end
  end
  shared_examples "can index admin user" do
    it "can index" do
      jget user_roles_path(admin_id)
      expect(response).to have_http_status(:ok)
      payload=parsed_body
      expect(payload.length).to eq(1)
    end
  end

  describe "User authorization" do
    context "caller is unauthenticated" do
      before(:each) { logout }
      it_should_behave_like "cannot index",  :unauthorized
      it_should_behave_like "cannot show",   :unauthorized
      it_should_behave_like "cannot create", :unauthorized
      it_should_behave_like "cannot delete", :unauthorized
    end
    context "caller is authenticated" do
      let!(:user)   { login account }
      it_should_behave_like "can index"
      context "other users" do
        it_should_behave_like "index other user roles", 0
        it_should_behave_like "cannot create", :forbidden
      end
      context "self" do
        it_should_behave_like "can show"
      end
      context "organizer" do
        it_should_behave_like "can create"
        it_should_behave_like "can delete"
      end
    end
    context "caller is admin" do
      before(:each) { login admin_account }
      context "other users" do
        it_should_behave_like "can index"
        it_should_behave_like "index other user roles", 1
        it_should_behave_like "can create", Role::ADMIN
      end
      context "self" do
        it_should_behave_like "can index admin user"
      end
    end

  end

end
