require 'rails_helper'

RSpec.describe Cangaroo::Translation, type: :model do
  let(:translation) { FactoryGirl.build(:translation) }

  before do
    Rails.configuration.cangaroo.payload_keys = ['id', 'order_id']
  end

  describe "#object_key" do
    it "chooses the first primary key available" do
      translation.request = {
        "id" => nil,
        "order_id" => 123
      }

      expect(translation.object_key).to eq("order_id")
      expect(translation.object_id).to eq("123")
    end

    it 'returns nil when no key is available' do
      translation.request = {
        "order_id" => nil
      }

      expect(translation.object_key).to be_nil
      expect(translation.object_id).to be_nil
    end
  end
end
