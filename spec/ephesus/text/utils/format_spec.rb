# frozen_string_literal: true

require 'ephesus/text/utils/format'

RSpec.describe Ephesus::Text::Utils::Format do
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
