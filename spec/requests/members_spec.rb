require 'rails_helper'

describe 'Members', type: :request do
  let(:body) { JSON.parse(response.body) }
  let(:headers) { { "Accept" => "application/json", 'Content-Type' => 'application/json' } }

  let(:member1) { Member.create!(first_name: 'Test', last_name: 'One', url: 'https://example.com') }
  let(:member2) { Member.create!(first_name: 'Test', last_name: 'Two', url: 'https://everlyhealth.com') }
  let(:member3) { Member.create!(first_name: 'Test', last_name: 'Three', url: 'https://google.com') }
  let(:member4) { Member.create!(first_name: 'Test', last_name: 'Four', url: 'https://some-url.com') }
  let(:member5) { Member.create!(first_name: 'Test', last_name: 'Five', url: 'https://stackoverflow.com') }

  describe 'creating a member' do
    subject { post '/members', params: params.to_json, headers: headers }

    context 'with valid params' do
      let(:params) do
        {
          member: {
            first_name: 'Sandi',
            last_name: 'Metz',
            url: 'http://www.example.com'
          }
        }
      end

      it 'returns the correct status code' do
        subject
        expect(response).to have_http_status(:success)
      end
    end

    context 'with missing params' do
      let(:params) { {} }

      it 'returns the correct status code' do
        subject
        expect(response).not_to have_http_status(:success)
      end
    end
  end

  describe 'viewing all members' do
    subject { get '/members', headers: headers }

    it 'returns the correct status code' do
      subject
      expect(response).to have_http_status(:success)
    end

    it 'returns an array' do
      subject
      expect(body).to be_an_instance_of(Array)
    end
  end

  describe 'viewing a member' do
    context 'when member exists' do
      subject { get "/members/#{member1.id}", headers: headers }

      it 'returns the correct status code' do
        subject
        expect(response).to have_http_status(:success)
      end
    end

    context 'when member not fond' do
      subject { get '/members/0', headers: headers }

      it 'returns the correct status code' do
        subject
        expect(response).not_to have_http_status(:success)
      end
    end
  end

  describe 'searching for an expert' do
    let(:member2_content) { member2.headers.first.content.split(' | ').first }
    let(:member4_content) { member4.headers.first.content.split(' | ').first }
    let(:member5_content) { member5.headers.first.content.split(' | ').first }
    

    before do
      Friendship.create!(member_id: member1.id, friend_id: member2.id)
      Friendship.create!(member_id: member2.id, friend_id: member3.id)
      Friendship.create!(member_id: member3.id, friend_id: member4.id)
    end

    context 'when member exists and query is present' do
      subject { get "/members/#{member1.id}/search", params: { query: member4_content }, headers: headers }

      it 'returns the friend path to expert' do
        subject

        expect(response).to have_http_status(:success)
        expect(body).to be_an_instance_of(Array)
        expect(body).to eq([member1, member2, member3, member4].map(&:as_json))
      end
    end

    context 'when member is not present' do
      subject { get "/members/0/search", params: { query: member4_content }, headers: headers }

      it 'returns appropriate error response' do
        subject

        expect(response).not_to have_http_status(:success)
        expect(body).to include('error')
        expect(body['error']).to eq('Member not found')
      end
    end

    context 'when query is not present' do
      subject { get "/members/#{member1.id}/search", params: { query: '' }, headers: headers }

      it 'returns appropriate error response' do
        subject

        expect(response).not_to have_http_status(:success)
        expect(body).to include('error')
        expect(body['error']).to eq('Query not found')
      end
    end

    context 'when no expert is found' do
      subject { get "/members/#{member1.id}/search", params: { query: member2_content }, headers: headers }

      it 'returns appropriate error response' do
        subject

        expect(response).not_to have_http_status(:success)
        expect(body).to include('error')
        expect(body['error']).to eq('No expert found')
      end
    end

    context 'when no friend path is found' do
      subject { get "/members/#{member1.id}/search", params: { query: member5_content }, headers: headers }

      it 'returns appropriate error response' do
        subject

        expect(response).not_to have_http_status(:success)
        expect(body).to include('error')
        expect(body['error']).to eq('No friend path found')
      end
    end
  end
end
