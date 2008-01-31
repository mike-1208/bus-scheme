module BusScheme
  class BusSchemeError < StandardError; end
  class ParseError < BusSchemeError; end
  class EvalError < BusSchemeError; end
  class ArgumentError < BusSchemeError; end

  PRIMITIVES = {
    # right now I believe there are as few things implemented primitively as possible
    # except for functions that require splat args. do we need something like &rest?
    
    '#t'.intern => true, # :'#t' screws up emacs' ruby parser
    '#f'.intern => false,

    :+ => lambda { |*args| args.inject { |sum, i| sum + i } },
    :- => lambda { |x, y| x - y },
    :* => lambda { |*args| args.inject { |product, i| product * i } },
    '/'.intern => lambda { |x, y| x / y },

    :concat => lambda { |*args| args.join('') },
    :cons => lambda { |car, cdr| Cons.new(car, cdr) },
    # todo: lambda args should come as lists by default, not vectors/arrays
    :list => lambda { |*members| members.to_list },
    :vector => lambda { |*members| members },
    
    :ruby => lambda { |*code| eval(code.join('')) },
    :eval => lambda { |code| eval_form(code) },
    :send => lambda { |obj, *message| obj.send(*message) },
    :load => lambda { |filename| eval_string("(begin #{File.read(filename)} )") },
    :exit => lambda { exit }, :quit => lambda { exit },
  }

  # if we add in macros, can some of these be defined in scheme?
  SPECIAL_FORMS = {
    :quote => lambda { |arg| arg.to_sexp },
    :if => lambda { |q, yes, *no| eval_form(q) ? eval_form(yes) : eval_form([:begin] + no) },
    :begin => lambda { |*args| args.map{ |arg| eval_form(arg) }.last },
    :set! => lambda { |sym, value| raise EvalError.new unless Lambda.scope.has_key?(sym) and 
      Lambda.scope[sym] = eval_form(value); sym },
    :lambda => lambda { |args, *form| Lambda.new(args, form) },
    :define => lambda { |sym, definition| Lambda.scope[sym] = eval_form(definition); sym },

    # once we have macros, this can be defined in scheme
    :let => lambda { |defs, *body| Lambda.new(defs.map{ |d| d.car }, body).call(*defs.map{ |d| eval_form d.last }) }
  }
end
