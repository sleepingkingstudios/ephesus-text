# frozen_string_literal: true

require 'ephesus/text/adapters/base_adapter'

RSpec.describe Ephesus::Text::Adapters::BaseAdapter do
  subject(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  describe '#add_observer' do
    it { expect(instance).to respond_to(:add_observer).with(1..2).arguments }
  end

  describe '#error' do
    let(:error_message) do
      'implement #output in an adapter subclass'
    end

    it { expect(instance).to respond_to(:error).with(1).argument }

    it 'should raise an error' do
      expect { instance.error 'something' }
        .to raise_error NotImplementedError, error_message
    end

    context 'when the subclass implements #output' do
      let(:string) { 'error string' }

      before(:example) do
        allow(instance).to receive(:output) # rubocop:disable RSpec/SubjectStub
      end

      it 'should delegate to #output' do
        instance.error(string)

        expect(instance).to have_received(:output).with(string)
      end
    end
  end

  describe '#input' do
    it { expect(instance).to respond_to(:input).with(1).argument }

    context 'when the adapter has an observer' do
      let(:string) { 'input string' }
      let(:observer) do
        double('observer', update: nil) # rubocop:disable RSpec/VerifiedDoubles
      end

      before(:example) { instance.add_observer(observer) }

      it 'should update the observer with the string' do
        instance.input(string)

        expect(observer).to have_received(:update).with(string)
      end
    end
  end

  describe '#output' do
    let(:error_message) do
      'implement #output in an adapter subclass'
    end

    it { expect(instance).to respond_to(:output).with(1).argument }

    it 'should raise an error' do
      expect { instance.output 'something' }
        .to raise_error NotImplementedError, error_message
    end
  end
end
