require 'rails_helper'

RSpec.describe "Users", type: :request do
  include_context "db_cleanup_each"
  let!(:account) { signup FactoryGirl.attributes_for(:user) }
  let!(:alt_account) { signup FactoryGirl.attributes_for(:user) }
  let!(:admin_account) { apply_admin(signup FactoryGirl.attributes_for(:user)) }
  let!(:user_id)  { account[:id] }
  let!(:alt_user_id)  { alt_account[:id] }
  let!(:admin_id)  { admin_account[:id] }

  shared_examples "cannot index" do |status=:unauthorized|
    it "index fails with #{status}" do
      jget users_path
      expect(response).to have_http_status(status)
      expect(parsed_body).to include("errors")
    end
  end
  shared_examples "cannot show" do |status=:unauthorized|
    it "show fails with #{status}" do
      jget user_path(alt_user_id)
      expect(response).to have_http_status(status)
      expect(parsed_body).to include("errors")
    end
  end
  shared_examples "can index" do
    it "gets all users" do
      jget users_path
      expect(response).to have_http_status(:ok)
      payload=parsed_body
      expect(payload.length).to eq(3)
    end
  end
  shared_examples "can show" do
    it "can show" do
      jget user_path(user_id)
      expect(response).to have_http_status(:ok)
    end
  end
  shared_examples "can show another user" do
    it "can show" do
      jget user_path(alt_user_id)
      expect(response).to have_http_status(:ok)
    end
  end
  shared_examples "can show admin user" do
    it "can show" do
      jget user_path(alt_user_id)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "User authorization" do
    context "caller is unauthenticated" do
      before(:each) { logout }
      it_should_behave_like "cannot index", :unauthorized
      it_should_behave_like "cannot show",  :unauthorized
    end
    context "caller is authenticated" do
      let!(:user)   { login account }
      it_should_behave_like "cannot index", :forbidden
      context "other users" do
        it_should_behave_like "cannot show", :forbidden
      end
      context "self" do
        it_should_behave_like "can show"
      end
    end
    context "caller is admin" do
      before(:each) { login admin_account }
      it_should_behave_like "can index"
      context "other users" do
        it_should_behave_like "can show another user"
      end
      context "self" do
        it_should_behave_like "can show admin user"
      end
    end

  end

end
