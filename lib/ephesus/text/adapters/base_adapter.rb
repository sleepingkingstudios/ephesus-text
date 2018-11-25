# frozen_string_literal: true

require 'observer'

require 'ephesus/text/adapters'

module Ephesus::Text::Adapters
  # Abstract IO handler class. Defines #input, #output and #error methods, which
  # are overriden by subclasses with specific implementations.
  class BaseAdapter
    include Observable

    def error(string)
      output(string)
    end

    def input(string)
      changed

      notify_observers(string)
    end

    def output(_string)
      raise NotImplementedError, 'implement #output in an adapter subclass'
    end
  end
end
