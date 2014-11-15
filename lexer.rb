def to_fi(v)
  v.match('\.').nil? ? Integer(v) : Float(v)
end
class Lexer
  KEYWORDS = ["var", "def", "class", "if", "let", "else", "true", "false", "nil", "while", "unless", "lambda", "apply", "extends", "import", "into", "package", "with"]
  
  def tokenize(code)
    code.chomp!
    i = 0
    tokens = []
    
    while i < code.size
      chunk = code[i..-1]

      if operator = chunk[/\A(isnt|or|and|not|is|<=|>=)/, 1]
        tokens << [operator, operator]
        i += operator.size
      elsif identifier = chunk[/\A([a-zA-Z]\w*)/, 1]
        if KEYWORDS.include?(identifier)
          tokens << [identifier.upcase.to_sym, identifier]
        else
          tokens << [:IDENTIFIER, identifier]
        end
        i += identifier.size
      elsif number = chunk[/\A([-+]?[0-9]+\.?[0-9]*)/, 1]
        tokens << [:NUMBER, to_fi(number)]
        i += number.size
      elsif string = chunk[/\A"(.*?)"/, 1]
        tokens << [:STRING, string]
        i += string.size + 2

       elsif string = chunk[/\A'(.*?)'/, 1]
        tokens << [:STRING, string]
        i += string.size + 2
      
      ######
      # All indentation magic code was removed and only this elsif was added.
      elsif chunk.match(/\A\n+/)
        tokens << [:NEWLINE, "\n"]
        i += 1
      ######

      elsif chunk.match(/\A /)
        i += 1
      elsif comment = chunk.match(/\A#*$/)
        i += comment.size
      else
        value = chunk[0,1]
        tokens << [value, value]
        i += 1
        
      end
      
    end
    
    tokens
  end
end
