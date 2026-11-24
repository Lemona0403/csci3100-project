RSpec.describe "login", type: :request do
  it "redirects guests to login" do
    get items_path
    expect(response).to redirect_to(new_user_session_path)
  end
end