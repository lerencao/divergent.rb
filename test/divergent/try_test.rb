require 'test_helper'

class TryTest < Minitest::Test
  include Divergent
  def test_unit
    assert Try.unit { :a }.is_a? Try
  end

  def test_fmap
    a = Try.unit { :a }
    r = a.fmap { |x| Try.unit { x.to_sym } }
    assert r.is_a? Try
  end

  def test_failure
    assert Try { raise 'failure' }.failure?
    assert !Try { 1 }.failure?
  end

  def test_success
    assert !Try { raise 'failure' }.success?
    assert Try { 1 }.success?
  end

  def test_get_or_else
    s = Try { 1 }
    assert_equal 1, s.get_or_else(2)

    f = Try { raise 'failure' }
    assert_equal 2, f.get_or_else(2)
  end

  def test_or_else
    s = Try { 1 }
    assert_equal s, s.or_else(Try { 2 })

    f = Try { raise 'failure' }
    or_else = Try { 1 }
    assert_equal or_else, f.or_else(or_else)
  end

  def test_get
    s = Try { 1 }
    assert_equal 1, s.get

    f = Try { raise 'failure' }
    assert_raises { f.get }
  end

  def test_each
    s = Try { 1 }
    s.each do |v|
      assert_equal 1, v
    end

    f = Try { raise 'failure' }
    called = false
    f.each do |v|
      called = true
    end
    assert !called
  end

  def test_map
    s = Try { 1 }
    assert_equal 2, s.map { |v| v + 1 }.get

    f = Try { raise 'failure' }
    assert_equal f, f.map { |v| v + 1 }
  end

  def test_filter
    s = Try { 1 }
    assert_equal 1, s.filter { |v| v == 1 }.get
    assert_raises { s.filter { |v| v != 1 }.get }

    f = Try { raise 'failure' }
    assert_equal f, f.filter { |v| v == 1 }
  end

  def test_recover_with
    s = Try { 1 }
    assert_equal s, s.recover_with { |ex| Try { 2 } }

    f = Try { raise 'failure' }
    with_this = Try { 2 }
    assert_equal with_this, f.recover_with { |ex| with_this }
    assert_equal f, f.recover_with(EncodingError) { |ex| with_this }

    assert_equal with_this, f.recover_with(StandardError) { |_| with_this }

    assert_raises {
      f.recover_with { |ex| raise 'cannot recover with it' }
    }
  end

  def test_recover
    s = Try { 1 }
    assert_equal s, s.recover { |ex| 2}

    f = Try { raise 'failure' }
    assert_equal 2, f.recover { |ex| 2}.get
    assert_equal f, f.recover(IOError, &:message)

    recovered = f.recover(IOError, RuntimeError, &:message)
    assert recovered.success?
    assert_equal 'failure', recovered.get

    recover_supclass = f.recover(StandardError, &:message)
    assert recover_supclass.success?

    assert_raises {
      f.recover { |ex| raise 'cannot recover it' }
    }
  end

  def test_failed
    s = Try { 1 }
    assert s.failed.failure?

    f = Try { raise 'failure' }
    assert f.failed.success?
  end

  def test_transform
    s = Try { 1 }
    assert 2, s.transform( ->(v) { Try { v + 1 } }, ->(e) { Try { e } }).get

    f = Try { raise 'failure' }
    assert_raises('failure') {
      raise f.transform( ->(v) { Try { v + 1 } }, ->(e) { Try { e } }).get
    }
  end

  def test_flatten
    s = Try { Try { 1 } }
    assert 1, s.flatten.get
    s = Try { Try { raise 'failure' } }
    assert_raises('failure') {
      s.flatten.get
    }

    f = Try { raise 'failure' }
    assert_equal f, f.flatten
  end
end
