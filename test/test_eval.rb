$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'

class BusSchemeEvalTest < Test::Unit::TestCase
  def test_eval_empty_list
    assert_evals_to [], []
    assert_evals_to true, "(if () #t #f)"
  end

  def test_eval_number
    assert_evals_to 2, 2
  end

  def test_set_symbol
    Lambda.scope[:hi] = 'hi'
    assert Lambda.scope[:hi]
  end
  
  def test_eval_symbol
    Lambda.scope[:hi] = 13
    assert_evals_to 13, :hi
  end

  def test_eval_string
    assert_evals_to "hi", "\"hi\""
  end

  def test_eval_function_call
    assert_evals_to 2, [:+, 1, 1]
  end

  def test_nested_arithmetic
    assert_evals_to 6, [:+, 1, [:+, 1, [:*, 2, 2]]]
  end

  def test_blows_up_with_undefined_symbol
    assert_raises(EvalError) { eval("undefined-symbol") }
  end

  def test_variable_substitution
    eval "(define foo 7)"
    assert_evals_to 7, :foo.node
    assert_evals_to 21, [:*, 3, :foo.node]
  end

  def test_single_quote
    assert_evals_to :foo.node, "'foo"
    assert_evals_to [:foo.node, :biz.node, :bbb.node].to_list, "'(foo biz bbb)"
  end

  def test_array_of_args_or_list_of_args
    assert_evals_to 5, cons(:+, cons(2, cons(3)))
    assert_evals_to 5, cons(:+, cons(2, cons(3)).to_a)
  end

  def test_eval_multiple_forms
    assert_raises(AssertionFailed) do
      BusScheme.eval_string "(+ 2 2) (assert #f)"
    end
  end

  def test_define_after_load
    BusScheme.eval_string "(load \"#{File.dirname(__FILE__)}/../examples/fib.scm\")
(define greeting \"hi\")"
    assert Lambda[:greeting]
  end

  def test_funcall_list_means_nth
    assert_evals_to 3, "((list 1 2 3) 2)"
  end

  def test_funcall_vector_means_nth
    assert_evals_to 3, "((vector 1 2 3) 2)"
  end

  def test_funcall_hash_means_lookup
    assert_evals_to 3, "((hash (1 1) (2 2) (3 3)) 3)"
  end
end
