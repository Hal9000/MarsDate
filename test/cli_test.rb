#!/usr/bin/env ruby
# CLI regression tests.
# Run: ruby test/cli_test.rb

require 'minitest/autorun'
require 'open3'
require 'rbconfig'
require_relative '../lib/marsdate'

class CliTest < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  BIN = File.join(ROOT, 'bin', 'marsdate')
  LIB = File.join(ROOT, 'lib')

  def test_calendar_does_not_highlight_today_in_another_year
    other_year = [MarsDateTime.today.year - 1, 1].max
    other_year += 1 if other_year == MarsDateTime.today.year
    path = "/tmp/m#{other_year}.html"

    stdout, stderr, status = run_cli('calendar', other_year.to_s)
    assert status.success?, stderr
    assert_includes stdout, path
    html = File.read(path)
    refute_includes html, 'bgcolor=FFD0BF'
    refute_includes html, 'bgcolor=FFB0A0'
  ensure
    File.delete(path) if path && File.exist?(path)
  end

  def test_invocation_error_exits_nonzero
    _stdout, stderr, status = run_cli('m2e', 'nonsense')

    refute status.success?
    assert_includes stderr, 'Error in calling m2e:'
  end

  def test_wrong_argument_count_exits_nonzero
    stdout, stderr, status = run_cli('one', 'two', 'three', 'four')

    refute status.success?
    assert_includes stderr, 'Wrong number of arguments'
    assert_includes stdout, 'Usage:'
  end

  def test_valid_command_exits_zero
    stdout, stderr, status = run_cli('version')

    assert status.success?, stderr
    assert_equal "#{MarsDateTime::VERSION}\n", stdout
  end

  private

  def run_cli(*args)
    Open3.capture3(RbConfig.ruby, "-I#{LIB}", BIN, *args)
  end
end
