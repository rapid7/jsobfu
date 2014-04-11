class JSObfu::Minifier < RKelly::Visitors::ECMAVisitor

  attr_reader :scope

  def initialize
    @scope = JSObfu::Scope.new
    super
  end

  def visit_SourceElementsNode(o)
    scope.push!
    ret = super
    scope.pop!
    ret
  end

  def visit_FunctionDeclNode(o)
    o.value = if o.value and o.value.length > 0
      scope.rename_var(o.value)
    else
      scope.random_var_name
    end

    super
  end

  def visit_FunctionExprNode(o)
    if o.value != 'function'
      o.value = scope.rename_var(o.value)
    end

    super
  end

  def visit_VarDeclNode(o)
    o.name = scope.rename_var(o.name)
    super
  end

  def visit_ResolveNode(o)
    new_val = scope.rename_var(o.value, :generate => false)
    if new_val then o.value = new_val end
    super
  end

  def visit_ParameterNode(o)
    o.value = scope.rename_var(o.value)
    super
  end

end
