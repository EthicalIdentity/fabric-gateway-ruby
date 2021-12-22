# frozen_string_literal: true

RSpec.describe Fabric do
  it 'has a version number' do
    expect(Fabric::VERSION).not_to be nil
  end

  it 'has errors' do
    expect(Fabric::Error.new).to be_a_kind_of(StandardError)
    expect(Fabric::InvalidArgument.new).to be_a_kind_of(Fabric::Error)
  end
end
