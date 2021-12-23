# frozen_string_literal: true

FactoryBot.define do
  factory :simple_client, class: 'Fabric::Client' do
    transient do
      hostname { 'localhost:1234' }
      creds { :this_channel_is_insecure }
      client_opts { {} }
    end
    initialize_with { Fabric::Client.new(hostname, creds, client_opts) }
  end

  factory :identity, class: 'Fabric::Identity' do
    transient do
      private_key { nil }
      certificate { nil }
      msp_id { 'Org1MSP' }
    end

    initialize_with { Fabric::Identity.new(private_key: private_key, certificate: certificate, msp_id: msp_id) }
  end

  factory :gateway, class: 'Fabric::Gateway' do
    transient do
      signer { build(:identity) }
      client { build(:simple_client) }
    end

    initialize_with { Fabric::Gateway.new(signer, client) }
  end
end
