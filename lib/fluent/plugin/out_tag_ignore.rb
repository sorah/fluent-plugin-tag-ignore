require 'fluent/output'
require 'fluent/match'
require 'fluent-plugin-tag-ignore/version'

v = Fluent::TagIgnoreOutput::VERSION
module Fluent
  remove_const :TagIgnoreOutput
end

class Fluent::TagIgnoreOutput < Fluent::MultiOutput
  Fluent::Plugin.register_output('tag_ignore', self)

  def initialize(*)
    super
    @propagatee = nil
    @patterns = []
  end

  def configure(conf)
    super

    store = conf.elements.find { |e| e.name == 'store' }
    raise Fluent::ConfigError, 'Missing `store` for tag_ignore' unless store

    type = store['type']
    raise Fluent::ConfigError, 'Missing `type` for tag_ignore store configuration' unless type

    @propagatee = Fluent::Plugin.new_output(type)
    @propagatee.configure(store)

    @patterns = conf.elements.select { |e| e.name == 'ignore' }.map do |e|
      raise Fluent::ConfigError, 'Missing `glob` for tag_ignore ignore configuration' unless e['glob']
      Fluent::GlobMatchPattern.new(e['glob'])
    end
  end

  def start
    super
    @propagatee.start
  end

  def shutdown
    super
    @propagatee.shutdown
  end

  def emit(tag, es, chain)
    if @patterns.any? { |pat| pat.match(tag) }
      chain.next
      return
    end

    @propagatee.emit(tag, es, chain)
  end
end

Fluent::TagIgnoreOutput.send(:const_set, :VERSION, v)
