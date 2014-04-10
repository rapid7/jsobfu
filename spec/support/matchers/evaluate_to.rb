RSpec::Matchers.define :evaluate_to do |expected|
  match do |observed|
    begin
      @expected_output = ExecJS.compile(expected).call('test')
    rescue ExecJS::ProgramError => e
      @example_failed = e
    end

    begin
      @observed_output = ExecJS.compile(observed).call('test')
    rescue ExecJS::ProgramError => e
      @compiled_failed = e
    end

    expect(@observed_output).to eq @expected_output
  end

  failure_message_for_should do |observed|
    if @example_failed
      "runtime error while evaluating:\n\n#{expected}\n\n#{@example_failed}"
    elsif @compiled_failed
      "runtime error while evaluating:\n\n#{observed}\n\n#{@compiled_failed}"
    else
      "expected that the code:\n\n#{observed}:\n\n=> #{@expected_output}\n\n"+
      "evaluate to the same result as :\n\n#{expected}\n\n=> #{@observed_output}"
    end
  end
end
