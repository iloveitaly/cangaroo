require 'rails_helper'

RSpec.describe Cangaroo::Translation, type: :model do
  let(:translation) { FactoryGirl.build(:translation) }

  before do
    Rails.configuration.cangaroo.payload_keys = ['id', 'order_id']
  end

  describe '#related_translations' do
    it 'returns other translation of this same object that have been sent through the pipeline' do
      translation.save!

      previous_translation = FactoryGirl.build(:translation)

      previous_translation.object_type = translation.object_type
      # copying the request will also copy the ID + key type on save
      previous_translation.request = translation.request.deep_dup
      previous_translation.request['another_field'] = Faker::Lorem.word
      previous_translation.save!

      expect(translation.related_translations).to_not be_empty
      expect(translation.related_translations.first.id).to eq(previous_translation.id)
    end

    it 'returns an empty collection when on previous objects exist' do
      expect(translation.related_translations).to be_empty
    end
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
