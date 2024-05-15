require 'rails_helper'

describe 'Friendships', type: :request do
  let(:body) { JSON.parse(response.body) }
  let(:headers) { { "Accept" => "application/json", 'Content-Type' => 'application/json' } }

  let(:member1) { Member.create!(first_name: 'Test', last_name: 'One', url: 'https://example.com') }
  let(:member2) { Member.create!(first_name: 'Test', last_name: 'Two', url: 'https://google.com') }

  describe 'creating a friendship' do
    subject { post '/friendships', params: params.to_json, headers: headers }

    context 'with valid params' do
      let(:params) do
        {
          friendship: {
            member_id: member1.id,
            friend_id: member2.id,
          }
        }
      end

      it 'returns the correct status code' do
        subject
        expect(response).to have_http_status(:success)
      end
    end

    context 'with empty params' do
      let(:params) { {} }

      it 'returns the correct status code' do
        subject
        expect(response).not_to have_http_status(:success)
      end
    end
  end
end
