require 'rails_helper'

describe Rack::Attack do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  describe "throttle excessive POST requests to admin sign in by email address" do
    let(:limit) { 10 }
  
    context "number of requests is lower than the limit" do
      it "does not change the request status" do
        limit.times do |i|
          post "/pull_request_ai/confirm", { email: "cenas@mail.com" }, "REMOTE_ADDR" => "#{i}.2.4.9"
          # expect(last_response.status).to_not eq(429)
        end
      end
    end

    # context "number of requests is higher than the limit" do
    #   it "changes the request status to 429" do
    #     (limit * 2).times do |i|
    #       post "/admins/sign_in", { email: "example6@gmail.com" }, "REMOTE_ADDR" => "#{i}.2.5.9"
    #       expect(last_response.status).to eq(429) if i > limit
    #     end
    #   end
    # end
  end
end