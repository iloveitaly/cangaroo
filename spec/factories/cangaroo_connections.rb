FactoryGirl.define do
  factory :cangaroo_connection, class: 'Cangaroo::Connection' do
    name :store
    url 'www.store.com'
    parameters { { first: 'first', second: 'second' } }
    key { SecureRandom.hex(13) }
    token { SecureRandom.hex(13) }
  end
end
