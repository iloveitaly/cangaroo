FactoryGirl.define do
  factory :translation, class: 'Cangaroo::Translation' do
    source_connection { FactoryGirl.create(:cangaroo_connection, name: Faker::Company.name, url: Faker::Internet.domain_name) }
    destination_connection { FactoryGirl.create(:cangaroo_connection, name: Faker::Company.name, url: Faker::Internet.domain_name) }

    job_id { SecureRandom.uuid }
    object_type 'customers'

    request {
      {
        "id" => SecureRandom.random_number(1000),
        "updated_at" => DateTime.now.iso8601,
        "created_at" => DateTime.now.iso8601
      }
    }
  end
end
