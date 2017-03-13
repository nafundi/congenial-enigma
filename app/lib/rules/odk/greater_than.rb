class Rules::Odk::GreaterThan < Rules::Odk::NumericOperator
  with_title 'Is Greater Than'

  protected

  def test_submission_value(numeric_value)
    numeric_value > value
  end
end
