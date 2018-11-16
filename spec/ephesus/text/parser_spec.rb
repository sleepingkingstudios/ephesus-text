# frozen_string_literal: true

require 'ephesus/core/application'
require 'ephesus/core/controller'
require 'ephesus/core/command'
require 'ephesus/core/session'
require 'ephesus/text/parser'

RSpec.describe Ephesus::Text::Parser do
  subject(:instance) { described_class.new(session) }

  let(:application) { Ephesus::Core::Application.new }
  let(:session)     { Spec::ExampleSession.new(application) }

  example_class 'Spec::ExampleCommand', Ephesus::Core::Command

  example_class 'Spec::ExampleCommandWithKeywords', Ephesus::Core::Command \
  do |klass|
    klass.send :argument, :spell, required: false

    klass.send :keyword, :on

    klass.send :keyword, :with

    klass.send :keyword, :using
  end

  example_class 'Spec::ExampleController', Ephesus::Core::Controller do |klass|
    klass.command :cast, Spec::ExampleCommandWithKeywords

    klass.command :dance, Spec::ExampleCommand

    klass.command :do_the_mario, Spec::ExampleCommand

    klass.command :go, Spec::ExampleCommand

    klass.command :go_to, Spec::ExampleCommand

    klass.command :jump, Spec::ExampleCommand, aliases: %w[leap]
  end

  example_class 'Spec::ExampleSession', Ephesus::Core::Session do |klass|
    klass.controller Spec::ExampleController
  end

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end

  describe '#controller' do
    include_examples 'should have reader',
      :controller,
      -> { session.controller }
  end

  describe '#parse' do
    let(:expected) do
      {
        arguments: nil,
        command:   nil,
        match:     false
      }
    end

    it { expect(instance).to respond_to(:parse).with(1).argument }

    describe 'with nil' do
      let(:expected) { super().merge input: nil }

      it { expect(instance.parse nil).to be == expected }
    end

    describe 'with an Object' do
      let(:input)         { Object.new }
      let(:error_message) { "input must be a String, but was #{input.inspect}" }

      it 'should raise an error' do
        expect { instance.parse(input) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an empty string' do
      let(:expected) { super().merge input: '' }

      it { expect(instance.parse '').to be == expected }
    end

    describe 'with an invalid command string' do
      let(:input)    { 'defenestrate' }
      let(:expected) { super().merge input: input }

      it { expect(instance.parse input).to be == expected }
    end

    describe 'with a partial command string' do
      let(:input)    { 'da' }
      let(:expected) { super().merge input: input }

      it { expect(instance.parse input).to be == expected }
    end

    describe 'with a valid command string' do
      let(:input) { 'jump' }
      let(:expected) do
        {
          arguments: [],
          command:   :jump,
          input:     input,
          match:     true
        }
      end

      it { expect(instance.parse input).to be == expected }
    end

    describe 'with a valid command string with one argument' do
      let(:input) { 'jump across the chasm' }
      let(:expected) do
        {
          arguments: ['across the chasm'],
          command:   :jump,
          input:     input,
          match:     true
        }
      end

      it { expect(instance.parse input).to be == expected }
    end

    describe 'with a valid command string with many arguments' do
      let(:input) { 'dance the Charleston and the Lindy Hop and the Mario' }
      let(:expected) do
        {
          arguments: ['the Charleston', 'the Lindy Hop', 'the Mario'],
          command:   :dance,
          input:     input,
          match:     true
        }
      end

      it { expect(instance.parse input).to be == expected }
    end

    describe 'with a valid command string with arguments and keywords' do
      let(:input) do
        'cast empowered invoked apocalypse on goblin and jotun and ice slime ' \
        'with Brooch of Surtr and Staff of the Salamander using phoenix ' \
        'feather token and dust of Muspellheimr and radiant ruby'
      end
      let(:arguments) { 'empowered invoked apocalypse' }
      let(:keywords) do
        {
          on:    ['goblin', 'jotun', 'ice slime'],
          with:  ['Brooch of Surtr', 'Staff of the Salamander'],
          using: [
            'phoenix feather token',
            'dust of Muspellheimr',
            'radiant ruby'
          ]
        }
      end
      let(:expected) do
        {
          arguments: [*arguments, keywords],
          command:   :cast,
          input:     input,
          match:     true
        }
      end

      it { expect(instance.parse input).to be == expected }
    end

    describe 'with a multi-word command string' do
      let(:input) { 'do the Mario' }
      let(:expected) do
        {
          arguments: [],
          command:   :do_the_mario,
          input:     input,
          match:     true
        }
      end

      it { expect(instance.parse input).to be == expected }
    end

    describe 'with a multi-word command string with arguments' do
      let(:input) { 'do the Mario Luigi-style' }
      let(:expected) do
        {
          arguments: ['Luigi-style'],
          command:   :do_the_mario,
          input:     input,
          match:     true
        }
      end

      it { expect(instance.parse input).to be == expected }
    end

    describe 'with an aliased command string' do
      let(:input) { 'leap' }
      let(:expected) do
        {
          arguments: [],
          command:   :jump,
          input:     input,
          match:     true
        }
      end

      it { expect(instance.parse input).to be == expected }
    end

    describe 'with an aliased command string with arguments' do
      let(:input) { 'leap across the chasm' }
      let(:expected) do
        {
          arguments: ['across the chasm'],
          command:   :jump,
          input:     input,
          match:     true
        }
      end

      it { expect(instance.parse input).to be == expected }
    end

    describe 'with an ambiguous command string' do
      let(:input) { 'go to' }
      let(:expected) do
        {
          arguments: [],
          command:   :go_to,
          input:     input,
          match:     true
        }
      end

      it { expect(instance.parse input).to be == expected }
    end
  end

  describe '#session' do
    include_examples 'should have reader', :session, -> { session }
  end

  describe '#state' do
    include_examples 'should have reader', :state, -> { application.state }
  end
end
