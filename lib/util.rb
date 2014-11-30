class String
  def valid_parentheses?
    valid = true
    gsub(/[^\(\)]/, '').split('').inject(0) do |counter, parenthesis|
      counter += (parenthesis == '(' ? 1 : -1)
      valid = false if counter < 0
      counter
    end.zero? && valid
  end

  def valid_braces?
    valid = true
    gsub(/[^\[\]]/, '').split('').inject(0) do |counter, parenthesis|
      counter += (parenthesis == '[' ? 1 : -1)
      valid = false if counter < 0
      counter
    end.zero? && valid
  end

  def valid_curlies?
    valid = true
    gsub(/[^\{\}]/, '').split('').inject(0) do |counter, parenthesis|
      counter += (parenthesis == '{' ? 1 : -1)
      valid = false if counter < 0
      counter
    end.zero? && valid
  end

  def valid_code?
    valid_parentheses? && valid_braces? && valid_curlies?
  end
end
