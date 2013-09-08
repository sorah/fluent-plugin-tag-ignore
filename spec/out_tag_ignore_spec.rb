require 'spec_helper'
require 'fluent/test'
require 'fluent/plugin/out_tag_ignore'
require_relative 'support/out_tag_ignore_tester'

describe Fluent::TagIgnoreOutput do
  before(:each) do
    Fluent::TagIgnoreTesterOutput.records.clear
    Fluent::Test.setup
  end


  let(:tag) { 'test' }

  let(:conf) do
    <<-EOC
<store>
  type tag_ignore_tester
</store>
    EOC
  end

  let(:driver) do
    Fluent::Test::OutputTestDriver.new(described_class, tag).configure(conf)
  end

  let(:time) { Time.now }

  it "propagates to <store>" do
    expect {
      driver.run { driver.emit({'msg' => 'message'}, time) }
    }.to change { Fluent::TagIgnoreTesterOutput.records.last } \
     .from(nil).to(['test', 'msg' => 'message'])
  end

  context "with ignore pattern" do
    let(:conf) do
      <<-EOC
<ignore>
  glob rej.**
</ignore>

<store>
  type tag_ignore_tester
</store>
      EOC
    end

    it "doesn't propagate logs with matched tag" do
      expect {
        driver.tag = 'test';     driver.run { driver.emit({'m' => 'msg'}, time) }
        driver.tag = 'rej.test'; driver.run { driver.emit({'m' => 'rej'}, time) }
      }.to change { Fluent::TagIgnoreTesterOutput.records.size } \
       .from(0).to(1)

      expect(Fluent::TagIgnoreTesterOutput.records.last).to \
        eq(['test', 'm' => 'msg'])
    end
  end

  context "with many ignore patterns" do
    let(:conf) do
      <<-EOC
<ignore>
  glob rej.**
</ignore>

<ignore>
  glob deny.**
</ignore>

<store>
  type tag_ignore_tester
</store>
      EOC
    end

    it "doesn't propagate logs with matched tag" do
      expect {
        driver.tag = 'deny.test'; driver.run { driver.emit({'m' => 'deny'}, time) }
        driver.tag = 'test';     driver.run { driver.emit({'m' => 'msg'}, time) }
        driver.tag = 'rej.test'; driver.run { driver.emit({'m' => 'rej'}, time) }
      }.to change { Fluent::TagIgnoreTesterOutput.records.size } \
       .from(0).to(1)

      expect(Fluent::TagIgnoreTesterOutput.records.last).to \
        eq(['test', 'm' => 'msg'])
    end
  end

  context "with store configuration" do
    let(:conf) do
      <<-EOC
<store>
  type tag_ignore_tester
  foo baz
</store>
      EOC
    end
    let(:tag) { 'foo' }

    it "uses substore configuration" do
      expect {
        driver.run { driver.emit({'msg' => 'message'}, time) }
      }.to change { Fluent::TagIgnoreTesterOutput.records.last } \
       .from(nil).to(['foo', 'baz'])
    end
  end
end
