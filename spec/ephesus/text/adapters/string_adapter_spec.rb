# frozen_string_literal: true

require 'ephesus/text/adapters/string_adapter'

RSpec.describe Ephesus::Text::Adapters::StringAdapter do
  shared_context 'when initialized with an output buffer' do
    let(:output_buffer) { StringIO.new }
    let(:instance)      { described_class.new(output_buffer) }
  end

  shared_context 'when initialized with output and error buffers' do
    let(:output_buffer) { StringIO.new }
    let(:error_buffer)  { StringIO.new }
    let(:instance)      { described_class.new(output_buffer, error_buffer) }
  end

  subject(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..2).arguments }
  end

  describe '#add_observer' do
    it { expect(instance).to respond_to(:add_observer).with(1..2).arguments }
  end

  describe '#error' do
    let(:string) { 'error string' }

    it { expect(instance).to respond_to(:error).with(1).argument }

    it 'should append the string to the error buffer' do
      expect { instance.error string }
        .to change(instance, :error_string)
        .to be == "#{string}\n"
    end

    wrap_context 'when initialized with an output buffer' do
      it 'should append the string to the error buffer' do
        expect { instance.error string }
          .to change(instance, :error_string)
          .to be == "#{string}\n"
      end
    end

    wrap_context 'when initialized with output and error buffers' do
      it 'should append the string to the error buffer' do
        expect { instance.error string }
          .to change(instance, :error_string)
          .to be == "#{string}\n"
      end

      it 'should not change the output buffer' do
        expect { instance.error string }.not_to change(instance, :output_string)
      end
    end
  end

  describe '#error_buffer' do
    include_examples 'should have reader',
      :error_buffer,
      -> { an_instance_of StringIO }

    wrap_context 'when initialized with an output buffer' do
      it { expect(instance.error_buffer).to be output_buffer }
    end

    wrap_context 'when initialized with output and error buffers' do
      it { expect(instance.error_buffer).to be error_buffer }
    end
  end

  describe '#error_string' do
    include_examples 'should have reader',
      :error_string,
      -> { instance.output_buffer.string }

    wrap_context 'when initialized with an output buffer' do
      it { expect(instance.error_string).to be instance.output_buffer.string }
    end

    wrap_context 'when initialized with output and error buffers' do
      it { expect(instance.error_string).to be instance.error_buffer.string }
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
    let(:string) { 'output string' }

    it { expect(instance).to respond_to(:output).with(1).argument }

    it 'should append the string to the output buffer' do
      expect { instance.output string }
        .to change(instance, :output_string)
        .to be == "#{string}\n"
    end

    wrap_context 'when initialized with an output buffer' do
      it 'should append the string to the output buffer' do
        expect { instance.output string }
          .to change(instance, :output_string)
          .to be == "#{string}\n"
      end
    end

    wrap_context 'when initialized with output and error buffers' do
      it 'should append the string to the output buffer' do
        expect { instance.output string }
          .to change(instance, :output_string)
          .to be == "#{string}\n"
      end

      it 'should not change the error buffer' do
        expect { instance.output string }.not_to change(instance, :error_string)
      end
    end
  end

  describe '#output_buffer' do
    include_examples 'should have reader',
      :output_buffer,
      -> { an_instance_of StringIO }

    wrap_context 'when initialized with an output buffer' do
      it { expect(instance.output_buffer).to be output_buffer }
    end

    wrap_context 'when initialized with output and error buffers' do
      it { expect(instance.output_buffer).to be output_buffer }
    end
  end

  describe '#output_string' do
    include_examples 'should have reader',
      :output_string,
      -> { instance.output_buffer.string }

    wrap_context 'when initialized with an output buffer' do
      it { expect(instance.output_string).to be instance.output_buffer.string }
    end

    wrap_context 'when initialized with output and error buffers' do
      it { expect(instance.output_string).to be instance.output_buffer.string }
    end
  end
end
