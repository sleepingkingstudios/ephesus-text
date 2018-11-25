# frozen_string_literal: true

require 'ephesus/text/commands/no_matching_command_result'

RSpec.describe Ephesus::Text::Commands::NoMatchingCommandResult do
  subject(:instance) { described_class.new(parsed) }

  let(:input) { 'do something mysterious' }
  let(:parsed) do
    {
      arguments: nil,
      command:   nil,
      input:     input,
      match:     false
    }
  end

  describe '::NO_MATCHING_COMMAND_ERROR' do
    it 'should define the constant' do
      expect(described_class)
        .to define_constant(:NO_MATCHING_COMMAND_ERROR)
        .frozen
        .with_value('ephesus.text.errors.no_matching_command')
    end
  end

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(1).argument
        .and_any_keywords
    end
  end

  describe '#data' do
    it { expect(instance.data[:input]).to be == input }

    it { expect(instance.data[:parsed]).to be == parsed }
  end

  describe '#errors' do
    let(:expected_error) do
      {
        type:   described_class::NO_MATCHING_COMMAND_ERROR,
        params: { input: input }
      }
    end

    it { expect(instance.errors).to include expected_error }
  end

  describe '#failure?' do
    it { expect(instance.failure?).to be true }
  end

  describe '#success?' do
    it { expect(instance.success?).to be false }
  end
end
