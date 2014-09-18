require_relative 'obfuscator'

class JSObfu::Encoder < JSObfu::Obfuscator
  attr_reader :encoding_eval

  # Randomly encode some function elements into eval() statements
  def visit_SourceElementsNode(o)
    if rand(3) == 0 and !@encoding_eval
      @encoding_eval = true
      code = super
      @encoding_eval = false
      JSObfu::Utils.js_eval(code)
    else
      super
    end
  end

end
