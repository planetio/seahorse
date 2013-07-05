require 'spec_helper'

describe Seahorse::FloatType do
  let(:instance) { described_class.new('test_float') }

  it 'is a kind of Type' do
    described_class.new.should be_kind_of(Seahorse::Type)
  end

  describe '#from_input' do
    it 'returns a Float from a String' do
      instance.from_input('1.5').should be_instance_of(Float)
    end

    it 'returns a Float from an Integer' do
      instance.from_input(42).should be_instance_of(Float)
    end
  end

  describe '#to_output' do
    it 'calls #pull_value and converts the result to a Float' do
      mock_data = mock('Object')
      instance.should_receive(:pull_value).with(mock_data).and_return('3.14')
      instance.to_output(mock_data).should be_instance_of(Float)
    end

    it 'returns nil if the pulled value is nil' do
      mock_data = mock('Object')
      instance.should_receive(:pull_value).with(mock_data).and_return(nil)
      instance.to_output(mock_data).should be_nil
    end

    it 'returns nil if the pulled value is False' do
      # This behavior is questionable but left as is for now for consistency
      # with IntegerType.
      mock_data = mock('Object')
      instance.should_receive(:pull_value).with(mock_data).and_return(false)
      instance.to_output(mock_data).should be_nil
    end
  end
end