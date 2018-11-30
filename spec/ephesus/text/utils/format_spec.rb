# frozen_string_literal: true

require 'ephesus/text/utils/format'

RSpec.describe Ephesus::Text::Utils::Format do
  describe '::format_command_help' do
    shared_context 'when the command has aliases' do
      before(:example) do
        properties[:aliases] << 'do the thing' << 'do it rockapella'
      end
    end

    shared_context 'when the command has a description' do
      before(:example) do
        properties[:description] = 'Does something, probably.'
      end
    end

    shared_context 'when the command has a full description' do
      before(:example) do
        full_description = <<~DESCRIPTION
          Does it do something? Does it ever! Let me tell you, this command does
          the thing. In fact, it does all the things! This thing? Does it. That
          thing? Does it. Doesn't do that, though. Not really sure why it would,
          to be honest. Why would you want it to do that? You monster.
        DESCRIPTION

        properties[:full_description] = full_description
      end
    end

    shared_context 'when the command has an argument' do
      before(:example) do
        properties[:arguments] << {
          name:        :thing,
          description: nil,
          required:    true
        }
      end
    end

    shared_context 'when the command has an argument with a description' do
      before(:example) do
        properties[:arguments] << {
          name:        :detailed_thing,
          description: 'Some details about the thing.',
          required:    true
        }
      end
    end

    shared_context 'when the command has an optional argument' do
      before(:example) do
        properties[:arguments] << {
          name:        :another_thing,
          description: nil,
          required:    false
        }
      end
    end

    shared_context 'when the command has many arguments' do
      include_context 'when the command has an argument'
      include_context 'when the command has an argument with a description'
      include_context 'when the command has an optional argument'
    end

    shared_context 'when the command has a keyword' do
      before(:example) do
        properties[:keywords][:strength] = {
          name:        :strength,
          description: nil,
          required:    false
        }
      end
    end

    shared_context 'when the command has a keyword with a description' do
      before(:example) do
        properties[:keywords][:speed] = {
          name:        :speed,
          description: 'How fast to do the thing.',
          required:    false
        }
      end
    end

    shared_context 'when the command has a required keyword' do
      before(:example) do
        properties[:keywords][:stamina] = {
          name:        :stamina,
          description: nil,
          required:    true
        }
      end
    end

    shared_context 'when the command has many keywords' do
      include_context 'when the command has a keyword'
      include_context 'when the command has a keyword with a description'
      include_context 'when the command has a required keyword'
    end

    shared_context 'when the command has an example' do
      before(:example) do
        properties[:examples] << {
          command:     'do something',
          description: 'Does something.',
          header:      nil
        }
      end
    end

    shared_context 'when the command has an example with a header' do
      before(:example) do
        properties[:examples] << {
          command:     'do something else',
          description: 'Does something else.',
          header:      'Doing Something Else'
        }
      end
    end

    shared_context 'when the command has an example with a long description' do
      before(:example) do
        description =
          "Swing your arms from side to side! Come on, it's time to go - Do " \
          "the Mario! Take one step, and then again. Let's do the Mario, all " \
          'together now!'

        properties[:examples] << {
          command:     'do the mario',
          description: description,
          header:      nil
        }
      end
    end

    shared_context 'when the command has many examples' do
      include_context 'when the command has an example'
      include_context 'when the command has an example with a header'
      include_context 'when the command has an example with a long description'
    end

    let(:properties) do
      {
        aliases:          ['do something'],
        arguments:        [],
        command_name:     'do something',
        description:      nil,
        examples:         [],
        full_description: nil,
        keywords:         {}
      }
    end
    let(:expected) do
      <<~STRING
        COMMAND - do something
          There is no description for this command.
      STRING
    end

    it 'should define the method' do
      expect(described_class)
        .to respond_to(:format_command_help)
        .with(1).argument
    end

    it 'should format the command properties' do
      expect(described_class.format_command_help(properties)).to be == expected
    end

    wrap_context 'when the command has aliases' do
      let(:expected) do
        <<~STRING
          COMMAND - do something (also "do the thing", "do it rockapella")
            There is no description for this command.
        STRING
      end

      it 'should format the command properties' do
        expect(described_class.format_command_help(properties))
          .to be == expected
      end
    end

    wrap_context 'when the command has a description' do
      let(:expected) do
        <<~STRING
          COMMAND - do something
            Does something, probably.
        STRING
      end

      it 'should format the command properties' do
        expect(described_class.format_command_help(properties))
          .to be == expected
      end
    end

    wrap_context 'when the command has a full description' do
      let(:expected) do
        <<~STRING
          COMMAND - do something
            There is no description for this command.

          DESCRIPTION
            Does it do something? Does it ever! Let me tell you, this command does the
            thing. In fact, it does all the things! This thing? Does it. That thing? Does
            it. Doesn't do that, though. Not really sure why it would, to be honest. Why
            would you want it to do that? You monster.
        STRING
      end

      it 'should format the command properties' do
        expect(described_class.format_command_help(properties))
          .to be == expected
      end
    end

    wrap_context 'when the command has an argument' do
      let(:expected) do
        <<~STRING
          COMMAND - do something
            There is no description for this command.

          ARGUMENTS
            thing (required)
        STRING
      end

      it 'should format the command properties' do
        expect(described_class.format_command_help(properties))
          .to be == expected
      end
    end

    wrap_context 'when the command has an argument with a description' do
      let(:expected) do
        <<~STRING
          COMMAND - do something
            There is no description for this command.

          ARGUMENTS
            detailed thing (required) - Some details about the thing.
        STRING
      end

      it 'should format the command properties' do
        expect(described_class.format_command_help(properties))
          .to be == expected
      end
    end

    wrap_context 'when the command has an optional argument' do
      let(:expected) do
        <<~STRING
          COMMAND - do something
            There is no description for this command.

          ARGUMENTS
            another thing (optional)
        STRING
      end

      it 'should format the command properties' do
        expect(described_class.format_command_help(properties))
          .to be == expected
      end
    end

    wrap_context 'when the command has many arguments' do
      let(:expected) do
        <<~STRING
          COMMAND - do something
            There is no description for this command.

          ARGUMENTS
            thing (required)

            detailed thing (required) - Some details about the thing.

            another thing (optional)
        STRING
      end

      it 'should format the command properties' do
        expect(described_class.format_command_help(properties))
          .to be == expected
      end
    end

    wrap_context 'when the command has a keyword' do
      let(:expected) do
        <<~STRING
          COMMAND - do something
            There is no description for this command.

          KEYWORDS
            strength (optional)
        STRING
      end

      it 'should format the command properties' do
        expect(described_class.format_command_help(properties))
          .to be == expected
      end
    end

    wrap_context 'when the command has a keyword with a description' do
      let(:expected) do
        <<~STRING
          COMMAND - do something
            There is no description for this command.

          KEYWORDS
            speed (optional) - How fast to do the thing.
        STRING
      end

      it 'should format the command properties' do
        expect(described_class.format_command_help(properties))
          .to be == expected
      end
    end

    wrap_context 'when the command has a required keyword' do
      let(:expected) do
        <<~STRING
          COMMAND - do something
            There is no description for this command.

          KEYWORDS
            stamina (required)
        STRING
      end

      it 'should format the command properties' do
        expect(described_class.format_command_help(properties))
          .to be == expected
      end
    end

    wrap_context 'when the command has many keywords' do
      let(:expected) do
        <<~STRING
          COMMAND - do something
            There is no description for this command.

          KEYWORDS
            strength (optional)

            speed (optional) - How fast to do the thing.

            stamina (required)
        STRING
      end

      it 'should format the command properties' do
        expect(described_class.format_command_help(properties))
          .to be == expected
      end
    end

    wrap_context 'when the command has an example' do
      let(:expected) do
        <<~STRING
          COMMAND - do something
            There is no description for this command.

          EXAMPLE
            "do something"
              Does something.
        STRING
      end

      it 'should format the command properties' do
        expect(described_class.format_command_help(properties))
          .to be == expected
      end
    end

    wrap_context 'when the command has an example with a header' do
      let(:expected) do
        <<~STRING
          COMMAND - do something
            There is no description for this command.

          EXAMPLE - Doing Something Else
            "do something else"
              Does something else.
        STRING
      end

      it 'should format the command properties' do
        expect(described_class.format_command_help(properties))
          .to be == expected
      end
    end

    wrap_context 'when the command has an example with a long description' do
      let(:expected) do
        <<~STRING
          COMMAND - do something
            There is no description for this command.

          EXAMPLE
            "do the mario"
              Swing your arms from side to side! Come on, it's time to go - Do the Mario!
              Take one step, and then again. Let's do the Mario, all together now!
        STRING
      end

      it 'should format the command properties' do
        expect(described_class.format_command_help(properties))
          .to be == expected
      end
    end

    wrap_context 'when the command has many examples' do
      let(:expected) do
        <<~STRING
          COMMAND - do something
            There is no description for this command.

          EXAMPLE
            "do something"
              Does something.

          EXAMPLE - Doing Something Else
            "do something else"
              Does something else.

          EXAMPLE
            "do the mario"
              Swing your arms from side to side! Come on, it's time to go - Do the Mario!
              Take one step, and then again. Let's do the Mario, all together now!
        STRING
      end

      it 'should format the command properties' do
        expect(described_class.format_command_help(properties))
          .to be == expected
      end
    end

    context 'when the command has many properties' do
      include_context 'when the command has aliases'
      include_context 'when the command has a description'
      include_context 'when the command has a full description'
      include_context 'when the command has many arguments'
      include_context 'when the command has many keywords'
      include_context 'when the command has many examples'

      let(:expected) do
        <<~STRING
          COMMAND - do something (also "do the thing", "do it rockapella")
            Does something, probably.

          DESCRIPTION
            Does it do something? Does it ever! Let me tell you, this command does the
            thing. In fact, it does all the things! This thing? Does it. That thing? Does
            it. Doesn't do that, though. Not really sure why it would, to be honest. Why
            would you want it to do that? You monster.

          ARGUMENTS
            thing (required)

            detailed thing (required) - Some details about the thing.

            another thing (optional)

          KEYWORDS
            strength (optional)

            speed (optional) - How fast to do the thing.

            stamina (required)

          EXAMPLE
            "do something"
              Does something.

          EXAMPLE - Doing Something Else
            "do something else"
              Does something else.

          EXAMPLE
            "do the mario"
              Swing your arms from side to side! Come on, it's time to go - Do the Mario!
              Take one step, and then again. Let's do the Mario, all together now!
        STRING
      end

      it 'should format the command properties' do
        expect(described_class.format_command_help(properties))
          .to be == expected
      end
    end
  end

  describe '::format_multiline_block' do
    it 'should define the method' do
      expect(described_class)
        .to respond_to(:format_multiline_block)
        .with(1).argument
        .and_keywords(:width)
    end

    describe 'with nil' do
      it { expect(described_class.format_multiline_block nil).to be == '' }
    end

    describe 'with an empty string' do
      it { expect(described_class.format_multiline_block '').to be == '' }
    end

    describe 'with a string' do
      let(:string)   { 'To strive, to seek, to find, and not to yield.' }
      let(:expected) { string }

      it 'should return the string' do
        expect(described_class.format_multiline_block string).to be == expected
      end
    end

    describe 'with a string with surrounding whitespace' do
      let(:string)   { "    To strive, to seek, to find, and not to yield.\n" }
      let(:expected) { string.strip }

      it 'should strip the whitespace' do
        expect(described_class.format_multiline_block string).to be == expected
      end
    end

    describe 'with a multiline string' do
      let(:string) do
        <<~STRING
          The lights begin to twinkle from the rocks;
          The long day wanes; the slow moon climbs; the deep
          Moans round with many voices. Come, my friends,
          'T is not too late to seek a newer world.
        STRING
      end
      let(:expected) do
        'The lights begin to twinkle from the rocks; ' \
        'The long day wanes; the slow moon climbs; the deep ' \
        'Moans round with many voices. Come, my friends, ' \
        "'T is not too late to seek a newer world."
      end

      it 'should unwrap adjacent lines' do
        expect(described_class.format_multiline_block string).to be == expected
      end
    end

    describe 'with a multiline string and width: 40' do
      let(:string) do
        <<~STRING
          The lights begin to twinkle from the rocks;
          The long day wanes; the slow moon climbs; the deep
          Moans round with many voices. Come, my friends,
          'T is not too late to seek a newer world.
        STRING
      end
      let(:expected) do
        "The lights begin to twinkle from the\n" \
        "rocks; The long day wanes; the slow moon\n" \
        "climbs; the deep Moans round with many\n" \
        "voices. Come, my friends, 'T is not too\n" \
        'late to seek a newer world.'
      end

      it 'should wrap the lines to the given width' do
        expect(described_class.format_multiline_block string, width: 40)
          .to be == expected
      end
    end

    describe 'with an indented multiline string' do
      let(:string) do
        <<-STRING
          The lights begin to twinkle from the rocks;
          The long day wanes; the slow moon climbs; the deep
          Moans round with many voices. Come, my friends,
          'T is not too late to seek a newer world.
        STRING
      end
      let(:expected) do
        'The lights begin to twinkle from the rocks; ' \
        'The long day wanes; the slow moon climbs; the deep ' \
        'Moans round with many voices. Come, my friends, ' \
        "'T is not too late to seek a newer world."
      end

      it 'should unwrap adjacent lines' do
        expect(described_class.format_multiline_block string).to be == expected
      end
    end

    describe 'with a string with multiple paragraphs' do
      let(:string) do
        <<~STRING
          What lies beyond the furthest reaches of the sky?
          That which will lead the lost child back to her mother's arms. Exile.

          The waves that flow and dye the land gold.
          The blessed breath that nurtures life. A land of wheat.

          The path the angels descend upon.
          The path of great winds. The Grand Stream.

          What lies within the furthest depths of one's memory?
          The place where all are born and where all will return. A blue star.
        STRING
      end
      let(:expected) do
        'What lies beyond the furthest reaches of the sky? ' \
        "That which will lead the lost child back to her mother's arms. " \
        'Exile.' \
        "\n\n" \
        'The waves that flow and dye the land gold. ' \
        'The blessed breath that nurtures life. A land of wheat.' \
        "\n\n" \
        'The path the angels descend upon. ' \
        'The path of great winds. The Grand Stream.' \
        "\n\n" \
        "What lies within the furthest depths of one's memory? " \
        'The place where all are born and where all will return. A blue star.'
      end

      it 'should format the string into paragraphs' do
        expect(described_class.format_multiline_block string).to be == expected
      end
    end
  end

  describe '::format_table' do
    it 'should define the method' do
      expect(described_class)
        .to respond_to(:format_table)
        .with(1).argument
        .and_keywords(:gutter)
    end

    describe 'with nil' do
      it { expect(described_class.format_table nil).to be == '' }
    end

    describe 'with an empty array' do
      it { expect(described_class.format_table []).to be == '' }
    end

    describe 'with an array of rows' do
      let(:rows) do
        [
          [:ichi, 1, 'the Number one'],
          [:ni,   2, 'the Number two'],
          [:san,  3, 'el Número tres']
        ]
      end
      let(:expected) do
        <<~TABLE
          ichi 1 the Number one
          ni   2 the Number two
          san  3 el Número tres
        TABLE
      end

      it { expect(described_class.format_table(rows)).to be == expected }

      describe 'with gutter: " | "' do # rubocop:disable RSpec/NestedGroups
        let(:expected) do
          <<~TABLE
            ichi | 1 | the Number one
            ni   | 2 | the Number two
            san  | 3 | el Número tres
          TABLE
        end

        it 'should format the table' do
          expect(described_class.format_table(rows, gutter: ' | '))
            .to be == expected
        end
      end
    end
  end
end
