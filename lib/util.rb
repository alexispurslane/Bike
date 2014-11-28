class String
  def valid_parentheses?
    valid = true
    self.gsub(/[^\(\)]/, '').split('').inject(0) do |counter, parenthesis|
      counter += (parenthesis == '(' ? 1 : -1)
      valid = false if counter < 0
      counter
    end.zero? && valid
  end

  def valid_braces?
    valid = true
    self.gsub(/[^\[\]]/, '').split('').inject(0) do |counter, parenthesis|
      counter += (parenthesis == '[' ? 1 : -1)
      valid = false if counter < 0
      counter
    end.zero? && valid
  end

  def valid_curlies?
    valid = true
    self.gsub(/[^\{\}]/, '').split('').inject(0) do |counter, parenthesis|
      counter += (parenthesis == '{' ? 1 : -1)
      valid = false if counter < 0
      counter
    end.zero? && valid
  end

  def valid_code?
    self.valid_parentheses? && self.valid_braces? && self.valid_curlies?
  end
end
