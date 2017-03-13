class Rules::Odk::NumericEquality < Rules::Odk::NumericOperator
  with_title 'Is Exactly'

  protected

  def test_submission_value(numeric_value)
    numeric_value == value
  end
end
