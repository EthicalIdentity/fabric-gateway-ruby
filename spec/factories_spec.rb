# frozen_string_literal: true

RSpec.describe 'Factories' do
  describe 'Status' do
    context 'when passing successful trait' do
      let(:expected_attributes) do
        {
          transaction_id: 'factory_generated_transaction_id',
          block_number: 123,
          code: 0,
          successful: true
        }
      end

      it 'generates a successful status' do
        expect(build(:status, :successful)).to have_attributes(expected_attributes)
      end
    end

    context 'when passing unsuccessful trait' do
      let(:expected_attributes) do
        {
          transaction_id: 'factory_generated_transaction_id',
          block_number: 123,
          code: 1,
          successful: false
        }
      end

      it 'generates a successful status' do
        expect(build(:status, :unsuccessful)).to have_attributes(expected_attributes)
      end
    end
  end
end
