# frozen_string_literal: true

require 'ephesus/text/utils/format'

RSpec.describe Ephesus::Text::Utils::Format do
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
