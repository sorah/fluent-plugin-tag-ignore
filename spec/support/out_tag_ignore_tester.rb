require 'fluent/test'

class Fluent::TagIgnoreTesterOutput < Fluent::Output
  Fluent::Plugin.register_output('tag_ignore_tester', self)

  config_param :foo, :string, :default => 'bar'

  class << self
    def records
      @records ||= []
    end
  end

  def emit(tag, es, chain)
    es.each do |t, record|
      if tag == 'foo'
        self.class.records << ['foo', @foo]
      else
        self.class.records << [tag, record]
      end
    end

    chain.next
  end
end
