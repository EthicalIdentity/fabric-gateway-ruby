# frozen_string_literal: true

RSpec.describe Fabric do
  it 'has a version number' do
    expect(Fabric::VERSION).not_to be_nil
  end

  it { expect(Fabric::Error.new).to be_a(StandardError) }
  it { expect(Fabric::InvalidArgument.new).to be_a(Fabric::Error) }
  it { expect(Fabric::NotYetImplemented.new).to be_a(Fabric::Error) }
end
