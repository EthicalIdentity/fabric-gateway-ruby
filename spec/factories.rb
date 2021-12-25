# frozen_string_literal: true

FactoryBot.define do
  factory :simple_client, class: 'Fabric::Client' do
    transient do
      host { 'localhost:1234' }
      creds { :this_channel_is_insecure }
      client_opts { {} }
    end
    initialize_with { Fabric::Client.new(host: host, creds: creds, **client_opts) }
  end

  factory :identity, class: 'Fabric::Identity' do
    trait :user1 do
      transient do
        private_key { Fabric.crypto_suite.key_from_pem(File.read("#{RSPEC_ROOT}/fixtures/user1_privkey.pem")) }
        certificate { File.read("#{RSPEC_ROOT}/fixtures/user1_cert.pem") }
        msp_id { 'Org1MSP' }
      end
    end

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

  factory :network, class: 'Fabric::Network' do
    transient do
      gateway { build(:gateway) }
      name { 'testnet' }
    end

    initialize_with { Fabric::Network.new(gateway, name) }
  end

  factory :contract, class: 'Fabric::Contract' do
    transient do
      network { build(:network) }
      chaincode_name { 'testchaincode' }
      contract_name { 'testcontract' }
    end

    initialize_with { Fabric::Contract.new(network, chaincode_name, contract_name) }
  end

end
