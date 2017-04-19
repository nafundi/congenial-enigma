class Rules::Odk::LessThan < Rules::Odk::NumericOperator
  with_title 'Is Less Than'

  protected

  def test_submission_value(numeric_value)
    numeric_value < value
  end
end
