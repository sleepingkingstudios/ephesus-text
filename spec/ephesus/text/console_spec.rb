# frozen_string_literal: true

require 'ephesus/core/application'
require 'ephesus/core/controller'
require 'ephesus/core/session'
require 'ephesus/text/console'

RSpec.describe Ephesus::Text::Console do
  subject(:instance) { described_class.new(session) }

  let(:application) { Ephesus::Core::Application.new }
  let(:session)     { Spec::ExampleSession.new(application) }

  example_class 'Spec::ExampleSession', Ephesus::Core::Session do |klass|
    klass.controller Ephesus::Core::Controller
  end

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(1).argument
        .and_keywords(:parser)
    end
  end

  describe '#controller' do
    include_examples 'should have reader',
      :controller,
      -> { session.controller }
  end

  describe '#input' do
    it { expect(instance).to respond_to(:input).with(1).argument }

    describe 'with nil' do
      let(:parsed) do
        {
          arguments: nil,
          command:   nil,
          input:     nil,
          match:     false
        }
      end
      let(:result) { instance.input nil }
      let(:error_type) do
        result_class = Ephesus::Text::Commands::NoMatchingCommandResult

        result_class::NO_MATCHING_COMMAND_ERROR
      end
      let(:expected_error) do
        {
          type:   error_type,
          params: { input: nil }
        }
      end

      it { expect(result).to be_a Ephesus::Core::Commands::Result }

      it { expect(result.value).to be nil }

      it { expect(result.success?).to be false }

      it { expect(result.errors).to include expected_error }

      it { expect(result.data[:input]).to be nil }

      it { expect(result.data[:parsed]).to be == parsed }
    end

    describe 'with an empty string' do
      let(:parsed) do
        {
          arguments: nil,
          command:   nil,
          input:     '',
          match:     false
        }
      end
      let(:result) { instance.input '' }
      let(:error_type) do
        result_class = Ephesus::Text::Commands::NoMatchingCommandResult

        result_class::NO_MATCHING_COMMAND_ERROR
      end
      let(:expected_error) do
        {
          type:   error_type,
          params: { input: '' }
        }
      end

      it { expect(result).to be_a Ephesus::Core::Commands::Result }

      it { expect(result.value).to be nil }

      it { expect(result.success?).to be false }

      it { expect(result.errors).to include expected_error }

      it { expect(result.data[:input]).to be '' }

      it { expect(result.data[:parsed]).to be == parsed }
    end

    describe 'with a string that does not match a command' do
      let(:string) { 'do the Mario' }
      let(:parsed) do
        {
          arguments: nil,
          command:   nil,
          input:     string,
          match:     false
        }
      end
      let(:result) { instance.input string }
      let(:error_type) do
        result_class = Ephesus::Text::Commands::NoMatchingCommandResult

        result_class::NO_MATCHING_COMMAND_ERROR
      end
      let(:expected_error) do
        {
          type:   error_type,
          params: { input: string }
        }
      end

      before(:example) do
        allow(instance.parser)
          .to receive(:parse)
          .with(string)
          .and_return(parsed)
      end

      it 'should parse the input string' do
        instance.input(string)

        expect(instance.parser).to have_received(:parse).with(string)
      end

      it { expect(result).to be_a Ephesus::Core::Commands::Result }

      it { expect(result.value).to be nil }

      it { expect(result.success?).to be false }

      it { expect(result.errors).to include expected_error }

      it { expect(result.data[:input]).to be == string }

      it { expect(result.data[:parsed]).to be == parsed }
    end

    describe 'with a string that matches a command' do
      let(:string) { 'do the Mario' }
      let(:parsed) do
        {
          arguments: [{ dance: 'the Mario' }],
          command:   'dance',
          input:     string,
          match:     true
        }
      end
      let(:result) do
        Ephesus::Core::Commands::Result.new
      end

      before(:example) do
        allow(instance.parser)
          .to receive(:parse)
          .with(string)
          .and_return(parsed)

        allow(session.controller)
          .to receive(:execute_command)
          .and_return(result)
      end

      it 'should parse the input string' do
        instance.input(string)

        expect(instance.parser).to have_received(:parse).with(string)
      end

      it { expect(instance.input string).to be result }

      it { expect(instance.input(string).data[:input]).to be == string }

      it { expect(instance.input(string).data[:parsed]).to be == parsed }
    end
  end

  describe '#parser' do
    include_examples 'should have reader',
      :parser,
      -> { an_instance_of Ephesus::Text::Parser }

    it { expect(instance.parser.session).to be session }

    context 'when the console is initialized with a parser' do
      let(:parser)   { Ephesus::Text::Parser.new(session) }
      let(:instance) { described_class.new(session, parser: parser) }

      it { expect(instance.parser).to be parser }
    end

    context 'when the console defines a custom #build_parser method' do
      let(:described_class) { Spec::ExampleConsole }

      # rubocop:disable RSpec/DescribedClass
      example_class 'Spec::ExampleConsole', Ephesus::Text::Console do |klass|
        klass.send(:define_method, :build_parser) do |session|
          Spec::ExampleParser.new(session)
        end
      end
      # rubocop:enable RSpec/DescribedClass

      example_class 'Spec::ExampleParser', Ephesus::Text::Parser

      it { expect(instance.parser).to be_a Spec::ExampleParser }

      it { expect(instance.parser.session).to be session }

      # rubocop:disable RSpec/NestedGroups
      context 'when the console is initialized with a parser' do
        let(:parser)   { Ephesus::Text::Parser.new(session) }
        let(:instance) { described_class.new(session, parser: parser) }

        it { expect(instance.parser).to be parser }
      end
      # rubocop:enable RSpec/NestedGroups
    end
  end

  describe '#session' do
    include_examples 'should have reader', :session, -> { session }
  end
end
