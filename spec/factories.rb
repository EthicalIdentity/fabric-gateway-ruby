FactoryBot.define do
  factory :simple_client, class: "Fabric::Client" do
    transient do
      hostname { "localhost:1234" }
      creds { :this_channel_is_insecure }
      client_opts { {}}
    end
    initialize_with { Fabric::Client.new(hostname, creds, client_opts) }
  end
end