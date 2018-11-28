# frozen_string_literal: true

require 'ephesus/core/commands/result'
require 'ephesus/core/controller'
require 'ephesus/core/session'
require 'ephesus/text/console/result_handlers'

RSpec.describe Ephesus::Text::Console::ResultHandlers do
  shared_context 'when #input returns a result' do
    let(:parsed) do
      {
        arguments: [],
        command:   command_name,
        input:     'do something',
        match:     true
      }
    end
    let(:command_class) { 'Spec::ExampleCommand' }
    let(:command_name)  { :do_something }
    let(:controller)    { 'Spec::ExampleController' }
    let(:result_value)  { 'result value' }
    let(:result_errors) { Bronze::Errors.new }
    let(:result) do
      Ephesus::Core::Commands::Result
        .new(result_value, errors: result_errors)
        .tap do |result|
          result.data[:command_class] = command_class
          result.data[:command_name]  = command_name
          result.data[:controller]    = controller
        end
    end

    example_class 'Spec::ExampleCommand', Ephesus::Core::Command

    before(:example) do
      allow(console.parser).to receive(:parse).and_return(parsed)

      allow(session).to receive(:execute_command).and_return(result)
    end
  end

  shared_context 'when the result is failing' do
    let(:error_type)   { 'spec.errors.example_error' }
    let(:error_params) { { key: 'value' } }

    before(:example) do
      result_errors.add(error_type, error_params)
    end
  end

  shared_context 'with an included handlers module' do
    let(:described_class) { Spec::ExampleHandlers }

    example_constant 'Spec::ExampleHandlers' do
      Module.new { include Ephesus::Text::Console::ResultHandlers }
    end

    before(:example) do
      Spec::ExampleConsole.send :include, described_class
    end
  end

  subject(:console) { Spec::ExampleConsole.new(session) }

  let(:described_class) { Spec::ExampleConsole }
  let(:session) do
    instance_double(Ephesus::Core::Session, execute_command: nil)
  end

  example_class 'Spec::ExampleConsole', Ephesus::Text::Console do |klass|
    # rubocop:disable RSpec/DescribedClass
    klass.send :include, Ephesus::Text::Console::ResultHandlers
    # rubocop:enable RSpec/DescribedClass
  end

  describe '::handle_command' do
    it 'should define the method' do
      expect(described_class)
        .to respond_to(:handle_command)
        .with(1).argument
        .and_keywords(:on)
        .and_a_block
    end

    wrap_context 'when #input returns a result' do
      describe 'with a non-matching command class' do
        example_class 'Spec::OtherCommand', Ephesus::Core::Command

        it 'should not yield' do
          expect do |block|
            described_class.handle_command(Spec::OtherCommand, &block)

            console.input('do something')
          end
            .not_to yield_control
        end
      end

      describe 'with a non-matching command class name' do
        example_class 'Spec::OtherCommand', Ephesus::Core::Command

        it 'should not yield' do
          expect do |block|
            described_class.handle_command('Spec::OtherCommand', &block)

            console.input('do something')
          end
            .not_to yield_control
        end
      end

      describe 'with a non-matching command name' do
        it 'should not yield' do
          expect do |block|
            described_class.handle_command(:do_nothing, &block)

            console.input('do something')
          end
            .not_to yield_control
        end
      end

      describe 'with a matching command class' do
        it 'should yield the result to the block' do
          expect do |block|
            described_class.handle_command(Spec::ExampleCommand, &block)

            console.input('do something')
          end
            .to yield_with_args(result)
        end
      end

      describe 'with a matching command class name' do
        it 'should yield the result to the block' do
          expect do |block|
            described_class.handle_command('Spec::ExampleCommand', &block)

            console.input('do something')
          end
            .to yield_with_args(result)
        end
      end

      describe 'with a matching command name' do
        it 'should yield the result to the block' do
          expect do |block|
            described_class.handle_command(command_name, &block)

            console.input('do something')
          end
            .to yield_with_args(result)
        end
      end

      describe 'with a matching command name and on: :success' do
        # rubocop:disable RSpec/NestedGroups
        context 'when the result is passing' do
          it 'should yield the result to the block' do
            expect do |block|
              described_class.handle_command(command_name, on: :success, &block)

              console.input('do something')
            end
              .to yield_with_args(result)
          end
        end

        wrap_context 'when the result is failing' do
          it 'should not yield' do
            expect do |block|
              described_class.handle_command(command_name, on: :success, &block)

              console.input('do something')
            end
              .not_to yield_control
          end
        end
        # rubocop:enable RSpec/NestedGroups
      end

      describe 'with a matching command name and on: :failure' do
        # rubocop:disable RSpec/NestedGroups
        context 'when the result is passing' do
          it 'should not yield' do
            expect do |block|
              described_class.handle_command(command_name, on: :failure, &block)

              console.input('do something')
            end
              .not_to yield_control
          end
        end

        wrap_context 'when the result is failing' do
          it 'should yield the result to the block' do
            expect do |block|
              described_class.handle_command(command_name, on: :failing, &block)

              console.input('do something')
            end
              .to yield_with_args(result)
          end
        end
        # rubocop:enable RSpec/NestedGroups
      end
    end

    wrap_context 'with an included handlers module' do
      wrap_context 'when #input returns a result' do
        describe 'with a non-matching command class' do
          example_class 'Spec::OtherCommand', Ephesus::Core::Command

          it 'should not yield' do
            expect do |block|
              described_class.handle_command(Spec::OtherCommand, &block)

              console.input('do something')
            end
              .not_to yield_control
          end
        end

        describe 'with a non-matching command class name' do
          example_class 'Spec::OtherCommand', Ephesus::Core::Command

          it 'should not yield' do
            expect do |block|
              described_class.handle_command('Spec::OtherCommand', &block)

              console.input('do something')
            end
              .not_to yield_control
          end
        end

        describe 'with a non-matching command name' do
          it 'should not yield' do
            expect do |block|
              described_class.handle_command(:do_nothing, &block)

              console.input('do something')
            end
              .not_to yield_control
          end
        end

        describe 'with a matching command class' do
          it 'should yield the result to the block' do
            expect do |block|
              described_class.handle_command(Spec::ExampleCommand, &block)

              console.input('do something')
            end
              .to yield_with_args(result)
          end
        end

        describe 'with a matching command class name' do
          it 'should yield the result to the block' do
            expect do |block|
              described_class.handle_command('Spec::ExampleCommand', &block)

              console.input('do something')
            end
              .to yield_with_args(result)
          end
        end

        describe 'with a matching command name' do
          it 'should yield the result to the block' do
            expect do |block|
              described_class.handle_command(command_name, &block)

              console.input('do something')
            end
              .to yield_with_args(result)
          end
        end

        describe 'with a matching command name and on: :success' do
          # rubocop:disable RSpec/ExampleLength
          # rubocop:disable RSpec/NestedGroups
          context 'when the result is passing' do
            it 'should yield the result to the block' do
              expect do |block|
                described_class
                  .handle_command(command_name, on: :success, &block)

                console.input('do something')
              end
                .to yield_with_args(result)
            end
          end

          wrap_context 'when the result is failing' do
            it 'should not yield' do
              expect do |block|
                described_class
                  .handle_command(command_name, on: :success, &block)

                console.input('do something')
              end
                .not_to yield_control
            end
          end
          # rubocop:enable RSpec/NestedGroups
        end

        describe 'with a matching command name and on: :failure' do
          # rubocop:disable RSpec/NestedGroups
          context 'when the result is passing' do
            it 'should not yield' do
              expect do |block|
                described_class
                  .handle_command(command_name, on: :failure, &block)

                console.input('do something')
              end
                .not_to yield_control
            end
          end

          wrap_context 'when the result is failing' do
            it 'should yield the result to the block' do
              expect do |block|
                described_class
                  .handle_command(command_name, on: :failing, &block)

                console.input('do something')
              end
                .to yield_with_args(result)
            end
          end
          # rubocop:enable RSpec/ExampleLength
          # rubocop:enable RSpec/NestedGroups
        end
      end
    end
  end

  describe '::handle_error' do
    it 'should define the method' do
      expect(described_class)
        .to respond_to(:handle_error)
        .with(0..1).arguments
        .and_a_block
    end

    wrap_context 'when #input returns a result' do
      context 'when the result is passing' do
        it 'should not yield' do
          expect do |block|
            described_class.handle_error(&block)

            console.input('do something')
          end
            .not_to yield_control
        end
      end

      wrap_context 'when the result is failing' do
        it 'should yield the result to the block' do
          expect do |block|
            described_class.handle_error(&block)

            console.input('do something')
          end
            .to yield_with_args(result)
        end

        describe 'with a non-matching error type' do
          let(:other_type) { 'spec.errors.other_error' }

          it 'should not yield' do
            expect do |block|
              described_class.handle_error(other_type, &block)

              console.input('do something')
            end
              .not_to yield_control
          end
        end

        describe 'with a matching error type' do
          it 'should yield the result and the error to the block' do
            expect do |block|
              described_class.handle_error(error_type, &block)

              console.input('do something')
            end
              .to yield_with_args(result, result.errors.first)
          end
        end
      end
    end

    wrap_context 'with an included handlers module' do
      include_context 'when #input returns a result'

      context 'when the result is passing' do
        it 'should not yield' do
          expect do |block|
            described_class.handle_error(&block)

            console.input('do something')
          end
            .not_to yield_control
        end
      end

      wrap_context 'when the result is failing' do
        it 'should yield the result to the block' do
          expect do |block|
            described_class.handle_error(&block)

            console.input('do something')
          end
            .to yield_with_args(result)
        end

        describe 'with a non-matching error type' do
          let(:other_type) { 'spec.errors.other_error' }

          it 'should not yield' do
            expect do |block|
              described_class.handle_error(other_type, &block)

              console.input('do something')
            end
              .not_to yield_control
          end
        end

        describe 'with a matching error type' do
          it 'should yield the result and the error to the block' do
            expect do |block|
              described_class.handle_error(error_type, &block)

              console.input('do something')
            end
              .to yield_with_args(result, result.errors.first)
          end
        end
      end
    end
  end

  describe '::handle_result' do
    it { expect(described_class).to respond_to(:handle_result).with_a_block }

    wrap_context 'when #input returns a result' do
      it 'should yield the result to the block' do
        expect do |block|
          described_class.handle_result(&block)

          console.input('do something')
        end
          .to yield_with_args(result)
      end
    end

    wrap_context 'with an included handlers module' do
      include_context 'when #input returns a result'

      it 'should yield the result to the block' do
        expect do |block|
          described_class.handle_result(&block)

          console.input('do something')
        end
          .to yield_with_args(result)
      end
    end
  end
end
