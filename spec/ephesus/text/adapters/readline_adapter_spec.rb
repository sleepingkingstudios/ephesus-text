# frozen_string_literal: true

require 'ephesus/text/adapters/readline_adapter'

RSpec.describe Ephesus::Text::Adapters::ReadlineAdapter do
  subject(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  describe '#add_observer' do
    it { expect(instance).to respond_to(:add_observer).with(1..2).arguments }
  end

  describe '#error' do
    let(:string) { 'error string' }

    it { expect(instance).to respond_to(:error).with(1).argument }

    it 'should write the string to STDERR' do
      expect { instance.error(string) }
        .to output("#{string}\n")
        .to_stderr
    end

    it { expect { instance.error(string) }.not_to output.to_stdout }
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
    let(:string) { 'output string' }

    it { expect(instance).to respond_to(:output).with(1).argument }

    it 'should write the string to STDOUT' do
      expect { instance.output(string) }
        .to output("#{string}\n")
        .to_stdout
    end

    it { expect { instance.output(string) }.not_to output.to_stderr }
  end

  describe '#start' do
    let(:inputs) { [] }

    before(:example) do
      allow(Readline).to receive(:readline).and_return(*inputs, nil)

      allow(instance).to receive(:input) # rubocop:disable RSpec/SubjectStub
    end

    it { expect(instance).to respond_to(:start).with(0).arguments }

    it 'should display an input prompt' do
      instance.start

      expect(Readline).to have_received(:readline).with('> ', true)
    end

    describe 'with a string input' do
      let(:inputs) { ['do something'] }

      it 'should call #input with the string' do
        instance.start

        expect(instance).to have_received(:input).with(inputs.first)
      end
    end

    describe 'with a sequence of string inputs' do
      let(:inputs) do
        [
          'do something',
          'do something else',
          'do the thing'
        ]
      end

      it 'should call #input with each string in order' do
        instance.start

        inputs.each do |input|
          expect(instance).to have_received(:input).with(input).ordered
        end
      end
    end

    describe 'with input: "exit"' do
      let(:inputs) do
        [
          'exit',
          'never do this'
        ]
      end

      it 'should close the prompt' do
        instance.start

        expect(Readline).to have_received(:readline).once
      end

      it 'should not call #input' do
        instance.start

        expect(instance).not_to have_received(:input)
      end
    end

    context 'when the exit strings are redefined' do
      let(:inputs) do
        [
          'exeunt',
          'never do this'
        ]
      end

      before(:example) do
        # rubocop:disable RSpec/SubjectStub
        allow(instance).to receive(:exit_strings).and_return(%w[exeunt])
        # rubocop:enable RSpec/SubjectStub
      end

      it 'should close the prompt' do
        instance.start

        expect(Readline).to have_received(:readline).once
      end

      it 'should not call #input' do
        instance.start

        expect(instance).not_to have_received(:input)
      end
    end
  end
end
